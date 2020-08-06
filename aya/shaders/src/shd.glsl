// ./sokol-shdc --input shd.glsl --output basics.h --slang glsl330:metal_macos --format sokol_impl

@vs sprite_vs
uniform vs_params {
	vec4 TransformMatrix[2];
};

in vec2 VertPosition;
in vec2 VertTexCoord;
in vec4 VertColor;

out vec2 VaryingTexCoord;
out vec4 VaryingColor;

void main() {
	VaryingTexCoord = VertTexCoord;
	VaryingColor = VertColor;
	mat3x2 transMat = mat3x2(TransformMatrix[0].x, TransformMatrix[0].y, TransformMatrix[0].z, TransformMatrix[0].w, TransformMatrix[1].x, TransformMatrix[1].y);

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
uniform sepia_fs_params {
	vec3 sepia_tone; // vec3(1.2, 1.0, 0.8)
};

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	vec4 color = texture(tex, tex_coord);

	// convert to greyscale then tint
	float gray_scale = dot(color.rgb, vec3(0.3, 0.59, 0.11));
	color.rgb = mix(color.rgb, gray_scale * sepia_tone, 0.75);

	return color;
}
@end

@program sepia sprite_vs sepia_fs


@fs lines_fs
@include_block sprite_fs_main
uniform lines_fs_params {
	float line_size; // width of the line in pixels
	vec4 line_color;
};

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	// we only need the alpha value of the original texture
	float alpha = texture(tex, tex_coord).a;

	vec2 screen_size = vec2(1024.0, 768.0);
	vec2 screen_pos = gl_FragCoord.xy; // / screen_size; // vec2(gl_FragCoord.x, (gl_FragCoord.y * screen_size.x) + screen_size.y);

	// floor the screenPosition / line_size. This gives us blocks with height line_size. We mod that by 2 to take only the even blocks
	float flooredAlternate = mod(floor(screen_pos.y / line_size), 2.0);

	// lerp transparent to lineColor. This will always be either transparent or lineColor since flooredAlternate will be 0 or 1.
	vec4 finalColor = mix(vec4(0, 0, 0, 0), line_color, flooredAlternate);
	return finalColor *= alpha;
}
@end

@program lines sprite_vs lines_fs


//#define via_PixelCoord (vec2(gl_FragCoord.x, (gl_FragCoord.y * via_ScreenSize.z) + via_ScreenSize.w))