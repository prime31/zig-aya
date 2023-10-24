const zgpu = @import("zgpu");

pub const MeshLayouts = struct {
    /// The mesh model uniform (transform) and nothing else.
    model_only: zgpu.BindGroupLayoutHandle = .{},

    /// Also includes the uniform for skinning
    skinned: zgpu.BindGroupLayoutHandle = .{},

    /// Also includes the uniform and [`MorphAttributes`] for morph targets.
    /// [`MorphAttributes`]: bevy_render::mesh::morph::MorphAttributes
    morphed: zgpu.BindGroupLayoutHandle = .{},

    /// Also includes both uniforms for skinning and morph targets, also the
    /// morph target [`MorphAttributes`] binding.
    /// [`MorphAttributes`]: bevy_render::mesh::morph::MorphAttributes
    morphed_skinned: zgpu.BindGroupLayoutHandle = .{},

    pub fn init(gctx: *zgpu.GraphicsContext) MeshLayouts {
        return .{
            .model_only = gctx.createBindGroupLayout(&.{
                zgpu.bufferEntry(0, .{ .vertex = true, .fragment = true }, .uniform, true, 0),
            }),
        };
    }
};
