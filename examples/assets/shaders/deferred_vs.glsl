#version 330

uniform vec4 DeferredVertexParams[2];
out vec2 uv_out;
layout(location = 1) in vec2 uv_in;
out vec2 normal_out;
layout(location = 2) in vec2 normal_in;
layout(location = 0) in vec2 pos_in;

void main()
{
    uv_out = uv_in;
    normal_out = normal_in;
    gl_Position = vec4(mat3x2(vec2(DeferredVertexParams[0].x, DeferredVertexParams[0].y), vec2(DeferredVertexParams[0].z, DeferredVertexParams[0].w), vec2(DeferredVertexParams[1].x, DeferredVertexParams[1].y)) * vec3(pos_in, 1.0), 0.0, 1.0);
}

