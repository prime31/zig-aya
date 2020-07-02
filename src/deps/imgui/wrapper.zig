usingnamespace @import("imgui.zig");
const aya = @import("../../aya.zig");
pub const fonts = @import("font_awesome.zig");

pub fn ogButton(label: [*c]const u8) bool {
    return igButton(label, ImVec2{});
}

pub fn ogImage(texture: aya.gfx.Texture) void {
    const white = ImVec4{.x = 1, .y = 1, .z = 1, .w = 1};
    const size = ImVec2{.x = @intToFloat(f32, texture.width), .y = @intToFloat(f32, texture.height)};
    igImage(texture.tex, size, ImVec2{}, ImVec2{.x = 1, .y = 1}, white, ImVec4{});
}

pub fn ogGetCursorScreenPos() ImVec2 {
    var pos = ImVec2{};
    igGetCursorScreenPos(&pos);
    return pos;
}

pub fn ogGetCursorPos() ImVec2 {
    var pos = ImVec2{};
    igGetCursorPos(&pos);
    return pos;
}

pub fn ogGetContentRegionAvail() ImVec2 {
    var pos = ImVec2{};
    igGetContentRegionAvail(&pos);
    return pos;
}

pub fn ogAddQuad(draw_list: [*c]ImDrawList, tl: ImVec2, size: f32, col: ImU32, thickness: f32) void {
    ImDrawList_AddQuad(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y + size }, ImVec2{ .x = tl.x, .y = tl.y + size }, col, thickness);
}

pub fn ogAddQuadFilled(draw_list: [*c]ImDrawList, tl: ImVec2, size: f32, col: ImU32) void {
    ImDrawList_AddQuadFilled(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y }, ImVec2{ .x = tl.x + size, .y = tl.y + size }, ImVec2{ .x = tl.x, .y = tl.y + size }, col);
}

/// adds a rect with possibly non-matched width/height to the draw list
pub fn ogAddRectFilled(draw_list: [*c]ImDrawList, tl: ImVec2, size: ImVec2, col: ImU32) void {
    ImDrawList_AddQuadFilled(draw_list, ImVec2{ .x = tl.x, .y = tl.y }, ImVec2{ .x = tl.x + size.x, .y = tl.y }, ImVec2{ .x = tl.x + size.x, .y = tl.y + size.y }, ImVec2{ .x = tl.x, .y = tl.y + size.y }, col);
}

pub fn ogInputText(label: [*c]const u8, buf: [*c]u8, buf_size: usize) bool {
    return igInputText(label, buf, buf_size, ImGuiInputTextFlags_None, null, null);
}

pub fn ogDragUsize(label: [*c]const u8, p_data: *usize, v_speed: f32, p_min: usize, p_max: usize) bool {
    var min = p_min;
    var max = p_max;
    return igDragScalar(label, ImGuiDataType_U64, p_data, v_speed, &min, &max, null, 1);
}
