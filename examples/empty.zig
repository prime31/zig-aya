const std = @import("std");
const aya = @import("aya");

pub const thing = true;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() void {}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{ .color = aya.math.Color.aya });
    aya.gfx.endPass();
}
