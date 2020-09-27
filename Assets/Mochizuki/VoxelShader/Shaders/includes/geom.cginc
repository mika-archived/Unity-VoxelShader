// #include "core.cginc"

#define INPUT_VERTEXES 3

inline float3 getVertexPosFromIndex(v2g i[INPUT_VERTEXES], uint index) {
    v2g v = i[index];
    return v.vertex.xyz;
}

inline float2 getVertexUVFromIndex(v2g i[INPUT_VERTEXES], uint index) {
    v2g v = i[index];
    return v.uv;
}

inline float2 getUV(float2 a, float2 b, float2 c) {
    if (_UVSamplingSource == 0) return (a + b + c) / 3;
    if (_UVSamplingSource == 1) return a;
    if (_UVSamplingSource == 2) return b;
    if (_UVSamplingSource == 3) return c;

    return float2(0.0, 0.0);
}

inline float getMaxDistanceFor(float a, float b, float c) {
    if (_VoxelSource == 0) {
        const float s = max(max(distance(a, b), distance(b, c)), distance(a, c));
        return s < _VoxelMinSize ? _VoxelMinSize : s;
    } else {
        return _VoxelSize;
    }
}

inline float getRandom(float2 st, int seed) {
    return frac(sin(dot(st.xy, float2(12.9898, 78.233)) + seed) * 43758.5453123); 
}

inline float3 calcNormal(float3 a, float3 b, float3 c) {
    return normalize(cross(b - a, c - a));
}

inline float3 getVertex(float3 center, float x, float y, float z) {
    return center + mul(unity_ObjectToWorld, float4(x, y, z, 0.0)).xyz;
}

inline g2f getStreamData(float3 vertex, float3 normal, float2 uv) {
    g2f o = (g2f) 0;
    o.pos    = UnityWorldToClipPos(vertex);
    o.normal = normal;
    o.uv     = uv;

    TRANSFER_SHADOW(o);

    return o;
}

