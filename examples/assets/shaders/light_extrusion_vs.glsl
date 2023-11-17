#version 330

uniform vec4 params[2]; // vec2 light_pos is last 2 elements of the array

layout(location = 0) in vec2 pos_in;
layout(location = 1) in vec2 normal_in;

void main() {
    vec2 light_pos = params[1].zw;
	vec2 light_dir = normalize(light_pos - pos_in);
	vec2 position = pos_in;

	// if the vert normal is facing away from the light, it will be negative
	if (dot(light_dir, normal_in) < 0) {
		position = pos_in + light_dir * 100;
	}

    mat3x2 trans_mat = mat3x2(vec2(params[0].x, params[0].y), vec2(params[0].z, params[0].w), vec2(params[1].x, params[1].y));
	gl_Position = vec4(trans_mat * vec3(position, 1.0), 0.0, 1.0);
}

