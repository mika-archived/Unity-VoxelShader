Shader "Mochizuki/Voxel Shader/Opaque"
{
    Properties
    {
        // Main
        _MainTex                ("Main Texture",                  2D) = "white" {}

        // Voxel
        [Enum(Mochizuki.VoxelShader.VoxelSource)]
        _VoxelSource            ("Voxel Source",                 Int) = 1
        _VoxelMinSize           ("Voxel Minimal Size",         Float) = 0
        _VoxelSize              ("Voxel Size",                 Float) = 0.0125
        _VoxelOffsetN           ("Voxel offset Normal",        Float) = 0
        _VoxelOffsetX           ("Voxel Offset X",             Float) = 0
        _VoxelOffsetY           ("Voxel Offset Y",             Float) = 0
        _VoxelOffsetZ           ("Voxel Offset X",             Float) = 0
        [Enum(Mochizuki.VoxelShader.UvSamplingSource)]
        _UVSamplingSource       ("UV Sampling Source",           Int) = 0

        // Animation
        [ToggleWithoutKeyword]
        _EnableAnimation        ("Enable Animation",             Int) = 1

        // Thin Out
        [ToggleWithoutKeyword]
        _EnableThinOut          ("Enable ThinOut",               Int) = 0
        [Enum(Mochizuki.VoxelShader.ThinOutSource)]
        _ThinOutSource          ("ThinOut Source",               Int) = 0
        [NoScaleOffset]
        _ThinOutMaskTex         ("ThinOut Mask Texture",          2D) = "white" {}
        [NoScaleOffset]
        _ThinOutNoiseTex        ("ThinOut Noise Texture",         2D) = "white" {}
        _ThinOutNoiseThresholdR ("ThinOut Noise Threshold R",  Float) = 1
        _ThinOutNoiseThresholdG ("ThinOut Noise Threshold G",  Float) = 1
        _ThinOutNoiseThresholdB ("ThinOut Noise Threshold B",  Float) = 1
        _ThinOutMinSize         ("ThinOut Minimal Size",       Float) = 1

        // Advanced
        [Enum(UnityEngine.Rendering.CullMode)]
        _Culling                ("Culling",                     Int) = 0
        [Enum(Off,0,On,1)]
        _ZWrite                 ("_ZWrite",                     Int) = 0

        // Meta
        [HideInInspector]
        _VersionMajor           ("Major Version",               Int) = 0
        [HideInInspector]
        _VersionMinor           ("Minor Version",               Int) = 0
        [HideInInspector]
        _VersionPatch           ("Patch Version",               Int) = 0
    }

    SubShader
    {
        LOD 0

        Tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
            "IgnoreProjector" = "False"
        }

        Pass
        {
            Tags {
                "LightMode" = "ForwardBase"
            }

            Cull   [_Culling]
            ZWrite [_ZWrite]
            
            CGPROGRAM

            #pragma require  geometry

            #pragma vertex   vs
            #pragma geometry gs
            #pragma fragment fs

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #pragma target   4.5

            #define RENDER_AS_OPAQUE
            #define RENDER_PASS_FB

            #include "includes/core.cginc"

            ENDCG
        }

        /*
        Pass
        {
            Tags {
                "LightMode" = "ForwardAdd"
            }

            Cull   [_Culling]
            ZWrite Off

            CGPROGRAM

            // #pragma vertex   vs
            // #pragma geometry gs
            // #pragma fragment fs

            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #pragma target   4.5

            #define RENDER_AS_OPAQUE
            #define RENDER_PASS_FA

            // #include "includes/core.cginc"

            ENDCG
        }
        */

        Pass {
            Tags {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On

            CGPROGRAM

            #pragma require  geometry

            #pragma vertex   vs
            #pragma geometry gs
            #pragma fragment fs

            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog

            #pragma target   4.5

            #define RENDER_AS_OPAQUE
            #define RENDER_PASS_SC

            #include "includes/core.cginc"

            ENDCG
        }
    }

    Fallback "Diffuse"

    CustomEditor "Mochizuki.VoxelShader.VoxelShaderGui"
}