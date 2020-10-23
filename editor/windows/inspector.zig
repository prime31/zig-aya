const std = @import("std");
const aya = @import("aya");
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

pub fn draw(state: *editor.AppState) void {
    defer igEnd();
    if (!igBegin("Inspector", null, ImGuiWindowFlags_None)) return;

    _ = ogButton("word to your mother");
}
