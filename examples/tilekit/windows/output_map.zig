const std = @import("std");
usingnamespace @import("imgui");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
const colors = @import("../colors.zig");
const processor = @import("../rule_processor.zig");

pub fn drawWindow(state: *tk.AppState) void {
    // only process map data when it changes
    if (state.map_data_dirty) {
        processor.generateProcessedMap(state);
        processor.generateOutputMap(state);
        // TODO: fix this to only process when necessary
        //state.map_data_dirty = false;
    }

    if (state.windows.output_map and igBegin("Output Map", &state.windows.output_map, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar)) {
        draw(state);
        igEnd();
    }
}

fn draw(state: *tk.AppState) void {
    const origin = ogGetCursorScreenPos();
    const map_size = state.mapSize();

    ogAddRectFilled(igGetWindowDrawList(), origin, map_size, colors.colorRgb(0, 0, 0));
    _ = igInvisibleButton("##output-map-button", map_size);

    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            // const tile = processor.transformTileWithRules(state, x, y);
            const tile = state.final_map_data[x + y * state.map.w];
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
            drawTile(state, tl, tile - 1);
        }
    }
}

fn drawTile(state: *tk.AppState, tl: ImVec2, tile: usize) void {
    var br = tl;
    br.x += @intToFloat(f32, state.map.tile_size);
    br.y += @intToFloat(f32, state.map.tile_size);

    // tk.drawBrush(state.map_rect_size, tile, tl);
    const rect = tk.uvsForTile(state, tile);
    const uv0 = ImVec2{.x = rect.x, .y = rect.y};
    const uv1 = ImVec2{.x = rect.x + rect.w, .y = rect.y + rect.h};

    ImDrawList_AddImage(igGetWindowDrawList(), state.texture.tex, tl, br, uv0, uv1, 0xffffffff);
}
