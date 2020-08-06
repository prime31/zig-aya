const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");
usingnamespace @import("sokol");

const imgui = false;
var demo_open: bool = true;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .window = .{
            .width = 1024,
            .height = 768,
        },
        .imgui = true,
    });
}

fn init() void {}

fn update() void {
    igShowDemoWindow(&demo_open);
}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.gfx.endPass();
}
