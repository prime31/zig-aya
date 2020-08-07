// ./sokol-shdc --input shd.glsl --output basics.h --slang glsl330:metal_macos --format sokol_impl

// reusable blocks
@block rand
float rand(vec2 co){
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
@end


@vs sprite_vs
uniform vs_params {
	vec4 TransformMatrix[2];
};

layout(location = 0) in vec2 VertPosition;
layout(location = 1) in vec2 VertTexCoord;
layout(location = 2) in vec4 VertColor;

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


@fs noise_fs
@include_block sprite_fs_main
uniform noise_fs_params {
	float time;
	float power; // 100
};

@include_block rand

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	vec4 color = texture(tex, tex_coord);
	float x = (tex_coord.x + 4) * (tex_coord.y + 4) * (sin(time) * 10);
	vec3 grain = vec3(mod((mod(x, 13) + 1) * (mod(x, 123) + 1), 0.01) - 0.005) * power;
	color.rgb += grain;

	return color;
}
@end

@program noise sprite_vs noise_fs


@fs vignette_fs
@include_block sprite_fs_main
uniform vignette_fs_params {
	float radius; // 1.25
	float power; // 1.0
};

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	vec4 color = texture(tex, tex_coord);

	vec2 dist = (tex_coord - 0.5f) * radius;
	dist.x = 1 - dot(dist, dist) * power;
	color.rgb *= dist.x;

	return color;
}
@end

@program vignette sprite_vs vignette_fs


@fs pixel_glitch_fs
@include_block sprite_fs_main
uniform pixel_glitch_fs_params {
	float vertical_size; // vertical size in pixels or each row. default 5.0
	float horizontal_offset; // horizontal shift in pixels. default 10.0
	vec2 screen_size; // screen width/height
};

float hash11(float p) {
	vec3 p3  = fract(vec3(p, p, p) * 0.1031);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    // convert vertical_size and horizontal_offset from pixels
    float pixels = screen_size.x / vertical_size;
    float offset = horizontal_offset / screen_size.y;

    // get a number between -1 and 1 to offset the row of pixels by that is dependent on the y position
    float r = hash11(floor(tex_coord.y * pixels)) * 2.0 - 1.0;
	return texture(tex, vec2(tex_coord.x + r * offset, tex_coord.y));
}
@end

@program pixel_glitch sprite_vs pixel_glitch_fs



@fs dissolve_fs
@include_block sprite_fs_main
uniform dissolve_fs_params {
	float progress; // 0 - 1 where 0 is no change to s0 and 1 will discard all of s0 where dissolve_tex.r < value
	float dissolve_threshold; // 0.04
	vec4 dissolve_threshold_color; // the color that will be used when dissolve_tex is between progress +- dissolve_threshold
};
uniform sampler2D dissolve_tex;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	float _progress = progress + dissolve_threshold;

	vec4 color = texture(tex, tex_coord);
	// get dissolve from 0 - 1 where 0 is pure white and 1 is pure black
	float dissolve_amount = 1 - texture(dissolve_tex, tex_coord).r;

	// when our dissolve.r (dissolve_amount) is less than progress we discard
	if(dissolve_amount < _progress - dissolve_threshold)
		discard;

	float tmp = abs(_progress - dissolve_threshold - dissolve_amount) / dissolve_threshold;
	float colorAmount = mix(1, 0, 1 - clamp(tmp, 0.0, 1.0));
	vec4 thresholdColor = mix(vec4(0, 0, 0, 1), dissolve_threshold_color, colorAmount);

	float b = dissolve_amount < _progress ? 1.0 : 0.0;
	return mix(color, color * thresholdColor, b);
}
@end

@program dissolve sprite_vs dissolve_fs