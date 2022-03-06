#version 330

uniform sampler2D tex;

layout(location = 0) out vec4 frag_color;
in vec2 uv;
in vec4 color;

void main()
{
    frag_color = texture(tex, uv) * color;
}

