#version 330

uniform vec4 VignetteParams[1];
uniform sampler2D main_tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color)
{
    vec4 _36 = texture(tex, tex_coord);
    vec2 _50 = (tex_coord - vec2(0.5)) * VignetteParams[0].x;
    vec3 _69 = _36.xyz * (1.0 - (dot(_50, _50) * VignetteParams[0].y));
    return vec4(_69.x, _69.y, _69.z, _36.w);
}

void main()
{
    vec2 param = uv_out;
    vec4 param_1 = color_out;
    frag_color = effect(main_tex, param, param_1);
}

