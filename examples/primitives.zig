const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const Color = math.Color;

var tri_batch: aya.gfx.TriangleBatcher = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    tri_batch.deinit();
}

fn init() void {
    var shader = aya.gfx.Shader.initFromFile("assets/SpriteEffect.fxb") catch unreachable;
    var mat = aya.math.Mat32.initOrtho(640, 480);
    shader.setParam(aya.math.Mat32, "TransformMatrix", mat);
    shader.apply();

    tri_batch = aya.gfx.TriangleBatcher.init(null, 100) catch unreachable;
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass();
    aya.gfx.line(aya.math.Vec2.init(0, 0), aya.math.Vec2.init(640, 480), 2, aya.math.Color.blue);
    aya.gfx.point(math.Vec2.init(350, 350), 10, math.Color.sky_blue);
    aya.gfx.point(math.Vec2.init(380, 380), 15, math.Color.magenta);
    aya.gfx.rect(math.Vec2.init(387, 372), 40, 15, math.Color.dark_brown);
    aya.gfx.hollowRect(math.Vec2.init(430, 372), 40, 15, 2, math.Color.yellow);
    aya.gfx.circle(math.Vec2.init(100, 350), 20, 1, 12, math.Color.orange);

    const poly = [_]math.Vec2{ .{ .x = 400, .y = 30 }, .{ .x = 420, .y = 10 }, .{ .x = 430, .y = 80 }, .{ .x = 410, .y = 60 }, .{ .x = 375, .y = 40 } };
    aya.gfx.hollowPolygon(poly[0..], 2, math.Color.gold);
    aya.gfx.endPass();

    aya.gfx.beginPass();
    tri_batch.drawTriangle(.{ .x = 50, .y = 50 }, .{ .x = 150, .y = 150 }, .{ .x = 0, .y = 150 }, Color.black);
    tri_batch.drawTriangle(.{ .x = 300, .y = 50 }, .{ .x = 350, .y = 150 }, .{ .x = 200, .y = 150 }, Color.lime);
    tri_batch.endFrame();
    aya.gfx.endPass();
}
