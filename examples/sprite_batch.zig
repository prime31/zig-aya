const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya");
const wgpu = aya.wgpu;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Quad = aya.math.Quad;
const Rect = aya.math.Rect;
const RectI = aya.math.RectI;
const Color = aya.math.Color;

const Batcher = aya.render.Batcher;

const Vertex = extern struct {
    pos: Vec2,
    uv: Vec2,
};

var state: struct {
    batcher: Batcher = undefined,
    texture: aya.TextureHandle,
    check_texture: aya.TextureHandle,
    tex_view: aya.TextureViewHandle,
    check_tex_view: aya.TextureViewHandle,
    sampler: aya.SamplerHandle,
    pipeline: aya.RenderPipelineHandle,
} = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    var gctx = aya.gctx;
    state.batcher = Batcher.init(128);

    // textures
    state.texture = gctx.createTextureFromFile("examples/assets/tree0.png");
    state.check_texture = gctx.createTextureFromFile("examples/assets/checkbox.png");

    // texture view
    state.tex_view = gctx.createTextureView(state.texture, &.{});
    state.check_tex_view = gctx.createTextureView(state.check_texture, &.{});

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

    state.pipeline = gctx.createPipeline(&.{
        .source = @embedFile("assets/shaders/quad.wgsl"),
        .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
    });
}

fn shutdown() !void {
    state.batcher.deinit();
}

fn render() !void {
    const pip = aya.gctx.lookupResource(state.pipeline) orelse return;

    // get the current texture view for the swap chain
    var surface_texture: wgpu.SurfaceTexture = undefined;
    aya.gctx.surface.getCurrentTexture(&surface_texture);
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

    const texture_view = surface_texture.texture.?.createView(null);
    defer texture_view.release();

    var command_encoder = aya.gctx.device.createCommandEncoder(&.{ .label = "Command Encoder" });

    // begin the render pass
    var pass = command_encoder.beginRenderPass(&.{
        .label = "Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = texture_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
    });

    pass.setPipeline(pip);

    state.batcher.begin(pass);
    state.batcher.drawTex(.{ .x = 50 }, Color.blue.value, state.check_texture);
    state.batcher.drawTex(.{}, Color.red.value, state.texture);
    state.batcher.drawTex(.{ .x = 150 }, Color.white.value, state.check_texture);
    state.batcher.drawTex(.{ .x = 200 }, Color.white.value, state.check_texture);
    state.batcher.drawTex(.{ .x = 250 }, Color.white.value, state.check_texture);
    state.batcher.drawTex(.{ .y = 100 }, Color.white.value, state.texture);
    state.batcher.end();

    pass.end();
    pass.release();

    var command_buffer = command_encoder.finish(&.{ .label = "Command buffer" });
    aya.gctx.submit(&.{command_buffer});
    aya.gctx.surface.present();
}
