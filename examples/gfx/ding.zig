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

const Uniform = extern struct {
    transform_matrix: Mat32,
};

var state: struct {
    batcher: Batcher = undefined,
    pipeline: aya.render.RenderPipelineHandle,
    bind_group: aya.render.BindGroupHandle,
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

    const bind_group_layout0 = gctx.createBindGroupLayout(&.{
        .label = "Bind Group",
        .entries = &.{
            .{ .visibility = .{ .fragment = true }, .texture = .{} },
            .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(bind_group_layout0); // TODO: do we have to hold onto these?

    const bind_group_layout1 = gctx.createBindGroupLayout(&.{
        .label = "Uniform Bind Group",
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = true } },
        },
    });
    defer gctx.releaseResource(bind_group_layout1); // TODO: do we have to hold onto these?

    state.bind_group = gctx.createBindGroup(bind_group_layout1, &.{
        .{ .buffer_handle = gctx.uniforms.buffer, .size = 256 },
    });

    state.pipeline = gctx.createPipeline(&.{
        .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/quad.wgsl") catch unreachable,
        .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
        .bgls = &.{ gctx.lookupResource(bind_group_layout0).?, gctx.lookupResource(bind_group_layout1).? },
    });

    state.fontbook = aya.render.FontBook.init(128, 128);
    _ = state.fontbook.addFontMem("ProggyTiny", aya.fs.readZ(aya.mem.tmp_allocator, "src/render/assets/ProggyTiny.ttf") catch unreachable, false);
    state.fontbook.setSize(10);
}

fn shutdown() !void {
    state.batcher.deinit();
    state.fontbook.deinit();
}

fn render(ctx: *aya.render.RenderContext) !void {
    const pip = aya.gctx.lookupResource(state.pipeline) orelse return;
    const bg = aya.gctx.lookupResource(state.bind_group) orelse return;

    // begin the render pass
    var pass = ctx.beginRenderPass(&.{
        .label = "Ding Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = ctx.swapchain_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
    });

    pass.setPipeline(pip);

    // projection matrix uniform
    {
        const win_size = aya.window.sizeInPixels();

        const mem = aya.gctx.uniforms.allocate(Uniform, 1);
        mem.slice[0] = .{
            .transform_matrix = Mat32.initOrtho(@as(f32, @floatFromInt(win_size.w)), @as(f32, @floatFromInt(win_size.h))),
        };
        pass.setBindGroup(1, bg, &.{mem.offset});
    }

    state.batcher.begin(pass);
    text("Fuck off you dumbass! i cant believe you did that in Batcher", 10, 50);
    state.batcher.drawTex(.{ .x = 200, .y = 200 }, Color.white.value, state.fontbook.texture);
    state.batcher.end();

    pass.end();
    pass.release();
}

var quad = Quad.init(0, 0, 1, 1, 1, 1);

fn text(str: []const u8, x: f32, y: f32) void {
    const img_info = aya.gctx.pools.texture_pool.getInfo(state.fontbook.texture);
    quad.setFill(@floatFromInt(img_info.size.width), @floatFromInt(img_info.size.height));

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

        state.batcher.draw(state.fontbook.texture, quad, matrix, Color{ .value = iter.color });
    }
}
