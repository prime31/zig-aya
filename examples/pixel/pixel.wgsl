struct Camera {
    world_to_clip: mat4x4f,
    position: vec3f,
    uv_type: i32,
};

struct VertexInput {
    @location(0) position: vec3f,
    @location(1) uv: vec2f,
};

struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) uv: vec2f,
};

@group(0) @binding(0) var<uniform> camera : Camera;

@group(1) @binding(0) var<uniform> model : mat4x4f;
@group(1) @binding(1) var image: texture_2d<f32>;
@group(1) @binding(2) var image_sampler: sampler;

@vertex
fn vs_main(input: VertexInput) -> VertexOutput {
    let pos = vec4(input.position, 1.0) * model * camera.world_to_clip;
    return VertexOutput(pos, input.uv);
}

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4f {
    let texture_size = vec2f(textureDimensions(image));

    var uv = input.uv;
    if camera.uv_type == 1 {
        uv = uv_iq(input.uv, texture_size);
    } else if camera.uv_type == 2 {
        uv = uv_cstantos(input.uv, texture_size);
    }

    let color = textureSample(image, image_sampler, uv);
    if color.a == 0.0 { discard; }
    return color;
}

fn uv_iq(uv: vec2<f32>, texture_size: vec2<f32>) -> vec2<f32> {
    var pixel: vec2<f32> = uv * texture_size;
    let seam: vec2<f32> = floor(pixel + 0.5);
    let dudv: vec2<f32> = fwidth(pixel);
    pixel = seam + clamp((pixel - seam) / dudv, vec2f(-0.5), vec2f(0.5));
    return pixel / texture_size;
}

fn uv_cstantos(uv: vec2<f32>, res: vec2<f32>) -> vec2<f32> {
    var pixels: vec2<f32> = uv * res;
    let alpha: vec2<f32> = 0.7 * fwidth(pixels);
    let pixels_fract: vec2<f32> = fract(pixels);
    let pixels_diff: vec2<f32> = clamp(0.5 / alpha * pixels_fract, vec2f(0.0), vec2f(0.5)) + clamp(0.5 / alpha * (pixels_fract - 1.0) + 0.5, vec2f(0.0), vec2f(0.5));
    pixels = floor(pixels) + pixels_diff;
    return pixels / res;
}