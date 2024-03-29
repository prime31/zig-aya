const std = @import("std");
const aya = @import("aya");

var checker_tex: aya.gfx.Texture = undefined;
var font_tex: aya.gfx.Texture = undefined;
var checker_quad: aya.math.Quad = undefined;
var font_quad: aya.math.Quad = undefined;

pub fn main() !void {
    try aya.run(.{ .init = init, .update = update, .render = render, .shutdown = shutdown, .window = .{ .disable_vsync = false } });
}

fn init() !void {
    checker_tex = aya.gfx.Texture.initCheckerTexture(1);
    font_tex = aya.gfx.Texture.initFromFile("examples/assets/textures/font.png", .linear) catch unreachable;

    checker_quad = aya.math.Quad.init(0, 0, checker_tex.width, checker_tex.height, checker_tex.width, checker_tex.height);
    font_quad = aya.math.Quad.init(0, 0, font_tex.width, font_tex.height, font_tex.width, font_tex.height);
}

fn shutdown() !void {
    checker_tex.deinit();
    font_tex.deinit();
}

fn update() !void {}

fn render() !void {
    aya.gfx.beginPass(.{});

    var x: usize = 0;
    var y = @as(usize, 0);
    while (x < 640 / 40) : (x += 1) {
        while (y < 480 / 40) : (y += 1) {
            aya.draw.tex(checker_tex, @as(f32, @floatFromInt(x * 5)), @as(f32, @floatFromInt(y * 5)));
        }
        y = 0;
    }

    aya.draw.texScale(font_tex, 200, 200, 0.2);
    aya.draw.texScale(checker_tex, 10, 10, 10);
    aya.draw.texScale(font_tex, 400, 100, 0.2);
    aya.draw.texScale(font_tex, 600, 200, 0.2);

    aya.gfx.endPass();
}
