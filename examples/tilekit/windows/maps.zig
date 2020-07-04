const std = @import("std");
usingnamespace @import("imgui");
const colors = @import("../colors.zig");
const history = @import("../history.zig");
const tk = @import("../tilekit.zig");

// helper to maintain state during a drag selection
var dragged = false;

pub fn drawWindows(state: *tk.AppState) void {
    if (state.windows.input_map and igBegin("Input Map", &state.windows.input_map, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar)) {
        draw(state, true);
        igEnd();
    }

    if (state.windows.post_processed_map and igBegin("Post Processed Map", &state.windows.post_processed_map, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar)) {
        draw(state, false);
        igEnd();
    }
}

fn draw(state: *tk.AppState, input_map: bool) void {
    var pos = ogGetCursorScreenPos();

    const map_size = state.mapSize();
    ogAddRectFilled(igGetWindowDrawList(), pos, map_size, colors.colorRgb(0, 0, 0));

    _ = igInvisibleButton("##input_map_button", map_size);
    const is_hovered = igIsItemHovered(ImGuiHoveredFlags_None);
    if (is_hovered) handleInput(state, pos);

    if (input_map) {
        drawInputMap(state, pos);
    } else {
        drawPostProcessedMap(state, pos);
    }

    // draw a rect over the current tile
    if (is_hovered and !dragged) {
        var tile = tileIndexUnderMouse(state, pos);
        const tl = ImVec2{ .x = pos.x + @intToFloat(f32, tile.x) * state.map_rect_size, .y = pos.y + @intToFloat(f32, tile.y) * state.map_rect_size };
        ogAddQuad(igGetWindowDrawList(), tl, state.map_rect_size, colors.rule_result_selected_outline, 1);
    }
}

fn drawInputMap(state: *tk.AppState, origin: ImVec2) void {
    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            const tile = state.map.data[x + y * state.map.w];
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
            tk.drawBrush(state.map_rect_size, tile - 1, tl);
        }
    }
}

fn drawPostProcessedMap(state: *tk.AppState, origin: ImVec2) void {
    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            const tile = state.processed_map_data[x + y * state.map.w];
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = origin.x + offset_x, .y = origin.y + offset_y };
            tk.drawBrush(state.map_rect_size, tile - 1, tl);
        }
    }
}

fn handleInput(state: *tk.AppState, screen_space_offset: ImVec2) void {
    // scrolling via drag with alt key down
    if (igIsMouseDragging(0, 0) and (igGetIO().KeyAlt or igGetIO().KeySuper)) {
        var scroll_delta = ImVec2{};
        igGetMouseDragDelta(&scroll_delta, 0, 0);

        igSetScrollXFloat(igGetScrollX() - scroll_delta.x);
        igSetScrollYFloat(igGetScrollY() - scroll_delta.y);
        igResetMouseDragDelta(0);
        return;
    }

    if (state.object_edit_mode) {
        return;
    }

    if (igIsMouseDragging(0, 0) and igGetIO().KeyShift) {
        var drag_delta = ogGetMouseDragDelta(0, 0);
        var tile1 = tileIndexUnderMouse(state, screen_space_offset);
        drag_delta.x += screen_space_offset.x;
        drag_delta.y += screen_space_offset.y;
        var tile2 = tileIndexUnderMouse(state, drag_delta);

        const min_x = @intToFloat(f32, std.math.min(tile1.x, tile2.x)) * state.map_rect_size + screen_space_offset.x;
        const min_y = @intToFloat(f32, std.math.max(tile1.y, tile2.y)) * state.map_rect_size + state.map_rect_size + screen_space_offset.y;
        const max_x = @intToFloat(f32, std.math.max(tile1.x, tile2.x)) * state.map_rect_size + state.map_rect_size + screen_space_offset.x;
        const max_y = @intToFloat(f32, std.math.min(tile1.y, tile2.y)) * state.map_rect_size + screen_space_offset.y;

        ImDrawList_AddQuad(igGetWindowDrawList(), ImVec2{ .x = min_x, .y = max_y }, ImVec2{ .x = max_x, .y = max_y }, ImVec2{ .x = max_x, .y = min_y }, ImVec2{ .x = min_x, .y = min_y }, colors.colorRgb(255, 255, 255), 2);

        dragged = true;
    } else if (igIsMouseReleased(0) and dragged) {
        dragged = false;

        var drag_delta = ogGetMouseDragDelta(0, 0);
        var tile1 = tileIndexUnderMouse(state, screen_space_offset);
        drag_delta.x += screen_space_offset.x;
        drag_delta.y += screen_space_offset.y;
        var tile2 = tileIndexUnderMouse(state, drag_delta);

        const min_x = std.math.min(tile1.x, tile2.x);
        var min_y = std.math.min(tile1.y, tile2.y);
        const max_x = std.math.max(tile1.x, tile2.x);
        const max_y = std.math.max(tile1.y, tile2.y);

        // undo support
        const start_index = min_x + min_y * state.map.w;
        const end_index = max_x + max_y * state.map.w;
        history.push(state.map.data[start_index..end_index + 1]);

        while (min_y <= max_y) : (min_y += 1) {
            var x = min_x;
            while (x <= max_x) : (x += 1) {
                state.map.setTile(x, min_y, @intCast(u8, state.selected_brush_index + 1));
            }
        }
        history.commit();
    } else if (igIsMouseDown(0) and !igGetIO().KeyShift) {
        var tile = tileIndexUnderMouse(state, screen_space_offset);

        const index = tile.x + tile.y * state.map.w;
        history.push(state.map.data[index..index + 1]);
        state.map.setTile(tile.x, tile.y, @intCast(u8, state.selected_brush_index + 1));

    } else if (igIsMouseReleased(0)) {
        history.commit();
    } else if (igIsMouseDown(1)) {
        var tile = tileIndexUnderMouse(state, screen_space_offset);

        const index = tile.x + tile.y * state.map.w;
        history.push(state.map.data[index..index + 1]);
        state.map.setTile(tile.x, tile.y, 0);
        history.commit();
    }
}

fn tileIndexUnderMouse(state: *tk.AppState, screen_space_offset: ImVec2) struct { x: usize, y: usize } {
    var pos = igGetIO().MousePos;
    pos.x -= screen_space_offset.x;
    pos.y -= screen_space_offset.y;

    const x = @divTrunc(@floatToInt(c_int, pos.x), @floatToInt(c_int, state.map_rect_size));
    const y = @divTrunc(@floatToInt(c_int, pos.y), @floatToInt(c_int, state.map_rect_size));

    return .{ .x = @intCast(usize, x), .y = @intCast(usize, y) };
}
