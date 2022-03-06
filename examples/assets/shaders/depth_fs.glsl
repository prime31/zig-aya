#version 330

uniform vec4 DepthParamsFS[1];
layout(location = 0) out vec4 frag_color;
in vec2 uv_out;
in vec4 color_out;

float linearizeDepth(float depth)
{
    return ((2.0 * DepthParamsFS[0].x) * DepthParamsFS[0].y) / ((DepthParamsFS[0].y + DepthParamsFS[0].x) - (((depth * 2.0) - 1.0) * (DepthParamsFS[0].y - DepthParamsFS[0].x)));
}

void main()
{
    float param = gl_FragCoord.z;
    float _61 = linearizeDepth(param) / DepthParamsFS[0].y;
    frag_color = vec4(_61, _61, _61, 1.0);
}

