#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct main0_out
{
    float4 frag_color [[color(0)]];
};

struct main0_in
{
    float4 color [[user(locn0)]];
    float2 uv [[user(locn1)]];
};

#line 13 ""
fragment main0_out main0(main0_in in [[stage_in]], texture2d<float> tex [[texture(0)]], sampler texSmplr [[sampler(0)]])
{
    main0_out out = {};
#line 13 ""
    out.frag_color = tex.sample(texSmplr, in.uv) * in.color;
    return out;
}

