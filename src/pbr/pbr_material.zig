const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const Handle = aya.Handle;
const Image = aya.Image;
const Color = aya.Color;
const AlphaMode = aya.AlphaMode;

const MaterialPipeline = aya.MaterialPipeline;
const RenderPipelineDescriptor = aya.RenderPipelineDescriptor;
const MeshVertexBufferLayout = aya.InnerMeshVertexBufferLayout;
const MeshPipelineKey = aya.MeshPipelineKey;
const MaterialPipelineKey = aya.MaterialPipelineKey;

pub const StandardMaterial = struct {
    /// Data that will be stored alongside the "prepared" bind group
    pub const Data = u8; // TODO: where do we use this?

    base_color: Color = Color.white,
    // #[texture(1)]
    // #[sampler(2)]
    // #[dependency]
    base_color_texture: ?Handle(Image) = null,
    emissive: Color = Color.black,
    // #[texture(3)]
    // #[sampler(4)]
    // #[dependency]
    emissive_texture: ?Handle(Image) = null,
    perceptual_roughness: f32 = 0.5,
    metallic: f32 = 0,
    // #[texture(5)]
    // #[sampler(6)]
    // #[dependency]
    metallic_roughness_texture: ?Handle(Image) = null,
    reflectance: f32 = 0.5,
    // #[texture(9)]
    // #[sampler(10)]
    // #[dependency]
    normal_map_texture: ?Handle(Image) = null,
    /// Normal map textures authored for DirectX have their y-component flipped. Set this to flip
    /// it to right-handed conventions.
    flip_normal_map_y: bool = false,
    // #[texture(7)]
    // #[sampler(8)]
    // #[dependency]
    occlusion_texture: ?Handle(Image) = null,
    double_sided: bool = false,
    cull_mode: wgpu.CullMode = .none,
    unlit: bool = false,
    fog_enabled: bool = true,
    alpha_mode: AlphaMode = .opaque_,
    depth_bias: f32 = 0,
    // depth_map: ?Handle(Image) = null,
    // parallax_depth_scale: f32 = 0.1,
    // parallax_mapping_method: ParallaxMappingMethod,
    // max_parallax_layer_count: f32 = 16,
    // opaque_render_method: OpaqueRendererMethod,
    // deferred_lighting_pass_id: u8 = 1,

    pub fn specialize(
        _: MaterialPipeline(StandardMaterial),
        _: *RenderPipelineDescriptor,
        _: *MeshVertexBufferLayout,
        _: MaterialPipelineKey(StandardMaterial),
    ) !void {}
};
