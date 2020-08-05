// ./sokol-shdc --input shd.glsl --output basics.h --slang glsl330:metal_macos --format sokol_impl

@vs sprite_vs
uniform vs_params {
	vec2 TransformMatrix[3];
};

in vec2 VertPosition;
in vec2 VertTexCoord;
in vec4 VertColor;

out vec2 VaryingTexCoord;
out vec4 VaryingColor;

void main() {
	VaryingTexCoord = VertTexCoord;
	VaryingColor = VertColor;
	mat3x2 transMat = mat3x2(TransformMatrix[0].x, TransformMatrix[0].y, TransformMatrix[1].x, TransformMatrix[1].y, TransformMatrix[2].x, TransformMatrix[2].y);

	// 0.0031, -0.0000, -0.0000, -0.0042, -1.0000, 1.0000
	// transMat[0] = vec2(0.003125, -0.000);
	// transMat[1] = vec2(-0.000, -0.004167);
	// transMat[2] = vec2(-1.000, 1.000);
	gl_Position = vec4(transMat * vec3(VertPosition, 1), 0, 1);
}
@end


@block sprite_fs_main
uniform sampler2D MainTex;

in vec2 VaryingTexCoord;
in vec4 VaryingColor;
out vec4 frag_color;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color);

void main() {
	frag_color = effect(MainTex, VaryingTexCoord.st, VaryingColor);
}
@end


@fs sprite_fs
@include_block sprite_fs_main
vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	return texture(tex, tex_coord) * vert_color;
}
@end

@program sprite sprite_vs sprite_fs



@fs sepia_fs
@include_block sprite_fs_main
uniform vec3 sepia_tone = vec3(1.2, 1.0, 0.8);

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	vec4 color = texture(tex, tex_coord);

	// first we need to convert to greyscale
	float gray_scale = dot(color.rgb, vec3(0.3, 0.59, 0.11));
	color.rgb = mix(color.rgb, gray_scale * sepia_tone, 0.75);

	return color;
}
@end

@program sepia sprite_vs sepia_fs
