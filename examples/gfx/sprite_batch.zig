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

var state: struct {
    renderer: aya.render.BasicRenderer,
    texture: aya.render.TextureHandle,
    check_texture: aya.render.TextureHandle,
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
    state.renderer = aya.render.BasicRenderer.init();

    // textures
    state.texture = gctx.createTextureFromFile("examples/assets/tree0.png");
    state.check_texture = gctx.createTextureFromFile("examples/assets/checkbox.png");
}

fn shutdown() !void {
    state.renderer.deinit();
    aya.gctx.releaseResource(state.texture);
    aya.gctx.releaseResource(state.check_texture);
}

fn render(ctx: *aya.render.RenderContext) !void {
    state.renderer.beginPass(ctx, Color.aya, null);

    state.renderer.draw.tex(state.check_texture, 50, 0);
    state.renderer.draw.tex(state.texture, 0, 0);
    state.renderer.draw.tex(state.check_texture, 150, 0);
    state.renderer.draw.tex(state.check_texture, 200, 0);
    state.renderer.draw.tex(state.check_texture, 250, 0);
    state.renderer.draw.tex(state.texture, 100, 0);

    state.renderer.endPass();
    state.renderer.endFrame();
}
