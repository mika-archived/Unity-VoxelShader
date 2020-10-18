/*-------------------------------------------------------------------------------------------
 * Copyright (c) Fuyuno Mikazuki / Natsuneko. All rights reserved.
 * Licensed under the MIT License. See LICENSE in the project root for license information.
 *------------------------------------------------------------------------------------------*/

// #include "core.cginc"

#if defined(RENDER_PASS_FB) || defined(RENDER_PASS_FA)

float4 getFragmentColor(float3 color, float alpha = 1.0) {
#if defined(RENDER_PASS_FB)
    return float4(color, alpha);
#else
    return lerp(float4(color, alpha), float4(color, 0.0), _Unlighting);
#endif
}

float4 fs(g2f i) : SV_TARGET {
    const float3 lightColor = _LightColor0.rgb * LIGHT_ATTENUATION(i);
    const float3 color  = tex2D(_MainTex, i.uv).rgb;

#if defined(RENDER_PAS_FB)
    const float3 lightBase = _LightColor0.rgb;
#else
    const float3 lightBase = _LightColor0.rgb * LIGHT_ATTENUATION(i);
#endif

    const float3 shadow = max(lightBase * SHADOW_ATTENUATION(i), 0.5) + 0.25;
    const float3 frag   = color * shadow;

#if defined(RENDER_MODE_TRANSPARENT)
    float4 fragWithAlpha = getFragmentColor(frag, _Alpha);
#else
    float4 fragWithAlpha = getFragmentColor(frag);
#endif

    UNITY_APPLY_FOG(i.fogCoord, fragWithAlpha);

    return fragWithAlpha;
}

#elif defined(RENDER_PASS_SC)

float4 fs(g2f i) : SV_TARGET {
    SHADOW_CASTER_FRAGMENT(i)
}

#endif