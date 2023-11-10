const std = @import("std");
const shaders = @import("shaders");
const aya = @import("aya");
const ig = aya.ig;

const Color = aya.math.Color;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .render = render,
    });
}

fn init() !void {}

fn render() !void {
    aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 10, .y = 20 }, null);
    aya.debug.drawHollowCircle(.{ .x = 600, .y = 600 }, 30, 4, Color.dark_purple);

    aya.gfx.beginPass(.{});
    aya.gfx.draw.rect(aya.math.Vec2.init(50, 50), 200, 400, Color.lime);
    aya.gfx.endPass();
}
