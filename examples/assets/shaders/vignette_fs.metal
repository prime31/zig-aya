#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VignetteParams
{
    float radius;
    float power;
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

#line 23 ""
static inline __attribute__((always_inline))
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, constant VignetteParams& v_44)
{
#line 23 ""
    float4 _36 = tex.sample(texSmplr, tex_coord);
#line 25 ""
    float2 _50 = (tex_coord - float2(0.5)) * v_44.radius;
    float3 _69 = _36.xyz * (1.0 - (dot(_50, _50) * v_44.power));
    return float4(_69.x, _69.y, _69.z, _36.w);
}

#line 15 ""
fragment main0_out main0(main0_in in [[stage_in]], constant VignetteParams& v_44 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], sampler main_texSmplr [[sampler(0)]])
{
    main0_out out = {};
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    out.frag_color = effect(main_tex, main_texSmplr, param, param_1, v_44);
    return out;
}

