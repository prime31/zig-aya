const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

pub const GpuImage = struct {
    texture: *wgpu.Texture,
    texture_view: zgpu.TextureViewHandle,
    texture_format: wgpu.Texture.Format,
    sampler: zgpu.SamplerHandle,
    size: @Vector(2, f32),
    mip_level_count: u32,
};
