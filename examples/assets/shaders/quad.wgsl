struct VertexOut {
    @builtin(position) position: vec4f,
    @location(0) uv: vec2f,
    @location(1) color: vec4f,
};

@vertex
fn vs_main(@location(0) position: vec4f, @location(1) uv: vec2f, @location(2) color: vec4f) -> VertexOut {
    return VertexOut(position, uv, color);
}

@group(0) @binding(0) var image: texture_2d<f32>;
@group(0) @binding(1) var image_sampler: sampler;

@fragment
fn fs_main(@location(0) uv: vec2f, @location(1) color: vec4f) -> @location(0) vec4f {
    return textureSample(image, image_sampler, uv) * color;
}