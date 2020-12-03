const std = @import("std");
const aya = @import("aya");
const root = @import("root");
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
    if (ogButtonEx(icons.redo, button_size)) value.* = reset_value;
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
    if (ogButtonEx(icons.redo, button_size)) value.* = reset_value;
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
    if (ogButtonEx(icons.redo, button_size)) value.* = reset_value;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", value, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igColumns(1, null, false);
}

pub fn inspectVec2(label: [:0]const u8, vec: *aya.math.Vec2, reset_value: aya.math.Vec2) void {
    igPushIDPtr(vec);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushMultiItemsWidths(2, (ogGetContentRegionAvail().x - 40));

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(204, 26, 38));
    if (ogButtonEx("X", button_size)) vec.*.x = reset_value.x;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", &vec.x, 0.1, 0, 0, "%.2f");
    igPopItemWidth();

    igSameLine(0, 0);
    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(51, 178, 51));
    if (ogButtonEx("Y", button_size)) vec.*.y = reset_value.y;
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
        if (ogButtonEx(icons.redo, button_size)) aya.mem.copyZ(u8, buf[0..buf_size], res_value);
        igPopStyleColor(1);

        igSameLine(0, 0);
    }

    _ = ogInputText("##", buf, buf_size);
    igPopItemWidth();

    igColumns(1, null, false);
}

pub fn inspectTexture(label: [:0]const u8, tex: *aya.gfx.Texture) void {
    igPushIDPtr(tex);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushItemWidth(-1);

    const max_dim = std.math.max(tex.width, tex.height);
    const multiplier = 50 / max_dim;

    if (ogImageButton(tex.imTextureID(), .{ .x = tex.width * multiplier, .y = tex.height * multiplier }, .{}, .{ .x = 1, .y = 1 }, 5))
        igOpenPopup("##texture-chooser", ImGuiPopupFlags_None);
    igPopItemWidth();

    igColumns(1, null, false);

    // texture chooser popup
    if (igBeginPopup("##texture-chooser", ImGuiWindowFlags_None)) {
        defer igEndPopup();
        igText("texture chooser");
    }
}

pub fn inspectOrigin(label: [:0]const u8, vec: *aya.math.Vec2, image_size: aya.math.Vec2) void {
    igPushIDPtr(vec);
    defer igPopID();

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();

    igPushMultiItemsWidths(2, (ogGetContentRegionAvail().x - 65));

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(204, 26, 38));
    if (ogButtonEx("X", button_size)) vec.*.x = 0;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", &vec.x, 0.1, -image_size.x, image_size.x, "%.2f");
    igPopItemWidth();

    igSameLine(0, 0);
    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(51, 178, 51));
    if (ogButtonEx("Y", button_size)) vec.*.y = 0;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##y", &vec.y, 0.1, -image_size.y, image_size.y, "%.2f");
    igPopItemWidth();

    igSameLine(0, 5);
    if (ogButton(icons.bullseye)) igOpenPopup("##origin-selector", ImGuiPopupFlags_None);

    igColumns(1, null, false);

    if (igBeginPopup("##origin-selector", ImGuiWindowFlags_None)) {
        igText("Origin:");

        if (ogButton(icons.circle ++ "##tl")) vec.* = .{}; // tl

        igSameLine(0, 7);
        if (ogButton(icons.arrow_up ++ "##tc")) vec.* = .{ .x = image_size.x / 2 }; // tc

        igSameLine(0, 7);
        if (ogButton(icons.circle ++ "##tr")) vec.* = .{ .x = image_size.x}; // tr

        // middle row
        if (ogButton(icons.arrow_left ++ "##ml")) vec.* = .{ .x = 0, .y = image_size.y / 2 }; // ml

        igSameLine(0, 7);
        if (ogButton(icons.bullseye ++ "##mc")) vec.* = .{ .x = image_size.x / 2, .y = image_size.y / 2 }; // c

        igSameLine(0, 7);
        if (ogButton(icons.arrow_right ++ "##mr")) vec.* = .{ .x = image_size.x, .y = image_size.y / 2 }; // mr

        // bottom row
        if (ogButton(icons.circle ++ "##bl")) vec.* = .{ .x = 0, .y = image_size.y }; // bl

        igSameLine(0, 7);
        if (ogButton(icons.arrow_down ++ "##bm")) vec.* = .{ .x = image_size.x / 2, .y = image_size.y }; // bm

        igSameLine(0, 7);
        if (ogButton(icons.circle ++ "##br")) vec.* = .{ .x = image_size.x, .y = image_size.y }; // br

        igEndPopup();
    }
}

pub fn inspectSprite(sprite: *root.data.Sprite) void {
    inspectTexture("Texture", &sprite.tex);
    inspectOrigin("Origin", &sprite.origin, .{ .x = sprite.tex.width, .y = sprite.tex.height });
}

pub fn inspectCollider(collider: *root.data.Collider) void {
    switch (collider.*) {
        .box => |*box| {
            inspectVec2("Offset", &box.offset, .{});
            inspectFloat("Width", &box.w, 25);
            inspectFloat("Height", &box.h, 25);
        },
        .circle => |*circle| {
            inspectVec2("Offset", &circle.offset, .{});
            inspectFloat("Radius", &circle.r, 25);
        },
    }
}

pub fn inspectTransform(transform: *root.data.Transform) void {
    inspectVec2("Position", &transform.pos, .{});
    inspectFloat("Rotation", &transform.rot, 0);
    inspectVec2("Scale", &transform.scale, .{ .x = 1, .y = 1 });
}
