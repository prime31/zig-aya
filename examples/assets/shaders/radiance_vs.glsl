#version 330

uniform vec4 VertexParams[2];

layout(location = 1) in vec2 uv_in;
layout(location = 2) in vec4 color_in;
layout(location = 0) in vec2 pos_in;

out vec2 uv_out;
out vec4 color_out;
out vec2 fuv;

void main() {
    uv_out = uv_in;
    color_out = color_in;
    gl_Position = vec4(mat3x2(vec2(VertexParams[0].x, VertexParams[0].y), vec2(VertexParams[0].z, VertexParams[0].w), vec2(VertexParams[1].x, VertexParams[1].y)) * vec3(pos_in, 1.0), 0.0, 1.0);

    vec2[] positions = vec2[](
        vec2(-1,-1),
        vec2(1,-1),
        vec2(1,1),
        vec2(-1,-1),
        vec2(1,1),
        vec2(-1,1)
    );
    vec2 vpos = positions[gl_VertexID % 6];
    fuv = vpos * 0.5 + 0.5;
    fuv.y = 1 - fuv.y;
}