[maxvertexcount(24)]
void gs(triangle v2g i[INPUT_VERTEXES], uint id : SV_PRIMITIVEID, inout TriangleStream<g2f> stream) {
    const float2 u1 = getVertexUVFromIndex(i, 0);
    const float2 u2 = getVertexUVFromIndex(i, 0);
    const float2 u3 = getVertexUVFromIndex(i, 0);

    const float2 uv = getUV(u1, u2, u3);

    if (_EnableThinOut == 1) {
        if (_ThinOutSource == 0) {
            const float4 m = tex2Dlod(_ThinOutMaskTex, float4(uv, 0.0, 0.0));
            if (m.r <= 0.5) {
                return;
            }
        }
        if (_ThinOutSource == 1) {
            const float4 n = tex2Dlod(_ThinOutNoiseTex, float4(uv, 0.0, 0.0));
            if (n.r < _ThinOutNoiseThresholdR && n.g < _ThinOutNoiseThresholdG && n.b < _ThinOutNoiseThresholdB) {
                return;
            }
        }
    }

    const float3 p1 = getVertexPosFromIndex(i, 0);
    const float3 p2 = getVertexPosFromIndex(i, 1);
    const float3 p3 = getVertexPosFromIndex(i, 2);
    
    const float3 center = (p1 + p2 + p3) / 3;

    const float x = getMaxDistanceFor(p1.x, p2.x, p3.x);
    const float y = getMaxDistanceFor(p1.y, p2.y, p3.y);
    const float z = getMaxDistanceFor(p1.z, p2.z, p3.z);

    if (_EnableThinOut == 1 && _ThinOutSource == 2) {
        if (x + y + z <= _ThinOutMinSize) {
            return;
        }
    }

    const float r1 = getRandom(i[0].uv, id);
    const float r2 = getRandom(i[1].uv, id);
    const float r3 = getRandom(i[2].uv, id);

    const float3 o = calcNormal(p1, p2, p3);

    const float3 dirs[3] = {
        float3(1.0, 0.0, 0.0),
        float3(0.0, 1.0, 0.0),
        float3(0.0, 0.0, 1.0),
    };

    const float signs[2] = { 1, -1 };

    const float3 d1 = dirs[0] * r1;
    const float3 d2 = dirs[1] * r2;
    const float3 d3 = dirs[2] * r3;

    const float  t = _SinTime.w * r1 + _CosTime.w * r3;
    const float3 f = _EnableAnimation ? (t / 250) * o * (d1 + d2 + d3) * signs[round(r2)] : 0;

    const float s = _VoxelSource == 0 ? 0 : 0;

    const float hx = x / 2 + s;
    const float hy = y / 2 + s;
    const float hz = z / 2 + s;

    // top
    {
        const float3 a = getVertex(center,  hx, hy,  hz);
        const float3 b = getVertex(center,  hx, hy, -hz);
        const float3 c = getVertex(center, -hx, hy,  hz);
        const float3 d = getVertex(center, -hx, hy, -hz);

        const float3 n = calcNormal(a, b, c);

        stream.Append(getStreamData(a + f, n, uv));
        stream.Append(getStreamData(b + f, n, uv));
        stream.Append(getStreamData(c + f, n, uv));
        stream.Append(getStreamData(d + f, n, uv));
        stream.RestartStrip();
    }

    // bottom
    {
        const float3 a = getVertex(center,  hx, -hy,  hz);
        const float3 b = getVertex(center, -hx, -hy,  hz);
        const float3 c = getVertex(center,  hx, -hy, -hz);
        const float3 d = getVertex(center, -hx, -hy, -hz);

        const float3 n = calcNormal(a, b, c);

        stream.Append(getStreamData(a + f, n, uv));
        stream.Append(getStreamData(b + f, n, uv));
        stream.Append(getStreamData(c + f, n, uv));
        stream.Append(getStreamData(d + f, n, uv));
        stream.RestartStrip();
    }

    // left side
    {
        const float3 a = getVertex(center, hx,  hy,  hz);
        const float3 b = getVertex(center, hx, -hy,  hz);
        const float3 c = getVertex(center, hx,  hy, -hz);
        const float3 d = getVertex(center, hx, -hy, -hz);

        const float3 n = calcNormal(a, b, c);

        stream.Append(getStreamData(a + f, n, uv));
        stream.Append(getStreamData(b + f, n, uv));
        stream.Append(getStreamData(c + f, n, uv));
        stream.Append(getStreamData(d + f, n, uv));
        stream.RestartStrip();
    }

    // right side
    {
        const float3 a = getVertex(center, -hx,  hy,  hz);
        const float3 b = getVertex(center, -hx,  hy, -hz);
        const float3 c = getVertex(center, -hx, -hy,  hz);
        const float3 d = getVertex(center, -hx, -hy, -hz);

        const float3 n = calcNormal(a, b, c);

        stream.Append(getStreamData(a + f, n, uv));
        stream.Append(getStreamData(b + f, n, uv));
        stream.Append(getStreamData(c + f, n, uv));
        stream.Append(getStreamData(d + f, n, uv));
        stream.RestartStrip();
    }

    // foreground
    {
        const float3 a = getVertex(center,  hx,  hy, hz);
        const float3 b = getVertex(center, -hx,  hy, hz);
        const float3 c = getVertex(center,  hx, -hy, hz);
        const float3 d = getVertex(center, -hx, -hy, hz);

        const float3 n = calcNormal(a, b, c);

        stream.Append(getStreamData(a + f, n, uv));
        stream.Append(getStreamData(b + f, n, uv));
        stream.Append(getStreamData(c + f, n, uv));
        stream.Append(getStreamData(d + f, n, uv));
        stream.RestartStrip();
    }

    // background
    {
        const float3 a = getVertex(center,  hx,  hy, -hz);
        const float3 b = getVertex(center,  hx, -hy, -hz);
        const float3 c = getVertex(center, -hx,  hy, -hz);
        const float3 d = getVertex(center, -hx, -hy, -hz);

        const float3 n = calcNormal(a, b, c);

        stream.Append(getStreamData(a + f, n, uv));
        stream.Append(getStreamData(b + f, n, uv));
        stream.Append(getStreamData(c + f, n, uv));
        stream.Append(getStreamData(d + f, n, uv));
        stream.RestartStrip();
    }
}