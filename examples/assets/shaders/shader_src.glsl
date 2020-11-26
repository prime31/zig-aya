@ctype vec2 math.Vec2
@ctype vec3 math.Vec3

// reusable blocks
@block rand
float rand(vec2 co){
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}
@end


@vs sprite_vs
uniform VertexParams {
	vec4 transform_matrix[2];
};

layout(location = 0) in vec2 pos_in;
layout(location = 1) in vec2 uv_in;
layout(location = 2) in vec4 color_in;

out vec2 uv_out;
out vec4 color_out;

void main() {
	uv_out = uv_in;
	color_out = color_in;
	mat3x2 transMat = mat3x2(transform_matrix[0].x, transform_matrix[0].y, transform_matrix[0].z, transform_matrix[0].w, transform_matrix[1].x, transform_matrix[1].y);

	gl_Position = vec4(transMat * vec3(pos_in, 1), 0, 1);
}
@end


@block sprite_fs_main
uniform sampler2D main_tex;

in vec2 uv_out;
in vec4 color_out;
out vec4 frag_color;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color);

void main() {
	frag_color = effect(main_tex, uv_out.st, color_out);
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
uniform SepiaParams {
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
uniform LinesParams {
	vec4 line_color;
	float line_size; // width of the line in pixels
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
uniform NoiseParams {
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
uniform VignetteParams {
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
uniform pixelGlitchParams {
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
uniform DissolveParams {
	float progress; // 0 - 1 where 0 is no change to s0 and 1 will discard all of s0 where dissolve_tex.r < value
	float threshold; // 0.04
	vec4 threshold_color; // the color that will be used when dissolve_tex is between progress +- threshold
};
uniform sampler2D dissolve_tex;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	float _progress = progress + threshold;

	vec4 color = texture(tex, tex_coord);
	// get dissolve from 0 - 1 where 0 is pure white and 1 is pure black
	float dissolve_amount = 1 - texture(dissolve_tex, tex_coord).r;

	// when our dissolve.r (dissolve_amount) is less than progress we discard
	if(dissolve_amount < _progress - threshold)
		discard;

	float tmp = abs(_progress - threshold - dissolve_amount) / threshold;
	float colorAmount = mix(1, 0, 1 - clamp(tmp, 0.0, 1.0));
	vec4 thresholdColor = mix(vec4(0, 0, 0, 1), threshold_color, colorAmount);

	float b = dissolve_amount < _progress ? 1.0 : 0.0;
	return mix(color, color * thresholdColor, b);
}
@end

@program dissolve sprite_vs dissolve_fs



@fs rgb_shift_fs
@include_block sprite_fs_main
uniform RgbShiftParams {
	float shift; // 0-1 range (clamp(0, p * p * p, 1) where p is sound pitch normalized to 0-1)
	float alpha; // (1 - p) * 40 + 2
	vec2 screen_size; // screen width/height
};

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	vec2 tc = tex_coord;
	vec2 scale = vec2(1.0 / screen_size.x, 1.0 / screen_size.y);

	vec4 r = texture(tex, vec2(tc.x + shift * scale.x, tc.y - shift * scale.y));
	vec4 g = texture(tex, vec2(tc.x, tc.y + shift * scale.y));
	vec4 b = texture(tex, vec2(tc.x - shift * scale.x, tc.y - shift * scale.y));
	float a = r.a + g.a + b.a / 3.0;

	return vec4(r.r, g.g, b.b, a * alpha);
}
@end

@program rgb_shift sprite_vs rgb_shift_fs


@fs mode7_fs
@include_block sprite_fs_main
uniform Mode7Params {
	float mapw;
	float maph;
	float x;
	float y;
	float zoom;
	float fov;
	float offset;
	float wrap;
	float x1, x2, y1, y2;
};
uniform sampler2D map_tex;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	mat2 rotation = mat2(x1, y1, x2, y2);
	vec2 uv = vec2(
		(0.5 - tex_coord.x) * zoom,
		(offset - tex_coord.y) * (zoom / fov)
	) * rotation;
	vec2 uv2 = vec2(
		(uv.x / tex_coord.y + x) / mapw,
		(uv.y / tex_coord.y + y) / maph
	);

	if (wrap == 0 && (uv2.x < 0.0 || uv2.x > 1.0 || uv2.y < 0.0 || uv2.y > 1.0)) {
		return vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		return (texture(map_tex, mod(uv2, 1.0) ) * vert_color);
	}
}
@end

@program mode7 sprite_vs mode7_fs