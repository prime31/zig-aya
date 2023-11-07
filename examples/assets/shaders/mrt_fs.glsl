#version 330

uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;
layout(location = 1) out vec4 frag_color2;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    vec4 _36 = texture(tex, tex_coord);
    float _46 = dot(_36.xyz, vec3(0.300000011920928955078125, 0.589999973773956298828125, 0.10999999940395355224609375));
    frag_color2 = vec4(_46, _46, _46, 1.0) * _36.w;
    return _36;
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    vec4 _32 = effect(main_tex, param, param_1);
    frag_color = _32;
}

