const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;

pub const RenderContext = struct {
    surface_texture: wgpu.SurfaceTexture,
    swapchain_view: wgpu.TextureView,
    command_encoder: wgpu.CommandEncoder,
    command_buffers: std.BoundedArray(wgpu.CommandBuffer, 8),

    pub fn init() RenderContext {
        var surface_texture: wgpu.SurfaceTexture = undefined;
        aya.gctx.surface.getCurrentTexture(&surface_texture);

        return .{
            .surface_texture = surface_texture,
            .swapchain_view = surface_texture.texture.?.createView(&.{ .label = "Swapchain View" }),
            .command_encoder = aya.gctx.device.createCommandEncoder(&.{ .label = "Base Command Encoder" }),
            .command_buffers = std.BoundedArray(wgpu.CommandBuffer, 8).init(0) catch unreachable,
        };
    }

    /// completes rendering: finishes the RenderContext, submits the CommandBuffers, and presents the surface
    pub fn deinit(self: *RenderContext) void {
        if (aya.ig.enabled) {
            aya.ig.sdl.draw(aya.gctx, self.command_encoder, self.swapchain_view);
        }

        self.finish();
        aya.gctx.submit(self.command_buffers.constSlice());
        aya.gctx.surface.present();

        self.swapchain_view.release();
        if (self.surface_texture.texture) |t| t.release();
    }

    /// Creates a new [`RenderPass`] for the context, configured using the provided `descriptor`.
    pub fn beginRenderPass(self: *RenderContext, descriptor: *const wgpu.RenderPassDescriptor) wgpu.RenderPassEncoder {
        return self.command_encoder.beginRenderPass(descriptor);
    }

    /// Creates a new [`TrackedRenderPass`] for the context, configured using the provided `descriptor`.
    pub fn beginTrackedRenderPass(self: *RenderContext, descriptor: *const wgpu.RenderPassDescriptor) TrackedRenderPass {
        return TrackedRenderPass.init(self.command_encoder.beginRenderPass(descriptor));
    }

    /// Append a [`CommandBuffer`] to the queue.
    /// If present, this will flush the currently unflushed [`CommandEncoder`] into a [`CommandBuffer`] into the queue
    /// before appending the provided buffer.
    pub fn appendCommandBuffer(self: *RenderContext, command_buffer: wgpu.CommandBuffer) void {
        self.flushEncoder();
        self.command_buffers.append(command_buffer) catch unreachable;
    }

    /// Finalizes the queue and prepares the [`CommandBuffer`]s for submitting
    pub fn finish(self: *RenderContext) void {
        self.flushEncoder();
    }

    fn flushEncoder(self: *RenderContext) void {
        // finish the encoder then create a new one
        self.command_buffers.append(self.command_encoder.finish(null)) catch unreachable;
        self.command_encoder = aya.gctx.device.createCommandEncoder(&.{ .label = "Base Command Encoder++" });
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
