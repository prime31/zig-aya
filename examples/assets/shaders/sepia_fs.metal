#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct SepiaParams
{
    float3 sepia_tone;
};

struct main0_out
{
    float4 frag_color [[color(0)]];
};

struct main0_in
{
    float2 uv_out [[user(locn0)]];
    float4 color_out [[user(locn1)]];
};

#line 22 ""
static inline __attribute__((always_inline))
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, constant SepiaParams& v_52)
{
#line 22 ""
    float4 _36 = tex.sample(texSmplr, tex_coord);
    float3 _41 = _36.xyz;
    float3 _61 = mix(_41, v_52.sepia_tone * dot(_41, float3(0.300000011920928955078125, 0.589999973773956298828125, 0.10999999940395355224609375)), float3(0.75));
    return float4(_61.x, _61.y, _61.z, _36.w);
}

#line 15 ""
fragment main0_out main0(main0_in in [[stage_in]], constant SepiaParams& v_52 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], sampler main_texSmplr [[sampler(0)]])
{
    main0_out out = {};
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    out.frag_color = effect(main_tex, main_texSmplr, param, param_1, v_52);
    return out;
}

