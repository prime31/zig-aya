const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya");
const wgpu = aya.wgpu;
const gpu = aya.gpu;

const GraphicsContext = aya.GraphicsContext;

const Vertex = extern struct {
    position: [2]f32,
    uv: [2]f32,
};

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

var state: struct {
    vbuff: aya.BufferHandle,
    ibuff: aya.BufferHandle,
    texture: aya.TextureHandle,
    tex_view: aya.TextureViewHandle,
    sampler: aya.SamplerHandle,
    bind_group: aya.BindGroupHandle,
    pipeline: aya.RenderPipelineHandle,
} = undefined;

pub fn init() !void {
    var gctx = aya.gctx;

    // vertex buffer
    const vertex_data = [_]Vertex{
        .{ .position = .{ -0.9, 0.9 }, .uv = .{ 0.0, 0.0 } },
        .{ .position = .{ 0.9, 0.9 }, .uv = .{ 1.0, 0.0 } },
        .{ .position = .{ 0.9, -0.9 }, .uv = .{ 1.0, 1.0 } },
        .{ .position = .{ -0.9, -0.9 }, .uv = .{ 0.0, 1.0 } },
    };
    state.vbuff = gctx.createBufferInit(null, .{ .copy_dst = true, .vertex = true }, Vertex, &vertex_data);

    // index buffer
    const index_data = [_]u16{ 0, 1, 3, 1, 2, 3 };
    state.ibuff = gctx.createBufferInit(null, .{ .copy_dst = true, .index = true }, u16, &index_data);

    // texture
    const image = @import("stb").Image.init(aya.mem.allocator, "examples/image.png") catch unreachable;
    defer image.deinit();

    state.texture = gctx.createTexture(image.w, image.h, GraphicsContext.swapchain_format);

    gctx.writeTexture(state.texture, u8, image.getImageData());

    // texture view
    state.tex_view = gctx.createTextureView(state.texture, &.{});

    // sampler
    state.sampler = gctx.createSampler(&.{});

    const bind_group_layout = gctx.createBindGroupLayout(&.{
        .label = "Bind Group",
        .entries = &.{
            .{ .visibility = .{ .fragment = true }, .texture = .{} },
            .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(bind_group_layout); // TODO: do we have to hold onto these?

    state.bind_group = gctx.createBindGroup(bind_group_layout, &.{
        .{ .texture_view_handle = state.tex_view },
        .{ .sampler_handle = state.sampler },
    });

    state.pipeline = gctx.createPipeline(&.{
        .source = @embedFile("quad.wgsl"),
        .vbuffers = &gpu.vertexAttributesForType(Vertex).vertexBufferLayouts(),
    });
}

pub fn render() !void {
    var gctx = aya.gctx;

    // get the current texture view for the swap chain
    var surface_texture: wgpu.SurfaceTexture = undefined;
    gctx.surface.getCurrentTexture(&surface_texture);
    defer if (surface_texture.texture) |t| t.release();

    switch (surface_texture.status) {
        .success => {},
        .timeout, .outdated, .lost => {
            const size = aya.window.sizeInPixels();
            aya.gctx.resize(size.w, size.h);
            return;
        },
        .out_of_memory, .device_lost => {
            std.debug.print("shits gone down: {}\n", .{surface_texture.status});
            @panic("unhandled surface texture status!");
        },
    }

    // create a command encoder
    var command_encoder = gctx.device.createCommandEncoder(&.{ .label = "Command Encoder" });

    const texture_view = surface_texture.texture.?.createView(null);
    defer texture_view.release();

    // begin the render pass
    pass: {
        const vb_info = gctx.lookupResourceInfo(state.vbuff) orelse break :pass;
        const ib_info = gctx.lookupResourceInfo(state.ibuff) orelse break :pass;
        const bg = gctx.lookupResource(state.bind_group) orelse break :pass;
        const pip = gctx.lookupResource(state.pipeline) orelse break :pass;

        var pass_encoder = command_encoder.beginRenderPass(&.{
            .label = "Render Pass Encoder",
            .color_attachment_count = 1,
            .color_attachments = &.{
                .view = texture_view,
                .load_op = .clear,
                .store_op = .store,
                .clear_value = .{ .r = 0.4, .g = 0.2, .b = 0.3, .a = 1.0 },
            },
        });

        defer {
            pass_encoder.end();
            pass_encoder.release();
        }

        pass_encoder.setVertexBuffer(0, vb_info.gpuobj.?, 0, vb_info.size);
        pass_encoder.setIndexBuffer(ib_info.gpuobj.?, .uint16, 0, ib_info.size);
        pass_encoder.setPipeline(pip);
        pass_encoder.setBindGroup(0, bg, 0, null);
        pass_encoder.drawIndexed(6, 1, 0, 0, 0);
    }

    var command_buffer = command_encoder.finish(&.{ .label = "Command buffer" });
    gctx.submit(&.{command_buffer});
    gctx.surface.present();
}

pub fn shutdown() !void {
    aya.gctx.destroyResource(state.vbuff);
    aya.gctx.destroyResource(state.ibuff);
    aya.gctx.destroyResource(state.texture);
    // aya.gctx.releaseResource(state.tex_view); // TODO: why does this crash with "Cannot remove a vacant resource"
    aya.gctx.releaseResource(state.sampler);
    aya.gctx.releaseResource(state.bind_group);
    aya.gctx.releaseResource(state.pipeline);
}
