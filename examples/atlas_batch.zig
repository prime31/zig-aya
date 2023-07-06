const std = @import("std");
const aya = @import("aya");

var batch: aya.gfx.AtlasBatch = undefined;
var font_tex: aya.gfx.Texture = undefined;
var quad: aya.math.Quad = undefined;
var index: usize = 0;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() !void {
    font_tex = aya.gfx.Texture.initFromFile("examples/assets/textures/font.png", .linear) catch unreachable;
    batch = aya.gfx.AtlasBatch.init(null, font_tex, 200) catch unreachable;
    quad = aya.math.Quad.init(0, 0, font_tex.width, font_tex.height, font_tex.width, font_tex.height);

    var mat = aya.math.Mat32.identity;

    var x: usize = 0;
    var y = @as(usize, 0);
    const w = 506 / 10;
    const h = 616 / 10;
    const scale = 0.3;
    while (y < 10) : (y += 1) {
        while (x < 10) : (x += 1) {
            const x_pos = @as(f32, @floatFromInt(x * w));
            const y_pos = @as(f32, @floatFromInt(y * h));
            const x_gap = @as(f32, @floatFromInt(x));
            const y_gap = @as(f32, @floatFromInt(y));
            mat.setTransform(.{ .x = x_pos * scale + x_gap, .y = y_pos * scale + y_gap, .sx = scale, .sy = scale });
            _ = batch.addViewport(.{ .x = @as(i32, @intFromFloat(x_pos)), .y = @as(i32, @intFromFloat(y_pos)), .w = w, .h = h }, mat, aya.math.Color.white);
            mat.translate(w * scale, 0);
        }
        x = 0;
        mat.translate(0, h * scale);
    }

    mat.setTransform(.{ .x = 300, .y = 150, .angle = 0.3, .sx = 0.2, .sy = 0.2, .ox = font_tex.width / 2.0, .oy = font_tex.height / 2.0 });
    _ = batch.add(quad, mat, aya.math.Color.green);
    index = batch.addViewport(.{ .w = 20, .h = 20 }, null, aya.math.Color.blue);
}

fn update() !void {
    if (aya.math.rand.chance(0.9)) return;

    const rx = aya.math.rand.range(f32, -2, 2);
    const ry = aya.math.rand.range(f32, -2, 2);

    var mat = aya.math.Mat32.identity;
    mat.translate(300 + rx, 300 + ry);

    batch.setViewport(index, .{ .w = 20, .h = 20 }, mat, aya.math.rand.color());
}

fn render() !void {
    aya.gfx.beginPass(.{});
    batch.draw();
    aya.gfx.endPass();
}
