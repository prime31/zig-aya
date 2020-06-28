const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");
const TileKit = @import("tilekit.zig").TileKit;

var tk: TileKit = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .imgui = true,
        .window = .{
            .width = 1024,
            .height = 768,
        },
    });
}

fn init() void {
    tk = TileKit.init();
}

fn update() void {
    tk.draw();
}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.gfx.endPass();
}
