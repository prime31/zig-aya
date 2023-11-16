#version 330

uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    if (texture(tex, tex_coord).w < 0.100000001490116119384765625)
    {
        discard;
    }
    return texture(tex, tex_coord) * vert_color;
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    vec4 _32 = effect(main_tex, param, param_1);
    frag_color = _32;
}

