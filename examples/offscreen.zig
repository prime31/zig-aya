const std = @import("std");
const aya = @import("aya");

var batcher: aya.gfx.Batcher = undefined;
var checker_tex: aya.gfx.Texture = undefined;
var font_tex: aya.gfx.Texture = undefined;
var checker_quad: aya.math.Quad = undefined;
var font_quad: aya.math.Quad = undefined;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    batcher.deinit();
}

fn init() void {
    batcher = aya.gfx.Batcher.init(null, 100) catch unreachable;

    var shader = aya.gfx.Shader.initFromFile("assets/SpriteEffect.fxb") catch unreachable;
    var mat = aya.math.Mat32.initOrtho(640, 480);
    shader.setParam(aya.math.Mat32, "TransformMatrix", mat);
    shader.apply();

    checker_tex = aya.gfx.Texture.initCheckerboard();
    font_tex = aya.gfx.Texture.initFromFile("assets/font.png") catch unreachable;

    checker_quad = aya.math.Quad.init(0, 0, @intToFloat(f32, checker_tex.width), @intToFloat(f32, checker_tex.height), checker_tex.width, checker_tex.height);
    font_quad = aya.math.Quad.init(0, 0, @intToFloat(f32, font_tex.width), @intToFloat(f32, font_tex.height), font_tex.width, font_tex.height);
}

fn update() void {}

fn render() void {
    var mat = aya.math.Mat32.identity;
    var x: usize = 0;
    var y = @as(usize, 0);
    while (x < 640 / 4) : (x += 1) {
        while (y < 480 / 4) : (y += 1) {
            batcher.draw(checker_tex.tex, checker_quad, mat, aya.math.Color.white);
            mat.translate(0, 4);
        }
        y = 0;
        mat.translate(4, 0);
        mat.translate(0, -480);
    }

    mat = aya.math.Mat32.identity;
    mat.translate(5, 5);
    mat.scale(10, 10);

    batcher.draw(checker_tex.tex, checker_quad, mat, aya.math.Color.white);

    mat.translate(5, 5);
    mat.scale(2, 2);
    batcher.draw(checker_tex.tex, checker_quad, mat, aya.math.Color.magenta);

    mat = aya.math.Mat32.identity;
    mat.translate(400, 100);
    mat.scale(0.2, 0.2);
    batcher.draw(font_tex.tex, font_quad, mat, aya.math.Color.lime);

    mat.translate(400, 100);
    batcher.draw(font_tex.tex, font_quad, mat, aya.math.Color.white);

    batcher.endFrame();
    aya.gfx.endPass();
}
