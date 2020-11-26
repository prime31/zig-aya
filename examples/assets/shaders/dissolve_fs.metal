#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct DissolveParams
{
    float progress;
    float threshold;
    float4 threshold_color;
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

#line 25 ""
static inline __attribute__((always_inline))
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, constant DissolveParams& v_37, thread texture2d<float> dissolve_tex, thread const sampler dissolve_texSmplr)
{
#line 25 ""
    float _46 = v_37.progress + v_37.threshold;
#line 27 ""
    float4 _50 = tex.sample(texSmplr, tex_coord);
#line 29 ""
    float4 _56 = dissolve_tex.sample(dissolve_texSmplr, tex_coord);
    float _60 = 1.0 - _56.x;
    float _65 = _46 - v_37.threshold;
    if (_60 < _65)
    {
#line 33 ""
        discard_fragment();
    }
#line 37 ""
    return mix(_50, _50 * mix(float4(0.0, 0.0, 0.0, 1.0), v_37.threshold_color, float4(mix(1.0, 0.0, 1.0 - fast::clamp(abs(_65 - _60) / v_37.threshold, 0.0, 1.0)))), float4(float(_60 < _46)));
}

#line 15 ""
fragment main0_out main0(main0_in in [[stage_in]], constant DissolveParams& v_37 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], texture2d<float> dissolve_tex [[texture(1)]], sampler main_texSmplr [[sampler(0)]], sampler dissolve_texSmplr [[sampler(1)]])
{
    main0_out out = {};
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    float4 _32 = effect(main_tex, main_texSmplr, param, param_1, v_37, dissolve_tex, dissolve_texSmplr);
    out.frag_color = _32;
    return out;
}

