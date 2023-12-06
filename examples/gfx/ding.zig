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
    texture: aya.render.TextureHandle,
    check_texture: aya.render.TextureHandle,
    tex_view: aya.render.TextureViewHandle,
    check_tex_view: aya.render.TextureViewHandle,
    sampler: aya.render.SamplerHandle,
    pipeline: aya.render.RenderPipelineHandle,
    fontbook: *aya.render.FontBook,
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
        .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/quad.wgsl") catch unreachable,
        .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
    });

    state.fontbook = aya.render.FontBook.init(128, 128);
    _ = state.fontbook.addFontMem("ProggyTiny", aya.fs.readZ(aya.mem.tmp_allocator, "src/render/assets/ProggyTiny.ttf") catch unreachable, false);
    state.fontbook.setSize(10);
}

fn shutdown() !void {
    state.batcher.deinit();
    state.fontbook.deinit();
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

    var command_encoder = aya.gctx.device.createCommandEncoder(&.{ .label = "Ding Command Encoder" });

    // begin the render pass
    var pass = command_encoder.beginRenderPass(&.{
        .label = "Ding Render Pass Encoder",
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
    text("SSSSSSSSSSSSSSSSSS", 10, 50);
    state.batcher.drawTex(.{ .x = 200, .y = 200 }, Color.white.value, state.fontbook.texture);
    // state.batcher.drawTex(.{ .x = 50 }, Color.blue.value, state.check_texture);
    // state.batcher.drawTex(.{}, Color.red.value, state.texture);
    // state.batcher.drawTex(.{ .x = 150 }, Color.white.value, state.check_texture);
    // state.batcher.drawTex(.{ .x = 200 }, Color.white.value, state.check_texture);
    // state.batcher.drawTex(.{ .x = 250 }, Color.white.value, state.check_texture);
    // state.batcher.drawTex(.{ .y = 100 }, Color.white.value, state.texture);
    state.batcher.end();

    pass.end();
    pass.release();

    // TODO: move this in aya
    aya.ig.sdl.draw(aya.gctx, command_encoder, texture_view);

    var command_buffer = command_encoder.finish(&.{ .label = "Ding Command buffer" });
    aya.gctx.submit(&.{command_buffer});
    aya.gctx.surface.present();
}

var quad = Quad.init(0, 0, 1, 1, 1, 1);

fn text(str: []const u8, x: f32, y: f32) void {
    // TODO: dont hardcode scale
    var matrix = Mat32.initTransform(.{ .x = x, .y = y, .sx = 2, .sy = 2 });

    var fons_quad = aya.render.FontBook.Quad{};
    var iter = state.fontbook.getTextIterator(str);
    while (state.fontbook.textIterNext(&iter, &fons_quad)) {
        quad.positions[0] = .{ .x = fons_quad.x0, .y = fons_quad.y0 };
        quad.positions[1] = .{ .x = fons_quad.x1, .y = fons_quad.y0 };
        quad.positions[2] = .{ .x = fons_quad.x1, .y = fons_quad.y1 };
        quad.positions[3] = .{ .x = fons_quad.x0, .y = fons_quad.y1 };

        quad.uvs[0] = .{ .x = fons_quad.s0, .y = fons_quad.t0 };
        quad.uvs[1] = .{ .x = fons_quad.s1, .y = fons_quad.t0 };
        quad.uvs[2] = .{ .x = fons_quad.s1, .y = fons_quad.t1 };
        quad.uvs[3] = .{ .x = fons_quad.s0, .y = fons_quad.t1 };

        quad.uvs[0] = .{ .x = 0, .y = 0 };
        quad.uvs[1] = .{ .x = 1, .y = 0 };
        quad.uvs[2] = .{ .x = 1, .y = 1 };
        quad.uvs[3] = .{ .x = 0, .y = 1 };

        state.batcher.draw(state.fontbook.texture, quad, matrix, Color{ .value = iter.color });
    }
}
