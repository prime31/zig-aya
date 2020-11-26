#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct LinesParams
{
    float4 line_color;
    float line_size;
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

#line 24 ""
static inline __attribute__((always_inline))
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, thread float4& gl_FragCoord, constant LinesParams& v_55)
{
#line 24 ""
#line 27 ""
#line 33 ""
    return mix(float4(0.0), v_55.line_color, float4(mod(floor(gl_FragCoord.y / v_55.line_size), 2.0))) * tex.sample(texSmplr, tex_coord).w;
}

#line 15 ""
fragment main0_out main0(main0_in in [[stage_in]], constant LinesParams& v_55 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], sampler main_texSmplr [[sampler(0)]], float4 gl_FragCoord [[position]])
{
    main0_out out = {};
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    out.frag_color = effect(main_tex, main_texSmplr, param, param_1, gl_FragCoord, v_55);
    return out;
}

