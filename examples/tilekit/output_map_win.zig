const std = @import("std");
usingnamespace @import("imgui");
const aya = @import("aya");
const tk = @import("tilekit.zig");
const colors = @import("colors.zig");
const processor = @import("rule_processor.zig");

pub fn drawWindow(state: *tk.AppState) void {
    if (state.output_map_win and igBegin("Output Map", &state.output_map_win, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar)) {
        draw(state);
        igEnd();
    }
}

fn draw(state: *tk.AppState) void {
    const origin = ogGetCursorScreenPos();
    const map_size = state.mapSize();

    ogAddRectFilled(igGetWindowDrawList(), origin, map_size, colors.colorRgb(0, 0, 0));
    _ = igInvisibleButton("##output-map-button", map_size);

    // only process map data when it changes
    if (state.map_data_dirty) {
        processor.generateProcessedMap(state);
        processor.generateOutputMap(state);
        // TODO: fix this to only process when necessary
        //state.map_data_dirty = false;
    }

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
    const rect = uvsForTile(state, tile);
    const uv0 = ImVec2{.x = rect.x, .y = rect.y};
    const uv1 = ImVec2{.x = rect.x + rect.w, .y = rect.y + rect.h};

    ImDrawList_AddImage(igGetWindowDrawList(), state.texture.tex, tl, br, uv0, uv1, 0xffffffff);
}

fn uvsForTile(state: *tk.AppState, tile: usize) aya.math.Rect {
    const x = @intToFloat(f32, @mod(tile, state.tilesPerRow()));
    const y = @intToFloat(f32, @divTrunc(tile, state.tilesPerRow()));

    const inv_w = 1.0 / @intToFloat(f32, state.texture.width);
    const inv_h = 1.0 / @intToFloat(f32, state.texture.height);

    return .{
        .x = x * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) * inv_w,
        .y = y * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) * inv_h,
        .w = @intToFloat(f32, state.map.tile_size) * inv_w,
        .h = @intToFloat(f32, state.map.tile_size) * inv_h,
    };
}
