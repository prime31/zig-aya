const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya");
const wgpu = aya.wgpu;
const gpu = aya.gpu;

const GraphicsContext = aya.GraphicsContext;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub var allocator = gpa.allocator();

var gctx: *GraphicsContext = undefined;

pub fn main() !void {
    defer _ = gpa.deinit();

    gctx = try GraphicsContext.init(allocator);
    defer gctx.deinit(allocator);

    // texture
    const image = @import("stb").Image.init(allocator, "examples/image.png") catch unreachable;
    defer image.deinit();

    const texture = gpu.createTexture(gctx, image.w, image.h, .rgba8_unorm);
    defer texture.destroy();

    gpu.writeTexture(gctx, texture, image.w, image.h, u8, image.getImageData());

    // texture view
    const tex_view = texture.createView(null);
    defer tex_view.release();

    // sampler
    const sampler = gctx.device.createSampler(null);
    defer sampler.release();

    const bind_group_layout = gpu.createBindGroupLayout(gctx, &.{
        .label = "Bind Group",
        .entries = &.{
            .{
                .visibility = .{ .fragment = true },
                .texture = .{},
            },
            .{
                .visibility = .{ .fragment = true },
                .sampler = .{},
            },
        },
    });
    defer bind_group_layout.release();

    const bind_group = gpu.createBindGroup(gctx, &.{
        .label = "Bind Group",
        .layout = bind_group_layout,
        .entries = &.{
            .{ .texture_view = tex_view },
            .{ .sampler = sampler },
        },
    });
    defer bind_group.release();

    const pipeline = gpu.createPipeline(gctx, &.{ .source = @embedFile("fullscreen.wgsl") });
    defer pipeline.release();

    blk: while (true) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => break :blk,
                sdl.SDL_EVENT_WINDOW_RESIZED => gctx.resize(event.window.data1, event.window.data2),
                else => {},
            }
        }

        // get the current texture view for the swap chain
        var surface_texture: wgpu.SurfaceTexture = undefined;
        gctx.surface.getCurrentTexture(&surface_texture);
        defer if (surface_texture.texture) |t| t.release();

        switch (surface_texture.status) {
            .success => {},
            .timeout, .outdated, .lost => {
                var width: c_int = 0;
                var height: c_int = 0;
                _ = sdl.SDL_GetWindowSizeInPixels(gctx.sdl_window, &width, &height);

                gctx.resize(width, height);
                continue;
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
        var pass_encoder = command_encoder.beginRenderPass(&.{
            .label = "Render Pass Encoder",
            .color_attachment_count = 1,
            .color_attachments = &.{
                .view = texture_view,
                .load_op = .clear,
                .store_op = .store,
                .clear_value = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
            },
        });

        pass_encoder.setPipeline(pipeline);
        pass_encoder.setBindGroup(0, bind_group, 0, null);
        pass_encoder.draw(3, 1, 0, 0);
        pass_encoder.end();

        var command_buffer = command_encoder.finish(&.{ .label = "Command buffer" });
        gctx.submit(&.{command_buffer});
        gctx.surface.present();
    }
}
