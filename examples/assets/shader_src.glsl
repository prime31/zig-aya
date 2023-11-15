@ctype vec2 Vec2
@ctype vec3 Vec3
@ctype mat4 Mat4

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
	mat3x2 trans_mat = mat3x2(transform_matrix[0].x, transform_matrix[0].y, transform_matrix[0].z, transform_matrix[0].w, transform_matrix[1].x, transform_matrix[1].y);

	gl_Position = vec4(trans_mat * vec3(pos_in, 1), 0, 1);
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
uniform PixelGlitchParams {
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


// source: https://blog.seans.site/post/154285665406/a-hot-shader
@fs meta_flames_fs
@include_block sprite_fs_main
uniform MetaFlamesParams {
	float tear_sharpness; // 7
	float tear_wave_length; // 5
	float tear_wave_speed; // 500
	float tear_wave_amplitude; // 10
	float time;
	vec2 screen_size;
};

vec2 dither_amount = vec2(20.0, 40.0);

vec2 metaball_pos[20];
float metaball_radius[20];
float metaball_influence[20];

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    for (int i = 0; i < 20; i += 1) {
        float f = float(i);
 		metaball_pos[i].x = (sin(time * 1000.0 / (500.0 + f * 200.0 + mod(f, 6.0) * 500.0)) / (3.14) + 0.5) * screen_size.x,
		metaball_pos[i].y = (cos(time * 1000.0 / (500.0 + f * 200.0 - mod(f, 5.0) * 500.0)) / (3.14) + 0.5) * screen_size.y,
		metaball_radius[i] = 150.0;
		metaball_influence[i] = 0.5;
	}

    metaball_pos[1].x = (sin(time) / 3.14 + 0.5) * screen_size.x;
    metaball_pos[1].y = (cos(time / 4.0) / 3.14 + 0.5) * screen_size.y;
    metaball_radius[1] = 400.0;
    metaball_influence[1] = 1.0;
    metaball_pos[2].x = (sin(time / 2.0) / 3.14 + 0.5) * screen_size.x;
    metaball_pos[2].y = (cos(time / 3.0) / 3.14 + 0.5) * screen_size.y;
    metaball_radius[2] = 400.0;
    metaball_influence[2] = 1.0;

	float influence = 0.0;

	// get current pixel
	vec4 fg = texture(tex, tex_coord);

    // calculate total influence
	for (int i = 0; i < 20; ++i) {
		// convert UVs to pixel coordinates
		float x = gl_FragCoord.x;
		float y = screen_size.y - gl_FragCoord.y;

		// flame wave
		x += sin(y / dither_amount.x + cos(time) * 4.0);
		y += cos(x / dither_amount.y + sin(time) * 4.0);

 		// start off with distance between pixel and metaball
		float d = distance(vec2(x, y), metaball_pos[i].xy);

		// pick a point above metaball
		float tear_offset = metaball_pos[i].y - metaball_radius[i];

		// animate tear offset
		tear_offset -= (sin(x / tear_wave_length + time * tear_wave_speed / metaball_radius[i]) * tear_wave_amplitude);

        // apply tear shape
		d += pow(distance(metaball_pos[i].x, x) * tear_sharpness / distance(y, tear_offset), 2.0);

		// dither
		d += sin(y * 3.14 + time) * metaball_radius[i] / dither_amount.y;
		d += cos(x * 3.14 + time) * metaball_radius[i] / dither_amount.x;

		// diffuse
		float depth = 0.9;
		d /= pow(fg.r * depth + (1.0 - depth), 2.0);

		// divide by radius and keep within range (0.0, 1.0)
		d = min(1.0, d / metaball_radius[i]);

		// smooth falloff
		d = (1.0 - d * d);
		d *= d;

        // add to total (with multiplier)
		influence += d * metaball_influence[i];
	}

	// ambient
	influence += fg.g;
	influence -= fg.b;

	// convert influence to RGB
	fg.r = step(0.01, influence);
	fg.g = step(0.3, influence);
	fg.b = step(0.75, influence);
	fg.a = 1.0;

	return fg;
}
@end

@program meta_flames sprite_vs meta_flames_fs



@vs instanced_vs
uniform InstancedVertParams {
	vec4 transform_matrix[2];
};

layout(location = 0) in vec2 pos_in;
layout(location = 1) in vec2 uv_in;
layout(location = 2) in vec4 color_in;
layout(location = 3) in vec2 instance_pos_in;

out vec2 uv_out;
out vec4 color_out;

void main() {
	uv_out = uv_in;
	color_out = color_in;

	mat3x2 trans_mat = mat3x2(transform_matrix[0].x, transform_matrix[0].y, transform_matrix[0].z, transform_matrix[0].w, transform_matrix[1].x, transform_matrix[1].y);
	gl_Position = vec4(trans_mat * vec3(pos_in + instance_pos_in, 1), 0, 1);
}
@end

@fs instanced_fs
@include_block sprite_fs_main
vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	return texture(tex, tex_coord) * vert_color;
}
@end

@program instanced instanced_vs instanced_fs



@vs cube_vs
uniform CubeParamsVS {
	mat4 mvp;
};

layout(location = 0) in vec4 pos;
layout(location = 1) in vec4 color0;
layout(location = 2) in vec2 texcoord0;

out vec4 color;
out vec2 uv;

void main() {
    gl_Position = mvp * pos;
    color = color0;
    uv = texcoord0;
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






@fs depth_fs
uniform DepthParamsFS {
	float near;
	float far;
};

in vec2 uv_out;
in vec4 color_out;
out vec4 frag_color;

float linearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0; // back to NDC
    return (2.0 * near * far) / (far + near - z * (far - near));
}

