const std = @import("std");
const aya = @import("aya");
const wgpu = aya.wgpu;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Quad = aya.math.Quad;
const Rect = aya.math.Rect;
const RectI = aya.math.RectI;
const Color = aya.math.Color;

const Draw = aya.render.Draw;

var state: struct {
    renderer: aya.render.BasicRenderer,
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
    state.renderer = aya.render.BasicRenderer.init();
    state.checker_tex = initCheckerTexture(4);
    state.checker_view = aya.gctx.createTextureView(state.checker_tex, &.{});
}

fn shutdown() !void {
    state.renderer.deinit();
    aya.gctx.releaseResource(state.checker_tex);
    aya.gctx.releaseResource(state.checker_view);
}

fn update() !void {
    state.renderer.debug.drawHollowCircle(.{ .x = 400, .y = 400 }, 20, 2, null);
    state.renderer.debug.drawHollowCircle(.{ .x = 410, .y = 410 }, 20, 2, Color.gray);
    state.renderer.debug.drawHollowCircle(.{ .x = 420, .y = 420 }, 20, 2, Color.gold);
    state.renderer.debug.drawText("debug text", .{ .x = 350, .y = 470 }, Color.pink);
}

fn render(ctx: *aya.render.RenderContext) !void {
    state.renderer.beginPass(ctx, Color.aya, null);

    state.renderer.draw.text("whatever mate", 10, 20, null);
    state.renderer.draw.circle(.{ .x = 250, .y = 250 }, 50, 4, 8, Color.aya);
    state.renderer.draw.rect(.{ .x = 100, .y = 100 }, 50, 20, Color.lime);
    state.renderer.draw.hollowRect(.{ .x = 160, .y = 100 }, 50, 20, 3, Color.light_gray);
    state.renderer.draw.texScale(state.checker_tex, 500, 500, 4);
    state.renderer.draw.line(.{ .x = 750, .y = 10 }, .{ .x = 400, .y = 700 }, 6, Color.orange);

    state.renderer.endPass();

    state.renderer.beginPass(ctx, null, Mat32.initTransform(.{ .x = 10, .y = 10 }));

    state.renderer.draw.text("whatever mate", 10, 20, null);
    state.renderer.draw.circle(.{ .x = 250, .y = 250 }, 50, 4, 8, Color.aya);
    state.renderer.draw.rect(.{ .x = 100, .y = 100 }, 50, 20, Color.lime);
    state.renderer.draw.hollowRect(.{ .x = 160, .y = 100 }, 50, 20, 3, Color.light_gray);
    state.renderer.draw.texScale(state.checker_tex, 500, 500, 4);
    state.renderer.draw.line(.{ .x = 750, .y = 10 }, .{ .x = 400, .y = 700 }, 6, Color.orange);

    state.renderer.endPass();
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
