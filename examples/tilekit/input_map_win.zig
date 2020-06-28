const std = @import("std");
usingnamespace @import("imgui");
const colors = @import("colors.zig");
const tk = @import("tilekit.zig");

// helper to maintain state during a drag selection
var drag_rect_data = struct {
    dragged: bool = false,
    drag_tl: ImVec2 = ImVec2{},
    drag_br: ImVec2 = ImVec2{},
}{};

pub fn drawWindow(state: *tk.AppState) void {
    if (state.input_map and igBegin("Input Map", &state.input_map, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysHorizontalScrollbar)) {
        draw(state);
        igEnd();
    }
}

fn draw(state: *tk.AppState) void {
    var pos = ImVec2{};
    igGetCursorScreenPos(&pos);
    // std.debug.print("pos: {d}\n", .{pos});

    _ = igInvisibleButton("##input_map_button", ImVec2{ .x = @intToFloat(f32, state.map.w) * state.map_rect_size, .y = @intToFloat(f32, state.map.h) * state.map_rect_size });
    if (igIsItemHovered(ImGuiHoveredFlags_None)) handleInput(state, pos);

    var y: usize = 0;
    while (y < state.map.h) : (y += 1) {
        var x: usize = 0;
        while (x < state.map.w) : (x += 1) {
            const tile = state.map.getTile(x, y);
            if (tile == 0) continue;

            const offset_x = @intToFloat(f32, x) * state.map_rect_size;
            const offset_y = @intToFloat(f32, y) * state.map_rect_size;
            var tl = ImVec2{ .x = pos.x + offset_x, .y = pos.y + offset_y };
            tk.drawBrush(state.map_rect_size, tile - 1, tl);
        }
    }
}

fn handleInput(state: *tk.AppState, screen_space_offset: ImVec2) void {
    // scrolling via drag with alt key down
    if (igIsMouseDragging(0, 0) and igGetIO().KeyAlt) {
        var scroll_delta = ImVec2{};
        igGetMouseDragDelta(&scroll_delta, 0, 0);

        igSetScrollXFloat(igGetScrollX() + scroll_delta.x * 2);
        igSetScrollYFloat(igGetScrollY() + scroll_delta.y * 2);
        igResetMouseDragDelta(0);
    }

    if (igIsMouseDragging(0, 0) and igGetIO().KeyShift) {
        var drag_delta = ImVec2{};
        igGetMouseDragDelta(&drag_delta, 0, 0);

        // translate into world local space so we can get our selection clamped to our rect size then translate back to screen space
        var tl = igGetIO().MouseClickedPos[0];
        tl.x -= screen_space_offset.x;
        tl.y -= screen_space_offset.y;
        tl.x = tl.x - @mod(tl.x, state.map_rect_size);
        tl.y = tl.y - @mod(tl.y, state.map_rect_size);
        tl.x += screen_space_offset.x;
        tl.y += screen_space_offset.y;

        // clamp to a multiple of our rect size rounding up
        const width = drag_delta.x + state.map_rect_size - 1 - @mod(drag_delta.x - 1, state.map_rect_size);
        const height = drag_delta.y + state.map_rect_size - 1 - @mod(drag_delta.y - 1, state.map_rect_size);

        ImDrawList_AddQuad(igGetWindowDrawList(), tl, ImVec2{ .x = tl.x + width, .y = tl.y }, ImVec2{ .x = tl.x + width, .y = tl.y + height }, ImVec2{ .x = tl.x, .y = tl.y + height }, colors.colorRgb(255, 255, 0), 2);

        drag_rect_data.dragged = true;
        drag_rect_data.drag_tl = tl;
        drag_rect_data.drag_tl.x -= screen_space_offset.x;
        drag_rect_data.drag_tl.y -= screen_space_offset.y;

        drag_rect_data.drag_br = drag_rect_data.drag_tl;
        drag_rect_data.drag_br.x += width;
        drag_rect_data.drag_br.y += height;
        return;
    }

    if (igIsMouseReleased(0) and drag_rect_data.dragged) {
        drag_rect_data.dragged = false;
        var start_x = @divTrunc(@floatToInt(c_int, drag_rect_data.drag_tl.x), @floatToInt(c_int, state.map_rect_size));
        var start_y = @divTrunc(@floatToInt(c_int, drag_rect_data.drag_tl.y), @floatToInt(c_int, state.map_rect_size));
        var end_x = @divTrunc(@floatToInt(c_int, drag_rect_data.drag_br.x - state.map_rect_size), @floatToInt(c_int, state.map_rect_size));
        var end_y = @divTrunc(@floatToInt(c_int, drag_rect_data.drag_br.y - state.map_rect_size), @floatToInt(c_int, state.map_rect_size));

        // if we dragged backwards swap the values and undo the ceil clamping that we did
        if (start_x > end_x) {
            std.mem.swap(c_int, &start_x, &end_x);
            start_x += 1;
            end_x -= 1;
        }
        if (start_y > end_y) {
            std.mem.swap(c_int, &start_y, &end_y);
            start_y += 1;
            end_y -= 1;
        }

        var y = start_y;
        while (y <= end_y) : (y += 1) {
            var x = start_x;
            while (x <= end_x) : (x += 1) {
                state.map.setTile(@intCast(usize, x), @intCast(usize, y), @intCast(u32, state.selected_brush_index + 1));
            }
        }
        std.debug.print("----------- {},{} - {},{}\n", .{start_x, start_y, end_x, end_y});
    }

    if (igIsMouseDown(0)) {
        var tile = tileIndexUnderMouse(state, screen_space_offset);
        state.map.setTile(tile.x, tile.y, @intCast(u32, state.selected_brush_index + 1));
    }

    if (igIsMouseDown(1)) {
        var tile = tileIndexUnderMouse(state, screen_space_offset);
        state.map.setTile(tile.x, tile.y, 0);
    }

    // _ = tileIndexUnderMouse(state, screen_space_offset);
}

fn tileIndexUnderMouse(state: *tk.AppState, screen_space_offset: ImVec2) struct { x: usize, y: usize } {
    var pos = igGetIO().MousePos;
    pos.x -= screen_space_offset.x;
    pos.y -= screen_space_offset.y;

    const x = @divTrunc(@floatToInt(c_int, pos.x), @floatToInt(c_int, state.map_rect_size));
    const y = @divTrunc(@floatToInt(c_int, pos.y), @floatToInt(c_int, state.map_rect_size));

    // std.debug.print("tile: {},{}  -  {d}\n", .{x, y, pos});

    return .{ .x = @intCast(usize, x), .y = @intCast(usize, y) };
}
