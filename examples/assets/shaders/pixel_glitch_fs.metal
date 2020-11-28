#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct PixelGlitchParams
{
    float vertical_size;
    float horizontal_offset;
    float2 screen_size;
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

#line 24 ""
static inline __attribute__((always_inline))
float hash11(thread const float& p)
{
#line 24 ""
    float3 _47 = fract(float3(p, p, p) * 0.103100001811981201171875);
    float3 _57 = _47 + float3(dot(_47, _47.yzx + float3(19.1900005340576171875)));
    return fract((_57.x + _57.y) * _57.z);
}

#line 31 ""
static inline __attribute__((always_inline))
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, constant PixelGlitchParams& v_76)
{
#line 31 ""
#line 32 ""
#line 35 ""
    float param = floor(tex_coord.y * (v_76.screen_size.x / v_76.vertical_size));
#line 36 ""
    return tex.sample(texSmplr, float2(tex_coord.x + (((hash11(param) * 2.0) - 1.0) * (v_76.horizontal_offset / v_76.screen_size.y)), tex_coord.y));
}

#line 15 ""
fragment main0_out main0(main0_in in [[stage_in]], constant PixelGlitchParams& v_76 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], sampler main_texSmplr [[sampler(0)]])
{
    main0_out out = {};
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    out.frag_color = effect(main_tex, main_texSmplr, param, param_1, v_76);
    return out;
}

