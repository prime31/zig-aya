struct Camera {
    world_to_clip: mat4x4f,
    position: vec3f,
    time: f32,
};
@group(0) @binding(0) var<uniform> camera : Camera;

@group(1) @binding(0) var<uniform> model : mat4x4f;
@group(1) @binding(1) var image: texture_2d<f32>;
@group(1) @binding(2) var image_sampler: sampler;

struct VertexInput {
    @location(0) position: vec3f,
    @location(1) normal: vec3f,
    @location(2) uv: vec2f,
};

struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) normal: vec3f,
    @location(1) uv: vec2f,
};

@vertex
fn vs_main(input: VertexInput) -> VertexOutput {
    var output: VertexOutput;

    output.position = vec4(input.position, 1.0) * model * camera.world_to_clip;
    output.normal = input.normal * mat3x3(
        model[0].xyz,
        model[1].xyz,
        model[2].xyz,
    );
    output.uv = input.uv;

    return output;
}

// Some hardcoded lighting
const lightDir = vec3f(0.25, 0.5, 1.);
const lightColor = vec3f(1.);
const ambientColor = vec3f(0.4);

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4f {
    // An extremely simple directional lighting model, just to give our model some shape.
    let N = normalize(input.normal);
    let L = normalize(lightDir);
    let NDotL = max(dot(N, L), 0.0);
    let tex_color = textureSample(image, image_sampler, input.uv);
    let surface_color = tex_color.rgb * ambientColor + NDotL;

    return vec4f(surface_color, 1.);
}