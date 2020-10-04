
// #include "core.cginc"

#if defined(RENDER_PASS_FB)

float4 fs(g2f i) : SV_TARGET {
    const float3 d = dot(i.normal, normalize(_WorldSpaceLightPos0.xyz));

    const float3 color  = tex2D(_MainTex, i.uv).rgb;
    const float3 light  = (d * 0.5 + 0.5) * _LightColor0.rgb * LIGHT_ATTENUATION(i);
    const float3 shadow = max(light * SHADOW_ATTENUATION(i), 0.5) + 0.25;
    const float3 frag   = color * shadow;

#if defined(RENDER_MODE_TRANSPARENT)
    return lerp(float4(frag, 0), float4(frag, 1.0), _Alpha);
#else
    return float4(frag, 1.0);
#endif
}

#elif defined(RENDER_PASS_SC)

float4 fs(g2f i) : SV_TARGET {
    SHADOW_CASTER_FRAGMENT(i)
}

#endif