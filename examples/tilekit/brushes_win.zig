const std = @import("std");
const colors = @import("colors.zig");
usingnamespace @import("imgui");

pub var selected_brush_index: usize = 0;

const rect_size: f32 = 32;
const canvas_size = 6 * rect_size;
const thickness: f32 = 2;

pub fn drawWindow(open: *bool) void {
    if (open.* and igBegin("Brushes", open, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize)) {
        draw(false);
        igEnd();
    }
}

pub fn drawPopup() void {
    var pos = igGetIO().MousePos;
    pos.x -= rect_size * 6 / 2;
    pos.y -= rect_size * 6 / 2;
    igSetNextWindowPos(pos, ImGuiCond_Appearing, ImVec2{});
    if (igBeginPopup("brushes", ImGuiWindowFlags_NoTitleBar)) {
        draw(true);
        igEndPopup();
    }
}

fn draw(popup: bool) void {
    const draw_list = igGetWindowDrawList();

    var pos = ImVec2{};
    igGetCursorScreenPos(&pos);
    _ = igInvisibleButton("##but", ImVec2{ .x = canvas_size, .y = canvas_size });
    const mouse_pos = igGetIO().MousePos;
    const hovered = igIsItemHovered(ImGuiHoveredFlags_None);

    var y: usize = 0;
    while (y < 6) : (y += 1) {
        var x: usize = 0;
        while (x < 6) : (x += 1) {
            const index = x + y * 6;
            const offset_x = @intToFloat(f32, x) * rect_size;
            const offset_y = @intToFloat(f32, y) * rect_size;
            var tl = ImVec2{ .x = pos.x + offset_x, .y = pos.y + offset_y };

            drawBrush(index, tl);

            if (index == selected_brush_index) {
                const size = rect_size - thickness;
                tl.x += thickness / 2;
                tl.y += thickness / 2;
                ImDrawList_AddQuad(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y + size }, ImVec2{ .x = tl.x, .y = tl.y + size }, colors.brush_selected, 2);
            }

            if (hovered) {
                if (tl.x <= mouse_pos.x and mouse_pos.x < tl.x + rect_size and tl.y <= mouse_pos.y and mouse_pos.y < tl.y + rect_size) {
                    if (igIsMouseClicked(0, false)) {
                        selected_brush_index = index;
                    }
                }
            }
        }
    }
}

pub fn drawBrush(index: usize, tl: ImVec2) void {
    // we have 14 unique clors so collapse our index
    const color_index = @mod(index, 14);
    const set = @divTrunc(index, 14);

    ImDrawList_AddQuadFilled(igGetWindowDrawList(), ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + rect_size, .y = tl.y }, ImVec2{ .x = tl.x + rect_size, .y = tl.y + rect_size }, ImVec2{ .x = tl.x, .y = tl.y + rect_size }, colors.brushes[color_index]);

    const mini_size = rect_size / 2;
    var pt = tl;
    pt.x += (rect_size - mini_size) / 2;
    pt.y += (rect_size - mini_size) / 2;

    if (set == 1) {
        ImDrawList_AddQuadFilled(igGetWindowDrawList(), ImVec2{ .x = pt.x, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y + mini_size }, ImVec2{ .x = pt.x, .y = pt.y + mini_size }, colors.colorRgba(0, 0, 0, 100));
    } else if (set == 2) {
        ImDrawList_AddQuad(igGetWindowDrawList(), ImVec2{ .x = pt.x, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y }, ImVec2{ .x = pt.x + mini_size, .y = pt.y + mini_size }, ImVec2{ .x = pt.x, .y = pt.y + mini_size }, colors.colorRgba(0, 0, 0, 150), 1);
    }
}
