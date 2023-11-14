#version 330

uniform sampler2D main_tex;

in vec2 normal_out;
layout(location = 0) out vec4 frag_color;
in vec2 uv_out;

void main()
{
    vec2 _35 = ((normal_out + vec2(1.0)) * vec2(0.5)) * texture(main_tex, uv_out).w;
    frag_color = vec4(_35.x, _35.y, frag_color.z, frag_color.w);
    frag_color.z = texture(main_tex, uv_out).w;
}

