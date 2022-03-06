#version 330

uniform vec4 CubeParamsVS[4];
layout(location = 0) in vec4 pos;
out vec4 color;
layout(location = 1) in vec4 color0;
out vec2 uv;
layout(location = 2) in vec2 texcoord0;

void main()
{
    gl_Position = mat4(CubeParamsVS[0], CubeParamsVS[1], CubeParamsVS[2], CubeParamsVS[3]) * pos;
    color = color0;
    uv = texcoord0;
}

