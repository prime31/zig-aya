#version 330

uniform vec4 MetaFlamesParams[2];
uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;
vec2 dither_amount;
vec2 metaball_pos[20];
float metaball_radius[20];
float metaball_influence[20];

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    for (int i = 0; i < 20; i++)
    {
        float _54 = float(i);
        float _69 = MetaFlamesParams[1].x * 1000.0;
        float _74 = 500.0 + (_54 * 200.0);
        metaball_pos[i].x = ((sin(_69 / (_74 + (mod(_54, 6.0) * 500.0))) * 0.31847131252288818359375) + 0.5) * MetaFlamesParams[1].z;
        metaball_pos[i].y = ((cos(_69 / (_74 - (mod(_54, 5.0) * 500.0))) * 0.31847131252288818359375) + 0.5) * MetaFlamesParams[1].w;
        metaball_radius[i] = 150.0;
        metaball_influence[i] = 0.5;
    }
    float _128 = sin(MetaFlamesParams[1].x);
    metaball_pos[1].x = ((_128 * 0.31847131252288818359375) + 0.5) * MetaFlamesParams[1].z;
    metaball_pos[1].y = ((cos(MetaFlamesParams[1].x * 0.25) * 0.31847131252288818359375) + 0.5) * MetaFlamesParams[1].w;
    metaball_radius[1] = 400.0;
    metaball_influence[1] = 1.0;
    metaball_pos[2].x = ((sin(MetaFlamesParams[1].x * 0.5) * 0.31847131252288818359375) + 0.5) * MetaFlamesParams[1].z;
    metaball_pos[2].y = ((cos(MetaFlamesParams[1].x * 0.3333333432674407958984375) * 0.31847131252288818359375) + 0.5) * MetaFlamesParams[1].w;
    metaball_radius[2] = 400.0;
    metaball_influence[2] = 1.0;
    float influence = 0.0;
    vec4 fg = texture(tex, tex_coord);
    for (int i_1 = 0; i_1 < 20; i_1++)
    {
        float _199 = MetaFlamesParams[1].w - gl_FragCoord.y;
        float _211 = gl_FragCoord.x + sin((_199 / dither_amount.x) + (cos(MetaFlamesParams[1].x) * 4.0));
        float _223 = _199 + cos((_211 / dither_amount.y) + (_128 * 4.0));
        float _323 = min(1.0, ((((distance(vec2(_211, _223), metaball_pos[i_1]) + pow((distance(metaball_pos[i_1].x, _211) * MetaFlamesParams[0].x) / distance(_223, (metaball_pos[i_1].y - metaball_radius[i_1]) - (sin((_211 / MetaFlamesParams[0].y) + ((MetaFlamesParams[1].x * MetaFlamesParams[0].z) / metaball_radius[i_1])) * MetaFlamesParams[0].w)), 2.0)) + ((sin((_223 * 3.1400001049041748046875) + MetaFlamesParams[1].x) * metaball_radius[i_1]) / dither_amount.y)) + ((cos((_211 * 3.1400001049041748046875) + MetaFlamesParams[1].x) * metaball_radius[i_1]) / dither_amount.x)) / pow((fg.x * 0.89999997615814208984375) + 0.10000002384185791015625, 2.0)) / metaball_radius[i_1]);
        float _327 = 1.0 - (_323 * _323);
        influence += ((_327 * _327) * metaball_influence[i_1]);
    }
    float _342 = influence;
    float _348 = (_342 + fg.y) - fg.z;
    influence = _348;
    vec4 _370 = fg;
    _370.x = step(0.00999999977648258209228515625, _348);
    vec4 _372 = _370;
    _372.y = step(0.300000011920928955078125, _348);
    vec4 _374 = _372;
    _374.z = step(0.75, _348);
    vec4 _376 = _374;
    _376.w = 1.0;
    fg = _376;
    return _376;
}

void main()
{
    dither_amount = vec2(20.0, 40.0);
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    vec4 _37 = effect(main_tex, param, param_1);
    frag_color = _37;
}

