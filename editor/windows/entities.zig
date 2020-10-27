const std = @import("std");
const aya = @import("aya");
const root = @import("root");
usingnamespace @import("imgui");

pub fn draw(state: *root.AppState) void {
    if (igBegin("Entities", null, ImGuiWindowFlags_None)) {}
    igEnd();
}
