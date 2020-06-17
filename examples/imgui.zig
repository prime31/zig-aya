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
    const res = imgui.igDebugCheckVersionAndDataLayout("1.77 WIP", @sizeOf(imgui.ImGuiIO), @sizeOf(imgui.ImGuiStyle), @sizeOf(imgui.ImVec2), @sizeOf(imgui.ImVec4), @sizeOf(imgui.ImDrawVert), @sizeOf(imgui.ImDrawIdx));
    std.debug.warn("good? {s}\n", .{res});
}

fn update() void {}

fn render() void {}
