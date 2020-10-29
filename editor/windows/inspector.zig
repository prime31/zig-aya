const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
usingnamespace @import("imgui");

pub fn draw(state: *root.AppState) void {
    defer igEnd();
    if (!igBegin("Inspector", null, ImGuiWindowFlags_None)) return;

    _ = ogButton("word to your mother");

    var v = aya.math.Vec2{ .x = 6, .y = 55 };
    inspectVec2("Position", &v);
    inspectVec2("Fart", &v);
    inspectVec2("Big Longer Name", &v);
    inspectFloat("Floaty", &v.x);
    inspectFloat("Other One", &v.y);

    // context delete sample
    if (igBeginPopupContextItem("woot", ImGuiMouseButton_Right)) {
        if (igMenuItemBool("Delete Me", null, false, true)) {}
        igEndPopup();
    }

    if (ogButton("Add Component")) {
        igOpenPopup("AddComponent");
    }

    if (igBeginPopup("AddComponent", ImGuiWindowFlags_None)) {
        if (igMenuItemBool("Camera", null, false, true)) {}
        if (igMenuItemBool("Sprite", null, false, true)) {}
        igEndPopup();
    }
}

fn inspectFloat(name: [:0]const u8, value: *f32) void {
    igPushIDPtr(value);

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(name);
    igNextColumn();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (igButton("R", button_size)) value.* = 0;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", value, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igColumns(1, null, false);
    igPopID();
}

fn inspectVec2(name: [:0]const u8, vec: *aya.math.Vec2) void {
    igPushIDPtr(vec);

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(name);
    igNextColumn();

    igPushMultiItemsWidths(2, igCalcItemWidth() + 20);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(204, 26, 38));
    if (igButton("X", button_size)) vec.*.x = 0;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", &vec.x, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igSameLine(0, 0);
    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(51, 178, 51));
    if (igButton("Y", button_size)) vec.*.y = 0;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##y", &vec.y, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igColumns(1, null, false);
    igPopID();
}
