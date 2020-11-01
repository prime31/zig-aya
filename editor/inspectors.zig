const std = @import("std");
const aya = @import("aya");
const root = @import("main.zig");
usingnamespace @import("imgui");

pub fn inspectBool(label: [:0]const u8, value: *bool, reset_value: bool) void {
    igPushIDPtr(value);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (igButton(icons.redo, button_size)) value.* = reset_value;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = igCheckbox("##bool", value);
    igPopItemWidth();

    igColumns(1, null, false);
}

pub fn inspectInt(label: [:0]const u8, value: *i32, reset_value: i32) void {
    igPushIDPtr(value);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (igButton(icons.redo, button_size)) value.* = reset_value;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(i32, "##int", value, 0.1, 0, 0, null);
    igPopItemWidth();

    igColumns(1, null, false);
}

pub fn inspectFloat(label: [:0]const u8, value: *f32, reset_value: f32) void {
    igPushIDPtr(value);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (igButton(icons.redo, button_size)) value.* = reset_value;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", value, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igColumns(1, null, false);
}

pub fn inspectVec2(label: [:0]const u8, vec: *aya.math.Vec2, reset_value: aya.math.Vec2) void {
    igPushIDPtr(value);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushMultiItemsWidths(2, (ogGetContentRegionAvail().x - 40));

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(204, 26, 38));
    if (igButton("X", button_size)) vec.*.x = reset_value.x;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", &vec.x, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igSameLine(0, 0);
    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(51, 178, 51));
    if (igButton("Y", button_size)) vec.*.y = reset_value.y;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##y", &vec.y, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igColumns(1, null, false);
}

pub fn inspectString(label: [:0]const u8, buf: [*c]u8, buf_size: usize, reset_value: ?[:0]const u8) void {
    igPushIDPtr(buf);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushItemWidth(-1);

    if (reset_value) |res_value| {
        const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
        const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

        igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
        if (igButton(icons.redo, button_size)) aya.mem.copyZ(u8, buf[0..buf_size], res_value);
        igPopStyleColor(1);

        igSameLine(0, 0);
    }

    _ = ogInputText("##", buf, buf_size);
    igPopItemWidth();

    igColumns(1, null, false);
}
