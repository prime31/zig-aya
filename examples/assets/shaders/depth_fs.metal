#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct DepthParamsFS
{
    float near;
    float far;
};

struct main0_out
{
    float4 frag_color [[color(0)]];
};

#line 16 ""
static inline __attribute__((always_inline))
float linearizeDepth(thread const float& depth, constant DepthParamsFS& v_21)
{
#line 16 ""
#line 17 ""
    return ((2.0 * v_21.near) * v_21.far) / ((v_21.far + v_21.near) - (((depth * 2.0) - 1.0) * (v_21.far - v_21.near)));
}

#line 21 ""
fragment main0_out main0(constant DepthParamsFS& v_21 [[buffer(0)]], float4 gl_FragCoord [[position]])
{
    main0_out out = {};
#line 21 ""
    float param = gl_FragCoord.z;
    float _61 = linearizeDepth(param, v_21) / v_21.far;
    out.frag_color = float4(_61, _61, _61, 1.0);
    return out;
}

