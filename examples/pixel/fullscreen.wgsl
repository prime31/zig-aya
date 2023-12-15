struct VertexOut {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
};

@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VertexOut {
    let uv = vec2<f32>(f32(vertex_index >> 1u), f32(vertex_index & 1u)) * 2.0;
    let clip_position = vec4<f32>(uv * vec2<f32>(2.0, -2.0) + vec2<f32>(-1.0, 1.0), 0.0, 1.0);

    return VertexOut(clip_position, uv);
}

@group(0) @binding(0) var image: texture_2d<f32>;
@group(0) @binding(1) var image_sampler: sampler;

@fragment
fn fs_main(in: VertexOut) -> @location(0) vec4<f32> {
    let texture_size = vec2f(textureDimensions(image));
    var uv = in.uv;

    uv = uv_iq(in.uv, texture_size);
    // uv = uv_cstantos(in.uv, texture_size);

    return textureSample(image, image_sampler, uv);
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