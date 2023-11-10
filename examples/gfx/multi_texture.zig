const std = @import("std");
const shaders = @import("shaders");
const aya = @import("aya");
const ig = aya.ig;

const Texture = aya.render.Texture;
const Color = aya.math.Color;
const DissolveShader = shaders.DissolveShader;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

var tex: Texture = undefined;
var clouds_tex: Texture = undefined;
var dissolve_shader: DissolveShader = undefined;

fn init() !void {
    tex = Texture.initFromFile("examples/assets/sword_dude.png", .nearest);
    clouds_tex = Texture.initFromFile("examples/assets/clouds.png", .nearest);

    dissolve_shader = shaders.createDissolveShader();
    dissolve_shader.frag_uniform.threshold = 0.04;
    dissolve_shader.frag_uniform.threshold_color = [_]f32{ 1, 0.6, 0, 1 };
    dissolve_shader.textures[0] = clouds_tex;
}

fn render() !void {
    aya.gfx.beginPass(.{ .shader = &dissolve_shader.shader });
    dissolve_shader.frag_uniform.progress = aya.math.pingpong(aya.time.seconds(), 1);

    var center = aya.window.sizeInPixels().asVec2().mul(aya.math.Vec2.init(0.5, 0.5));
    aya.gfx.draw.texScale(tex, center.x - tex.width * 0.5 * 4, center.y - tex.height * 0.5 * 4, 4);

    aya.gfx.endPass();
}

fn shutdown() !void {
    tex.deinit();
    clouds_tex.deinit();
    dissolve_shader.deinit();
}
