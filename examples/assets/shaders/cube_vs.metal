#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct CubeParamsVS
{
    float4x4 mvp;
};

struct main0_out
{
    float4 color [[user(locn0)]];
    float2 uv [[user(locn1)]];
    float4 gl_Position [[position]];
};

struct main0_in
{
    float4 pos [[attribute(0)]];
    float4 color0 [[attribute(1)]];
    float2 texcoord0 [[attribute(2)]];
};

#line 18 ""
vertex main0_out main0(main0_in in [[stage_in]], constant CubeParamsVS& _20 [[buffer(0)]])
{
    main0_out out = {};
#line 18 ""
    out.gl_Position = _20.mvp * in.pos;
#line 19 ""
    out.color = in.color0;
#line 20 ""
    out.uv = in.texcoord0;
    return out;
}

