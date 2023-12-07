const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

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

const GpuObject = union(enum) {
    buffer: BufferHandle,
    texture: TextureHandle,
    texture_view: TextureViewHandle,
    sampler: SamplerHandle,
    render_pipeline: RenderPipelineHandle,
    compute_pipeline: ComputePipelineHandle,
    bind_group: BindGroupHandle,
    bind_group_layout: BindGroupLayoutHandle,
    pipeline_layout: PipelineLayoutHandle,
};

pub const DeletionQueue = struct {
    queue: std.ArrayList(GpuObject),

    pub fn init() DeletionQueue {
        return .{ .queue = std.ArrayList(GpuObject).init(aya.mem.allocator) };
    }

    pub fn deinit(self: *DeletionQueue) void {
        self.flush();
        self.queue.deinit();
    }

    /// appends a GPU obj to be deleated at the end of the frame
    pub fn append(self: *DeletionQueue, obj: anytype) void {
        const gpuobj = switch (@TypeOf(obj)) {
            BufferHandle => .{ .buffer = obj },
            TextureHandle => .{ .texture = obj },
            TextureViewHandle => .{ .texture_view = obj },
            SamplerHandle => .{ .sampler = obj },
            RenderPipelineHandle => .{ .render_pipeline = obj },
            ComputePipelineHandle => .{ .compute_pipeline = obj },
            BindGroupHandle => .{ .bind_group = obj },
            BindGroupLayoutHandle => .{ .bind_group_layout = obj },
            PipelineLayoutHandle => .{ .pipeline_layout = obj },

            else => @panic("Attempted to delete an object that isnt supported by the DeletionQueue: " ++ @typeName(@TypeOf(obj))),
        };
        self.queue.append(gpuobj) catch unreachable;
    }

    pub fn flush(self: *DeletionQueue) void {
        if (self.queue.items.len == 0) return;

        var iter = ReverseSliceIterator(GpuObject).init(self.queue.items);
        while (iter.next()) |obj| {
            switch (obj.*) {
                .buffer => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .texture => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .texture_view => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .sampler => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .render_pipeline => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .compute_pipeline => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .bind_group => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .bind_group_layout => |gpuobj| aya.gctx.releaseResource(gpuobj),
                .pipeline_layout => |gpuobj| aya.gctx.releaseResource(gpuobj),
            }
        }

        self.queue.clearRetainingCapacity();
    }
};

fn ReverseSliceIterator(comptime T: type) type {
    return struct {
        slice: []T,
        index: usize,

        pub fn init(slice: []T) @This() {
            return .{
                .slice = slice,
                .index = slice.len,
            };
        }

        pub fn next(self: *@This()) ?*T {
            if (self.index == 0) return null;
            self.index -= 1;

            return &self.slice[self.index];
        }
    };
}
