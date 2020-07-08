const std = @import("std");
usingnamespace @import("imgui");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
const colors = @import("../colors.zig");
const processor = @import("../rule_processor.zig");
const object_editor = @import("object_editor.zig");

var dragged_obj_index: ?usize = null;

pub fn drawWindow(state: *tk.AppState) void {
    // only process map data when it changes
    if (state.map_data_dirty) {
        processor.generateProcessedMap(state);
        processor.generateOutputMap(state);
        // TODO: fix this to only process when necessary
        //state.map_data_dirty = false;
    }

    if (state.prefs.windows.output_map and igBegin("Output Map", &state.prefs.windows.output_map, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar)) {
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
            const tile = state.final_map_data[x + y * state.map.w];
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
            drawTile(state, tl, tile - 1);
        }
    }

    // draw objects
    if (state.prefs.show_objects) {
        for (state.map.objects.items) |obj, i| {
            const tl = ImVec2{ .x = origin.x + @intToFloat(f32, obj.x) * state.map_rect_size, .y = origin.y + @intToFloat(f32, obj.y) * state.map_rect_size };
            const color = if (dragged_obj_index != null and dragged_obj_index.? == i) colors.object_selected else colors.object;
            ogAddQuad(igGetWindowDrawList(), tl, state.map_rect_size, color, 1);
        }
    }

    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        handleInput(state, origin);
    } else {
        dragged_obj_index = null;
    }
}

fn handleInput(state: *tk.AppState, origin: ImVec2) void {
    // scrolling via drag with alt key down
    if (igIsMouseDragging(ImGuiMouseButton_Left, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
        var scroll_delta = ImVec2{};
        igGetMouseDragDelta(&scroll_delta, 0, 0);

        igSetScrollXFloat(igGetScrollX() - scroll_delta.x);
        igSetScrollYFloat(igGetScrollY() - scroll_delta.y);
        igResetMouseDragDelta(ImGuiMouseButton_Left);
        return;
    }

    if (!state.object_edit_mode) {
        return;
    }

    if (igIsMouseClicked(ImGuiMouseButton_Left, false)) {
        // figure out if we clicked on any of our objects
        var tile = tk.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), origin);
        for (state.map.objects.items) |obj, i| {
            if (obj.x == tile.x and obj.y == tile.y) {
                dragged_obj_index = i;
                object_editor.setSelectedObject(i);
                @import("objects.zig").setSelectedObject(i);
                break;
            }
        }
    } else if (dragged_obj_index != null and igIsMouseDragging(ImGuiMouseButton_Left, 0)) {
        var tile = tk.tileIndexUnderMouse(@floatToInt(usize, state.map_rect_size), origin);
        var obj = &state.map.objects.items[dragged_obj_index.?];
        obj.x = tile.x;
        obj.y = tile.y;
    } else if (dragged_obj_index != null and igIsMouseReleased(ImGuiMouseButton_Left)) {
        dragged_obj_index = null;
    }
}

fn drawTile(state: *tk.AppState, tl: ImVec2, tile: usize) void {
    var br = tl;
    br.x += @intToFloat(f32, state.map.tile_size * state.prefs.tile_size_multiplier);
    br.y += @intToFloat(f32, state.map.tile_size * state.prefs.tile_size_multiplier);

    const rect = tk.uvsForTile(state, tile);
    const uv0 = ImVec2{ .x = rect.x, .y = rect.y };
    const uv1 = ImVec2{ .x = rect.x + rect.w, .y = rect.y + rect.h };

    ImDrawList_AddImage(igGetWindowDrawList(), state.texture.tex, tl, br, uv0, uv1, 0xffffffff);
}
