#version 330

uniform vec4 NoiseParams[1];
uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    vec4 _36 = texture(tex, tex_coord);
    float _61 = ((tex_coord.x + 4.0) * (tex_coord.y + 4.0)) * (sin(NoiseParams[0].x) * 10.0);
    vec3 _87 = _36.xyz + (vec3(mod((mod(_61, 13.0) + 1.0) * (mod(_61, 123.0) + 1.0), 0.00999999977648258209228515625) - 0.004999999888241291046142578125) * NoiseParams[0].y);
    return vec4(_87.x, _87.y, _87.z, _36.w);
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    frag_color = effect(main_tex, param, param_1);
}

