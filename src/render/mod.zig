const std = @import("std");
const aya = @import("../aya.zig");

pub usingnamespace @import("graphics_context.zig");
pub usingnamespace @import("render_context.zig");
pub usingnamespace @import("basic_renderer.zig");
// pub usingnamespace @import("render_layers.zig");
pub usingnamespace @import("graphics_context.zig");
pub usingnamespace @import("batcher.zig");
// pub usingnamespace @import("triangle_batcher.zig");
pub usingnamespace @import("fontbook.zig");
pub usingnamespace @import("mesh.zig");
pub usingnamespace @import("draw.zig");

pub const gpu = @import("gpu.zig");

pub const Vertex = extern struct {
    pos: aya.math.Vec2 = .{},
    uv: aya.math.Vec2 = .{},
    col: u32 = 0xFFFFFFFF,
};

// GPU handles and info objects
const pools = @import("resource_pools.zig");

pub const BufferHandle = pools.BufferHandle;
pub const TextureHandle = pools.TextureHandle;
pub const TextureViewHandle = pools.TextureViewHandle;
pub const SamplerHandle = pools.SamplerHandle;
pub const RenderPipelineHandle = pools.RenderPipelineHandle;
pub const ComputePipelineHandle = pools.ComputePipelineHandle;
pub const BindGroupHandle = pools.BindGroupHandle;
pub const BindGroupLayoutHandle = pools.BindGroupLayoutHandle;
pub const PipelineLayoutHandle = pools.PipelineLayoutHandle;

pub const BufferInfo = pools.BufferInfo;
pub const TextureInfo = pools.TextureInfo;
pub const TextureViewInfo = pools.TextureViewInfo;
pub const SamplerInfo = pools.SamplerInfo;
pub const RenderPipelineInfo = pools.RenderPipelineInfo;
pub const ComputePipelineInfo = pools.ComputePipelineInfo;
pub const BindGroupEntryInfo = pools.BindGroupEntryInfo;
pub const BindGroupInfo = pools.BindGroupInfo;
pub const BindGroupLayoutInfo = pools.BindGroupLayoutInfo;
pub const PipelineLayoutInfo = pools.PipelineLayoutInfo;
