const std = @import("std");
const aya = @import("aya");
const fna = @import("fna");

var tex: aya.gfx.Texture = undefined;
var lines_shader: aya.gfx.Shader = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() void {
    tex = aya.gfx.Texture.initFromFile("assets/sword_dude.png") catch unreachable;
    lines_shader = aya.gfx.Shader.initFromFile("assets/SpriteLines.fxb") catch unreachable;
    lines_shader.setCurrentTechnique("HorizontalLines") catch unreachable;
    lines_shader.setParam(f32, "LineSize", 4);
    lines_shader.setParam(aya.math.Vec4, "LineColor", .{ .x = 0.8, .y = 0.8, .z = 0, .w = 1.0 });
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{ .color = aya.math.Color.aya });
    aya.draw.texScale(tex, 30, 30, 3);

    aya.gfx.setShader(lines_shader);
    aya.draw.texScale(tex, 230, 230, 3);
    aya.gfx.endPass();
}
