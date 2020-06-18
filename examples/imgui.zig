const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");

var demo_open: bool = true;

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

fn update() void {
    imgui.igShowDemoWindow(&demo_open);
    imgui.igText("-");
}

fn render() void {
    aya.gfx.beginPass(.{});
}
