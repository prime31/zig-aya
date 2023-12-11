struct Camera {
    projection : mat4x4f,
    view : mat4x4f,
    position : vec3f,
    time : f32,
};
@group(0) @binding(0) var<uniform> camera : Camera;
@group(1) @binding(0) var<uniform> model : mat4x4f;

struct VertexInput {
    @location(0) position : vec3f,
    @location(1) normal : vec3f,
};

struct VertexOutput {
    @builtin(position) position : vec4f,
    @location(0) normal : vec3f,
};

@vertex
fn vs_main(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    output.position = camera.projection * camera.view * model * vec4f(input.position, 1.);
    output.normal = normalize((camera.view * model * vec4f(input.normal, 0.)).xyz);

    return output;
}

// Some hardcoded lighting
const lightDir = vec3f(0.25, 0.5, 1.);
const lightColor = vec3f(1.);
const ambientColor = vec3f(0.1);

@fragment
fn fs_main(input : VertexOutput) -> @location(0) vec4f {
    // An extremely simple directional lighting model, just to give our model some shape.
    let N = normalize(input.normal);
    let L = normalize(lightDir);
    let NDotL = max(dot(N, L), 0.0);
    let surfaceColor = ambientColor + NDotL;

    return vec4f(surfaceColor, 1.);
}