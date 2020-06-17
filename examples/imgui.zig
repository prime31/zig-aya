const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() void {
    imgui.CHECKVERSION();
}

fn update() void {}

fn render() void {}
