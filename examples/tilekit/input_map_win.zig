const std = @import("std");
const colors = @import("colors.zig");
usingnamespace @import("imgui");

pub fn drawWindow(open: *bool) void {
    if (open.* and igBegin("Input Map", open, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysAutoResize)) {
        draw();
        igEnd();
    }
}

fn draw() void {
    _ = igInvisibleButton("", ImVec2{.x = 300, .y = 250});
}