void main() {
	float depth = linearizeDepth(gl_FragCoord.z) / far; // divide by far for demonstration
    frag_color = vec4(vec3(depth), 1.0);
}
@end

@program depth sprite_vs depth_fs



@fs mrt_fs
@include_block sprite_fs_main

layout(location = 1) out vec4 frag_color2;

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	vec4 color = texture(tex, tex_coord);

	// convert to greyscale and output to 2nd textures
	float gray_scale = dot(color.rgb, vec3(0.3, 0.59, 0.11));
	frag_color2 = vec4(gray_scale, gray_scale, gray_scale, 1.0) * color.a;

	return color;
}
@end

@program mrt sprite_vs mrt_fs



@vs deferred_vs
uniform DeferredVertexParams {
	vec4 transform_matrix[2];
};

layout(location = 0) in vec2 pos_in;
layout(location = 1) in vec2 uv_in;
layout(location = 2) in vec2 normal_in;

out vec2 uv_out;
out vec2 normal_out;

void main() {
	uv_out = uv_in;
	normal_out = normal_in;
	mat3x2 trans_mat = mat3x2(transform_matrix[0].x, transform_matrix[0].y, transform_matrix[0].z, transform_matrix[0].w, transform_matrix[1].x, transform_matrix[1].y);

	gl_Position = vec4(trans_mat * vec3(pos_in, 1), 0, 1);
}
@end


@fs deferred_fs
uniform sampler2D main_tex;

in vec2 uv_out;
in vec2 normal_out;
out vec4 frag_color;

void main() {
	// pack the normals
	vec2 normals = (normal_out + vec2(1.0)) / 2.0;
	frag_color.rg = texture(main_tex, uv_out).a * normals;
	frag_color.b = texture(main_tex, uv_out).a * 1; // b channel is used for normal_falloff in light shaders
	frag_color.a = texture(main_tex, uv_out).a;
}
@end

@program deferred deferred_vs deferred_fs


@fs deferred_point_fs
@include_block sprite_fs_main
uniform DeferredPointParams {
	vec2 resolution;
	vec4 color;
	float intensity; // 0 - 1
	float falloff; // 0 - 1
	// float angular_falloff; // 0 - 1
	float volumetric_intensity; // 0 - 1
};

uniform sampler2D normals_tex;

// maps a value from some arbitrary range to the 0 to 1 range
float map01(float value, float min, float max) {
	return (value - min) * 1 / (max - min);
}

// maps value (which is in the range leftMin - leftMax) to a value in the range rightMin - rightMax
float map(float value, float leftMin, float leftMax, float rightMin, float rightMax) {
	return rightMin + (value - leftMin) * (rightMax - rightMin) / (leftMax - leftMin);
}

vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
	vec4 base_color = texture(tex, tex_coord);
	vec4 normal_color = texture(normals_tex, tex_coord);

	// TODO: add to uniform
	float min_angle = radians(0.0) / 3.141592;
	float max_angle = radians(45.0) / 3.141592;

	float angle = atan(tex_coord.t - 0.5, tex_coord.s - 0.5) + radians(180.0);
	angle /= 2 * 3.141592;
	if (angle > radians(0.0) / (2 * 3.141592) && angle < radians(45.0) / (2 * 3.141592)) return vec4(1.0, 0, 0, 1);
	// if (angle > radians(90.0) && angle < radians(100.0)) return vec4(1.0, 0, 0, 1);
	//angle = mod(angle + 3.141592, 3.141592);
	//angle = atan(0.5 - tex_coord.t, 0.5 - tex_coord.s);
	// return vec4(0, angle, 0, 1);
	float blur = 0.1;
	// return vec4(1, 0, 1, 1) * (1 - smoothstep(max_angle, max_angle + blur, angle));
	// return vec4(1, 0, 1, 1) * smoothstep(min_angle + blur, min_angle, angle);
	return vec4(1, 0, 1, 1) * (1 - smoothstep(min_angle, max_angle, angle)) * smoothstep(max_angle, min_angle, angle);

	// vec2 st = gl_FragCoord.xy / resolution;


	// TODO: calc using center of light and fragments coordinate in local space
	float distance = distance(vec2(0.5), tex_coord) * 2.0; // center to extent of quad is max of 0.5 but we want 0-1

	float radial_falloff = pow(1.0 - distance, 2.0);
	float angular_falloff = smoothstep(min_angle, max_angle, angle);

	// return  vec4(1, 1, 0, 1);
	return /*radial_falloff * */ angular_falloff * vec4(1, 0, 0.5, 1);

	// vec2 normal_vector = normalize(world_space_pos_center_of_light - world_space_frag_pos)
	// vec2 dir_to_light = ?
	vec2 light_vector = normalize(tex_coord - vec2(0.5));
	// light_vector /= length(light_vector);

    // tranform normal back into [-1,1] range
    vec2 normal = 2.0 * normal_color.xy - 1.0;
	float normal_falloff = clamp(dot(light_vector, normal), 0, 1) * normal_color.b;


	float final_intensity = intensity * radial_falloff * angular_falloff * normal_falloff;
	vec3 light_color = final_intensity * color.rgb;
	vec3 shaded_color = base_color.rgb * light_color.rgb;
	shaded_color += light_color * volumetric_intensity;

	return vec4(shaded_color, 1) * normal_color;
}
@end

@program deferred_point sprite_vs deferred_point_fs