// ./sokol-shdc --input shd.glsl --output basics.h --slang glsl330:metal_macos --format sokol_impl


@vs cube_vs
uniform cube_vs_params {
	mat4 mvp;
};

in vec4 pos;
in vec4 color0;
in vec2 texcoord0;

out vec4 color;
out vec2 uv;

void main() {
    gl_Position = mvp * pos;
    color = color0;
    uv = texcoord0; // * 5.0; // repeat the texture since this is a tester for a checkboard
}
@end


@fs cube_fs
uniform sampler2D tex;

in vec4 color;
in vec2 uv;
out vec4 frag_color;

void main() {
    frag_color = texture(tex, uv) * color;
}
@end

@program cube cube_vs cube_fs
