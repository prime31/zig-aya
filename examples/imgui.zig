const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");

pub const enable_imgui = true;
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
    });
}

fn init() !void {}

fn update() !void {
    imgui.igShowDemoWindow(&demo_open);
}

fn render() !void {
    aya.gfx.beginPass(.{});
    aya.gfx.endPass();
}
