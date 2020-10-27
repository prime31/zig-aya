const std = @import("std");
const aya = @import("aya");
const root = @import("root");
usingnamespace @import("imgui");

pub fn draw(state: *root.AppState) void {
    defer igEnd();
    if (!igBegin("Inspector", null, ImGuiWindowFlags_None)) return;

    _ = ogButton("word to your mother");
}
