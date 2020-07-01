const std = @import("std");
usingnamespace @import("imgui");
const tk = @import("tilekit.zig");

pub fn drawWindow(state: *tk.AppState) void {
    if (state.output_map and igBegin("Output Map", &state.output_map, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysAutoResize)) {
        draw(state);
        igEnd();
    }
}

fn draw(state: *tk.AppState) void {
    var origin = ogGetCursorScreenPos();
    _ = igInvisibleButton("", state.mapSize());

    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            const tile = state.map.getTile(x, y);
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
            tk.drawBrush(state.map_rect_size, tile - 1, tl);
        }
    }
}
