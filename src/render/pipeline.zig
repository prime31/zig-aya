const std = @import("std");
const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const Handle = aya.Handle;
const Shader = aya.Shader;
const ShaderDefVal = aya.ShaderDefVal;

pub const RenderPipelineDescriptor = struct {
    /// Debug label of the pipeline. This will show up in graphics debuggers for easy identification.
    label: ?[]const u8,
    /// The layout of bind groups for this pipeline.
    layout: std.ArrayList(zgpu.BindGroupLayoutHandle),
    /// The push constant ranges for this pipeline.
    /// Supply an empty vector if the pipeline doesn't use push constants.
    // push_constant_ranges: std.ArrayList(PushConstantRange),
    /// The compiled vertex stage, its entry point, and the input buffers layout.
    vertex: VertexState,
    /// The properties of the pipeline at the primitive assembly and rasterization level.
    primitive: wgpu.PrimitiveState,
    /// The effect of draw calls on the depth and stencil aspects of the output target, if any.
    depth_stencil: ?wgpu.DepthStencilState,
    /// The multi-sampling properties of the pipeline.
    multisample: wgpu.MultisampleState,
    /// The compiled fragment stage, its entry point, and the color targets.
    fragment: ?wgpu.FragmentState,
};

pub const VertexState = struct {
    /// The compiled shader module for this stage.
    shader: Handle(Shader),
    shader_defs: std.ArrayList(ShaderDefVal),
    /// The name of the entry point in the compiled shader. There must be a
    /// function with this name in the shader.
    entry_point: []const u8,
    /// The format of any vertex buffers used with this pipeline.
    buffers: std.ArrayList(wgpu.VertexBufferLayout),
};
