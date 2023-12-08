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

const Draw = aya.render.Draw;

const Uniform = extern struct {
    transform_matrix: Mat32,
};

var state: struct {
    draw: Draw = undefined,
    pipeline: aya.render.RenderPipelineHandle,
    bind_group: aya.render.BindGroupHandle,
    checker_tex: aya.render.TextureHandle,
    checker_view: aya.render.TextureViewHandle,
} = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    var gctx = aya.gctx;
    state.draw = Draw.init();

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

    state.checker_tex = initCheckerTexture(4);
    state.checker_view = aya.gctx.createTextureView(state.checker_tex, &.{});
}

fn shutdown() !void {
    state.draw.deinit();
    aya.gctx.releaseResource(state.pipeline);
    aya.gctx.releaseResource(state.bind_group);
    aya.gctx.releaseResource(state.checker_tex);
    aya.gctx.releaseResource(state.checker_view);
}

fn update() !void {
    aya.debug.drawHollowCircle(.{ .x = 400, .y = 400 }, 20, 2, null);
    aya.debug.drawHollowCircle(.{ .x = 410, .y = 410 }, 20, 2, Color.gray);
    aya.debug.drawHollowCircle(.{ .x = 420, .y = 420 }, 20, 2, Color.gold);
    aya.debug.drawText("debug text", .{ .x = 350, .y = 470 }, Color.pink);
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
            .clear_value = .{ .r = 0.5, .g = 0.2, .b = 0.3, .a = 1.0 },
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

    state.draw.batcher.begin(pass);
    state.draw.text("whatever mate", 10, 20, null);
    state.draw.circle(.{ .x = 250, .y = 250 }, 50, 4, 8, Color.aya);
    state.draw.rect(.{ .x = 100, .y = 100 }, 50, 20, Color.lime);
    state.draw.hollowRect(.{ .x = 160, .y = 100 }, 50, 20, 3, Color.light_gray);
    state.draw.texScale(state.checker_tex, 500, 500, 4);
    state.draw.line(.{ .x = 750, .y = 10 }, .{ .x = 400, .y = 700 }, 6, Color.orange);

    _ = aya.debug.render(&state.draw, true);
    state.draw.batcher.end();

    pass.end();
    pass.release();
}

pub fn initCheckerTexture(comptime scale: usize) aya.render.TextureHandle {
    const colors = [_]u32{
        0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
        0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
        0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
        0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
    };

    var pixels: [4 * scale * 4 * scale]u32 = undefined;
    var y: usize = 0;
    while (y < 4 * scale) : (y += 1) {
        var x: usize = 0;
        while (x < 4 * scale) : (x += 1) {
            pixels[y + x * 4 * scale] = colors[@mod(x / scale, 4) + @mod(y / scale, 4) * 4];
        }
    }

    const tex = aya.gctx.createTexture(4 * scale, 4 * scale, aya.render.GraphicsContext.swapchain_format);
    aya.gctx.writeTexture(tex, u32, &pixels);

    return tex;
}
