#version 330

uniform vec4 LinesParams[2];
uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    return mix(vec4(0.0), LinesParams[0], vec4(mod(floor(gl_FragCoord.y / LinesParams[1].x), 2.0))) * texture(tex, tex_coord).w;
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    frag_color = effect(main_tex, param, param_1);
}

