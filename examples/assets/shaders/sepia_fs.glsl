#version 330

uniform vec4 SepiaParams[1];
uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    vec4 _36 = texture(tex, tex_coord);
    vec3 _41 = _36.xyz;
    vec3 _61 = mix(_41, SepiaParams[0].xyz * dot(_41, vec3(0.300000011920928955078125, 0.589999973773956298828125, 0.10999999940395355224609375)), vec3(0.75));
    return vec4(_61.x, _61.y, _61.z, _36.w);
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    frag_color = effect(main_tex, param, param_1);
}

