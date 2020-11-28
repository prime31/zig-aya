#pragma clang diagnostic ignored "-Wmissing-prototypes"
#pragma clang diagnostic ignored "-Wmissing-braces"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

template<typename T, size_t Num>
struct spvUnsafeArray
{
    T elements[Num ? Num : 1];
    
    thread T& operator [] (size_t pos) thread
    {
        return elements[pos];
    }
    constexpr const thread T& operator [] (size_t pos) const thread
    {
        return elements[pos];
    }
    
    device T& operator [] (size_t pos) device
    {
        return elements[pos];
    }
    constexpr const device T& operator [] (size_t pos) const device
    {
        return elements[pos];
    }
    
    constexpr const constant T& operator [] (size_t pos) const constant
    {
        return elements[pos];
    }
    
    threadgroup T& operator [] (size_t pos) threadgroup
    {
        return elements[pos];
    }
    constexpr const threadgroup T& operator [] (size_t pos) const threadgroup
    {
        return elements[pos];
    }
};

struct MetaFlamesParams
{
    float tear_sharpness;
    float tear_wave_length;
    float tear_wave_speed;
    float tear_wave_amplitude;
    float iTime;
    float2 iResolution;
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

#line 33 ""
static inline __attribute__((always_inline))
float4 effect(thread const texture2d<float> tex, thread const sampler texSmplr, thread const float2& tex_coord, thread const float4& vert_color, thread float2& dither_amount, thread spvUnsafeArray<float2, 20> (&metaball_pos), constant MetaFlamesParams& v_63, thread spvUnsafeArray<float, 20> (&metaball_radius), thread spvUnsafeArray<float, 20> (&metaball_influence), thread float4& gl_FragCoord)
{
#line 33 ""
    for (int i = 0; i < 20; i++)
    {
#line 34 ""
        float _54 = float(i);
        float _69 = v_63.iTime * 1000.0;
        float _74 = 500.0 + (_54 * 200.0);
        metaball_pos[i].x = ((sin(_69 / (_74 + (mod(_54, 6.0) * 500.0))) * 0.31847131252288818359375) + 0.5) * v_63.iResolution.x;
        metaball_pos[i].y = ((cos(_69 / (_74 - (mod(_54, 5.0) * 500.0))) * 0.31847131252288818359375) + 0.5) * v_63.iResolution.y;
        metaball_radius[i] = 150.0;
        metaball_influence[i] = 0.5;
    }
#line 41 ""
    float _128 = sin(v_63.iTime);
    metaball_pos[1].x = ((_128 * 0.31847131252288818359375) + 0.5) * v_63.iResolution.x;
    metaball_pos[1].y = ((cos(v_63.iTime * 0.25) * 0.31847131252288818359375) + 0.5) * v_63.iResolution.y;
#line 43 ""
    metaball_radius[1] = 400.0;
#line 44 ""
    metaball_influence[1] = 1.0;
    metaball_pos[2].x = ((sin(v_63.iTime * 0.5) * 0.31847131252288818359375) + 0.5) * v_63.iResolution.x;
    metaball_pos[2].y = ((cos(v_63.iTime * 0.3333333432674407958984375) * 0.31847131252288818359375) + 0.5) * v_63.iResolution.y;
#line 47 ""
    metaball_radius[2] = 400.0;
#line 48 ""
    metaball_influence[2] = 1.0;
#line 50 ""
    float influence = 0.0;
#line 53 ""
    float4 fg = tex.sample(texSmplr, tex_coord);
#line 56 ""
    for (int i_1 = 0; i_1 < 20; i_1++)
    {
#line 58 ""
        float _199 = v_63.iResolution.y - gl_FragCoord.y;
        float _211 = gl_FragCoord.x + sin((_199 / dither_amount.x) + (cos(v_63.iTime) * 4.0));
        float _223 = _199 + cos((_211 / dither_amount.y) + (_128 * 4.0));
        float _323 = fast::min(1.0, ((((distance(float2(_211, _223), metaball_pos[i_1]) + pow((abs(metaball_pos[i_1].x - _211) * v_63.tear_sharpness) / abs(_223 - (metaball_pos[i_1].y - metaball_radius[i_1]) - (sin((_211 / v_63.tear_wave_length) + ((v_63.iTime * v_63.tear_wave_speed) / metaball_radius[i_1])) * v_63.tear_wave_amplitude)), 2.0)) + ((sin((_223 * 3.1400001049041748046875) + v_63.iTime) * metaball_radius[i_1]) / dither_amount.y)) + ((cos((_211 * 3.1400001049041748046875) + v_63.iTime) * metaball_radius[i_1]) / dither_amount.x)) / pow((fg.x * 0.89999997615814208984375) + 0.10000002384185791015625, 2.0)) / metaball_radius[i_1]);
        float _327 = 1.0 - (_323 * _323);
        influence += ((_327 * _327) * metaball_influence[i_1]);
    }
    float _342 = influence;
    float _348 = (_342 + fg.y) - fg.z;
    influence = _348;
    float4 _370 = fg;
    _370.x = step(0.00999999977648258209228515625, _348);
    float4 _372 = _370;
    _372.y = step(0.300000011920928955078125, _348);
    float4 _374 = _372;
    _374.z = step(0.75, _348);
    float4 _376 = _374;
    _376.w = 1.0;
    fg = _376;
    return _376;
}

#line 26 ""
fragment main0_out main0(main0_in in [[stage_in]], constant MetaFlamesParams& v_63 [[buffer(0)]], texture2d<float> main_tex [[texture(0)]], sampler main_texSmplr [[sampler(0)]], float4 gl_FragCoord [[position]])
{
    main0_out out = {};
#line 26 ""
    float2 dither_amount = float2(20.0, 40.0);
#line 15 ""
    float2 param = in.uv_out;
    float4 param_1 = in.color_out;
    spvUnsafeArray<float2, 20> metaball_pos;
    spvUnsafeArray<float, 20> metaball_radius;
    spvUnsafeArray<float, 20> metaball_influence;
    float4 _37 = effect(main_tex, main_texSmplr, param, param_1, dither_amount, metaball_pos, v_63, metaball_radius, metaball_influence, gl_FragCoord);
    out.frag_color = _37;
    return out;
}

