#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

uniform sampler2D _MainTex;
uniform float4    _MainTex_ST;
uniform float     _Alpha;

uniform int       _VoxelSource;
uniform float     _VoxelMinSize;
uniform float     _VoxelSize;
uniform float     _VoxelOffsetN;
uniform float     _VoxelOffsetX;
uniform float     _VoxelOffsetY;
uniform float     _VoxelOffsetZ;
uniform int       _UVSamplingSource;

uniform int       _EnableAnimation;

uniform int       _EnableThinOut;
uniform int       _ThinOutSource;
uniform sampler2D _ThinOutMaskTex;
uniform sampler2D _ThinOutNoiseTex;
uniform float     _ThinOutNoiseThresholdR;
uniform float     _ThinOutNoiseThresholdG;
uniform float     _ThinOutNoiseThresholdB;
uniform float     _ThinOutMinSize;

struct v2g {
    float4 vertex    : SV_POSITION;
    float3 normal    : NORMAL;
    float2 uv        : TEXCOORD0;
};

struct g2f {
    float4 pos       : SV_POSITION;
    float3 normal    : NORMAL;
    float2 uv        : TEXCOORD0;

    SHADOW_COORDS(1)
};

#include "vert.cginc"
#include "geom.cginc"
#include "frag.cginc"