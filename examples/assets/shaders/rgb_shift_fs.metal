#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct RgbShiftParams
{
    float shift;
    float alpha;
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
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, constant RgbShiftParams& v_39)
{
#line 24 ""
#line 25 ""
#line 27 ""
    float _63 = v_39.shift * (1.0 / v_39.screen_size.x);
    float _71 = v_39.shift * (1.0 / v_39.screen_size.y);
    float _72 = tex_coord.y - _71;
    float4 _74 = tex.sample(texSmplr, float2(tex_coord.x + _63, _72));
#line 28 ""
    float4 _88 = tex.sample(texSmplr, float2(tex_coord.x, tex_coord.y + _71));
#line 29 ""
    float4 _108 = tex.sample(texSmplr, float2(tex_coord.x - _63, _72));
    return float4(_74.x, _88.y, _108.z, ((_74.w + _88.w) + (_108.w * 0.3333333432674407958984375)) * v_39.alpha);
}

#line 15 ""
fragment main0_out main0(main0_in in [[stage_in]], constant RgbShiftParams& v_39 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], sampler main_texSmplr [[sampler(0)]])
{
    main0_out out = {};
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    out.frag_color = effect(main_tex, main_texSmplr, param, param_1, v_39);
    return out;
}

