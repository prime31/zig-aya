#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct NoiseParams
{
    float time;
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

// Implementation of the GLSL mod() function, which is slightly different than Metal fmod()
template<typename Tx, typename Ty>
inline Tx mod(Tx x, Ty y)
{
    return x - y * floor(x / y);
}

#line 27 ""
static inline __attribute__((always_inline))
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, constant NoiseParams& v_52)
{
#line 27 ""
    float4 _36 = tex.sample(texSmplr, tex_coord);
#line 28 ""
    float _61 = ((tex_coord.x + 4.0) * (tex_coord.y + 4.0)) * (sin(v_52.time) * 10.0);
    float3 _87 = _36.xyz + (float3(mod((mod(_61, 13.0) + 1.0) * (mod(_61, 123.0) + 1.0), 0.00999999977648258209228515625) - 0.004999999888241291046142578125) * v_52.power);
    return float4(_87.x, _87.y, _87.z, _36.w);
}

#line 15 ""
fragment main0_out main0(main0_in in [[stage_in]], constant NoiseParams& v_52 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], sampler main_texSmplr [[sampler(0)]])
{
    main0_out out = {};
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    out.frag_color = effect(main_tex, main_texSmplr, param, param_1, v_52);
    return out;
}

