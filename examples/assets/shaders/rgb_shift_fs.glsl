#version 330

uniform vec4 RgbShiftParams[1];
uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    float _63 = RgbShiftParams[0].x * (1.0 / RgbShiftParams[0].z);
    float _71 = RgbShiftParams[0].x * (1.0 / RgbShiftParams[0].w);
    float _72 = tex_coord.y - _71;
    vec4 _74 = texture(tex, vec2(tex_coord.x + _63, _72));
    vec4 _88 = texture(tex, vec2(tex_coord.x, tex_coord.y + _71));
    vec4 _108 = texture(tex, vec2(tex_coord.x - _63, _72));
    return vec4(_74.x, _88.y, _108.z, ((_74.w + _88.w) + (_108.w * 0.3333333432674407958984375)) * RgbShiftParams[0].y);
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    frag_color = effect(main_tex, param, param_1);
}

