// #include "core.cginc"

v2g vs(appdata_full v) {
    v2g o = (v2g) 0;
    o.vertex = mul(unity_ObjectToWorld, v.vertex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.uv     = TRANSFORM_TEX(v.texcoord, _MainTex);

    return o;
}