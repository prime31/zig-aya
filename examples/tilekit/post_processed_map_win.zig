const std = @import("std");
usingnamespace @import("imgui");
const colors = @import("colors.zig");
const tk = @import("tilekit.zig");

pub fn drawWindow(state: *tk.AppState) void {
    if (state.post_processed_map and igBegin("Post Processed Map", &state.post_processed_map, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysAutoResize)) {
        draw();
        igEnd();
    }
}

fn draw() void {
    _ = igInvisibleButton("", ImVec2{.x = 300, .y = 250});
}