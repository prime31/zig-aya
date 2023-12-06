const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;

pub const RenderContext = struct {
    surface_texture: ?wgpu.SurfaceTexture = null,
    swapchain_view: ?wgpu.TextureView = null,
    command_encoder: ?wgpu.CommandEncoder = undefined,
    command_buffers: std.BoundedArray(wgpu.CommandBuffer, 8),

    pub fn init() RenderContext {
        return .{
            .command_buffers = std.BoundedArray(wgpu.CommandBuffer, 8).init(0) catch unreachable,
        };
    }

    /// gets the current swapchain TextureView. DO NOT release it! It is managed internally.
    pub fn swapchainTextureView(self: *RenderContext) wgpu.TextureView {
        if (self.swapchain_view) |view| return view;

        self.swapchain_view = self.surface_texture.?.texture.?.createView(&.{ .label = "Swapchain View" });
        return self.swapchain_view.?;
    }

    pub fn commandEncoder(self: *RenderContext) wgpu.CommandEncoder {
        std.debug.print("get command encoder: {?}\n", .{self.command_encoder});
        if (self.command_encoder == null)
            self.command_encoder = aya.gctx.device.createCommandEncoder(&.{ .label = "Base Command Encoder" });
        std.debug.print("get command encoder2: {?}\n", .{self.command_encoder});
        return self.command_encoder.?;
    }

    /// Creates a new [`RenderPass`] for the context, configured using the provided `descriptor`.
    pub fn beginRenderPass(self: *RenderContext, descriptor: *const wgpu.RenderPassDescriptor) wgpu.RenderPassEncoder {
        return self.commandEncoder().beginRenderPass(descriptor);
    }

    /// Creates a new [`TrackedRenderPass`] for the context, configured using the provided `descriptor`.
    pub fn beginTrackedRenderPass(self: *RenderContext, descriptor: *const wgpu.RenderPassDescriptor) TrackedRenderPass {
        return TrackedRenderPass.init(self.commandEncoder().beginRenderPass(descriptor));
    }

    /// Append a [`CommandBuffer`] to the queue.
    /// If present, this will flush the currently unflushed [`CommandEncoder`] into a [`CommandBuffer`] into the queue
    /// before appending the provided buffer.
    pub fn addCommandBuffer(self: *RenderContext, command_buffer: wgpu.CommandBuffer) void {
        self.flushEncoder();
        self.command_buffers.append(command_buffer) catch unreachable;
    }

    /// Finalizes the queue and returns the queue of [`CommandBuffer`]s
    pub fn finish(self: *RenderContext) void {
        self.flushEncoder();
    }

    pub fn releaseResources(self: *RenderContext) void {
        if (self.swapchain_view) |view| view.release();
        if (self.surface_texture) |surface| {
            if (surface.texture) |t| t.release();
        }

        self.swapchain_view = null;
        self.surface_texture = null;
        self.command_encoder = null;
        self.command_buffers.resize(0) catch unreachable;
    }

    fn flushEncoder(self: *RenderContext) void {
        if (self.command_encoder) |encoder| {
            self.command_buffers.append(encoder.finish(null)) catch unreachable;
        }
    }
};

pub const TrackedRenderPass = struct {
    pass: wgpu.RenderPass,
    state: DrawState,

    pub fn init(pass: wgpu.RenderPass) TrackedRenderPass {
        return .{ .pass = pass, .state = DrawState.init() };
    }
};

pub const DrawState = struct {
    // pipeline: Option<RenderPipelineId>,
    // bind_groups: Vec<(Option<BindGroupId>, Vec<u32>)>,
    // vertex_buffers: Vec<Option<(BufferId, u64)>>,
    // index_buffer: Option<(BufferId, u64, IndexFormat)>,

    pub fn init() DrawState {
        return .{};
    }
};
