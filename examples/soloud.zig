const std = @import("std");
const aya = @import("aya");
const soloud = @import("soloud");

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() void {
    var instance: soloud.Soloud = undefined;
    std.debug.print("go: {}\n", .{soloud.Soloud_init(&instance)});
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{ .color = aya.math.Color.aya });
    aya.gfx.endPass();
}
