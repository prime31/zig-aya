const std = @import("std");
const aya = @import("aya");
const root = @import("root");
const imgui = @import("imgui");
const icons = imgui.icons;
const AppState = root.data.AppState;

// entity link state
var filter_buffer: [25:0]u8 = undefined;
var filter_entities = false;

fn beginColumns(label: [:0]const u8, ptr_id: ?*const anyopaque) void {
    imgui.igPushIDPtr(ptr_id);

    imgui.igColumns(2, null, false);
    imgui.igSetColumnWidth(0, 100);
    imgui.igText(label);
    imgui.igNextColumn();
}

fn endColumns() void {
    imgui.igColumns(1, null, false);
    imgui.igPopID();
}

pub fn inspectBool(label: [:0]const u8, value: *bool, reset_value: bool) void {
    beginColumns(label, value);
    defer endColumns();

    imgui.igPushItemWidth(-1);

    const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
    const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (imgui.ogButtonEx(icons.redo, button_size)) value.* = reset_value;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);
    _ = imgui.igCheckbox("##bool", value);
    imgui.igPopItemWidth();
}

pub fn inspectInt(label: [:0]const u8, value: *i32, reset_value: i32) void {
    beginColumns(label, value);
    defer endColumns();

    imgui.igPushItemWidth(-1);

    const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
    const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (imgui.ogButtonEx(icons.redo, button_size)) value.* = reset_value;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);
    _ = imgui.ogDragSignedFormat(i32, "##int", value, 0.1, 0, 0, null);
    imgui.igPopItemWidth();
}

pub fn inspectFloat(label: [:0]const u8, value: *f32, reset_value: f32) void {
    inspectFloatMinMax(label, value, reset_value, 0, 0);
}

/// note that BOTH min and max must be non-zero or Dear ImGui seems to imgui.ignore them entirely...
pub fn inspectFloatMinMax(label: [:0]const u8, value: *f32, reset_value: f32, min: f32, max: f32) void {
    beginColumns(label, value);
    defer endColumns();

    imgui.igPushItemWidth(-1);

    const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
    const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (imgui.ogButtonEx(icons.redo, button_size)) value.* = reset_value;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);
    _ = imgui.ogDragSignedFormat(f32, "##x", value, 0.1, min, max, "%.2f");
    imgui.igPopItemWidth();
}

pub fn inspectVec2(label: [:0]const u8, vec: *aya.math.Vec2, reset_value: aya.math.Vec2) void {
    beginColumns(label, vec);
    defer endColumns();

    imgui.igPushMultiItemsWidths(2, (imgui.ogGetContentRegionAvail().x - 40));

    const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
    const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(204, 26, 38));
    if (imgui.ogButtonEx("X", button_size)) vec.*.x = reset_value.x;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);
    _ = imgui.ogDragSignedFormat(f32, "##x", &vec.x, 0.1, 0, 0, "%.2f");
    imgui.igPopItemWidth();

    imgui.igSameLine(0, 0);
    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(51, 178, 51));
    if (imgui.ogButtonEx("Y", button_size)) vec.*.y = reset_value.y;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);
    _ = imgui.ogDragSignedFormat(f32, "##y", &vec.y, 0.1, 0, 0, "%.2f");
    imgui.igPopItemWidth();
}

pub fn inspectString(label: [:0]const u8, buf: [*c]u8, buf_size: usize, reset_value: ?[:0]const u8) void {
    beginColumns(label, buf);
    defer endColumns();

    imgui.igPushItemWidth(-1);

    if (reset_value) |res_value| {
        const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
        const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

        imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
        if (imgui.ogButtonEx(icons.redo, button_size)) aya.mem.copyZ(u8, buf[0..buf_size], res_value);
        imgui.igPopStyleColor(1);

        imgui.igSameLine(0, 0);
    }

    _ = imgui.ogInputText("##", buf, buf_size);
    imgui.igPopItemWidth();
}

pub fn inspectEntityLink(label: [:0]const u8, entity_id: u8, link: *u8, entities: std.ArrayList(root.data.Entity)) void {
    beginColumns(label, link);
    defer endColumns();

    imgui.igPushItemWidth(-1);

    const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
    const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (imgui.ogButtonEx(icons.redo, button_size)) link.* = 0;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);

    // figure out our label text
    var name: [25:0]u8 = undefined;
    if (link.* > 0) {
        for (entities.items) |entity| {
            if (entity.id == link.*) {
                name = entity.name;
                break;
            }
        }
    } else {
        _ = std.fmt.bufPrint(&name, "Choose...", .{}) catch unreachable;
    }

    if (imgui.ogButtonEx(&name, .{ .x = -1 })) imgui.igOpenPopup("##entity-chooser", imgui.ImGuiPopupFlags_None);
    imgui.igPopItemWidth();

    // entity chooser popup
    if (imgui.igBeginPopup("##entity-chooser", imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEndPopup();

        imgui.igPushItemWidth(imgui.igGetWindowContentRegionWidth());
        if (imgui.ogInputText("##obj-filter", &filter_buffer, filter_buffer.len)) {
            const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
            filter_entities = null_index > 0;
        }
        imgui.igPopItemWidth();

        for (entities.items) |entity| {
            if (filter_entities) {
                const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                if (std.mem.indexOf(u8, &entity.name, filter_buffer[0..null_index]) == null)
                    continue;
            }

            // dont allow linking to self
            if (entity.id == entity_id) continue;

            if (imgui.igSelectableBool(&entity.name, entity.id == link.*, imgui.ImGuiSelectableFlags_None, .{})) {
                link.* = entity.id;
                std.mem.set(u8, &filter_buffer, 0);
                filter_entities = false;
                imgui.igCloseCurrentPopup();
            }
        }
    }
}

pub fn inspectSpriteTexture(state: *AppState, sprite: *root.data.Sprite) void {
    beginColumns("Texture", &sprite.tex);
    defer endColumns();

    imgui.igPushItemWidth(-1);

    // const max_dim = std.math.max(sprite.tex.width, sprite.tex.height);
    // const multiplier = 50 / max_dim;

    const thumb_uvs = state.asset_man.getUvsForThumbnail(sprite.tex_name);
    const thumb_tex = if (sprite.tex.img == state.asset_man.default_tex.img) sprite.tex else state.asset_man.thumbnails.tex;
    if (imgui.ogImageButton(thumb_tex.imTextureID(), .{ .x = 75, .y = 75 }, thumb_uvs.tl, thumb_uvs.br, 5)) {
        imgui.igOpenPopup("##texture-chooser", imgui.ImGuiPopupFlags_None);
        std.mem.set(u8, &filter_buffer, 0);
    }
    imgui.igPopItemWidth();

    // texture chooser popup
    const popup_height = imgui.ogGetWindowSize().y - imgui.ogGetCursorScreenPos().y;
    imgui.ogSetNextWindowPos(imgui.ogGetCursorScreenPos(), imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    imgui.ogSetNextWindowSize(.{ .x = 75 * 3 + imgui.igGetStyle().ItemSpacing.x * 6, .y = popup_height }, imgui.ImGuiCond_Always);

    if (imgui.igBeginPopup("##texture-chooser", imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEndPopup();

        imgui.igPushItemWidth(imgui.igGetWindowContentRegionWidth());
        if (imgui.ogInputText("##texture-filter", &filter_buffer, filter_buffer.len)) {
            const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
            filter_entities = null_index > 0;
        }
        imgui.igPopItemWidth();

        var displayed_count: usize = 0;
        for (state.asset_man.thumbnails.names, 0..) |asset_name, i| {
            if (filter_entities) {
                const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                if (std.mem.indexOf(u8, asset_name, filter_buffer[0..null_index]) == null)
                    continue;
            }

            imgui.igPushIDInt(@intCast(c_int, i));
            defer imgui.igPopID();
            displayed_count += 1;

            imgui.igBeginGroup();

            const uvs = state.asset_man.getUvsForThumbnailAtIndex(i);
            if (imgui.ogImageButton(state.asset_man.thumbnails.tex.imTextureID(), .{ .x = 75, .y = 75 }, uvs.tl, uvs.br, 0)) {
                const tex_rect = state.asset_man.getTextureAndRect(asset_name);
                sprite.updateTexture(tex_rect.tex, tex_rect.rect, asset_name);
                imgui.igCloseCurrentPopup();
            }

            const base_name = asset_name[0..std.mem.indexOfScalar(u8, asset_name, '.').?];
            var name_buf: [12:0]u8 = undefined;
            std.mem.set(u8, &name_buf, 0);

            if (base_name.len > 11) {
                std.mem.copy(u8, &name_buf, base_name[0..11]);
            } else {
                std.mem.copy(u8, &name_buf, base_name);
            }

            imgui.igText(&name_buf);
            imgui.igEndGroup();

            if (displayed_count % 3 == 0) {
                imgui.ogDummy(.{ .y = 10 });
            } else {
                imgui.igSameLine(0, imgui.igGetStyle().ItemSpacing.x);
            }
        }
    }
}

pub fn inspectOrigin(label: [:0]const u8, vec: *aya.math.Vec2, image_size: aya.math.Vec2) void {
    beginColumns(label, vec);
    defer endColumns();

    imgui.igPushMultiItemsWidths(2, (imgui.ogGetContentRegionAvail().x - 65));

    const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
    const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(204, 26, 38));
    if (imgui.ogButtonEx("X", button_size)) vec.*.x = 0;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);
    _ = imgui.ogDragSignedFormat(f32, "##x", &vec.x, 0.1, -image_size.x, image_size.x, "%.2f");
    imgui.igPopItemWidth();

    imgui.igSameLine(0, 0);
    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(51, 178, 51));
    if (imgui.ogButtonEx("Y", button_size)) vec.*.y = 0;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);
    _ = imgui.ogDragSignedFormat(f32, "##y", &vec.y, 0.1, -image_size.y, image_size.y, "%.2f");
    imgui.igPopItemWidth();

    imgui.igSameLine(0, 5);
    if (imgui.ogButton(icons.bullseye)) imgui.igOpenPopup("##origin-selector", imgui.ImGuiPopupFlags_None);

    if (imgui.igBeginPopup("##origin-selector", imgui.ImGuiWindowFlags_None)) {
        imgui.igText("Origin:");

        if (imgui.ogButton(icons.circle ++ "##tl")) vec.* = .{}; // tl

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(icons.arrow_up ++ "##tc")) vec.* = .{ .x = image_size.x / 2 }; // tc

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(icons.circle ++ "##tr")) vec.* = .{ .x = image_size.x }; // tr

        // middle row
        if (imgui.ogButton(icons.arrow_left ++ "##ml")) vec.* = .{ .x = 0, .y = image_size.y / 2 }; // ml

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(icons.bullseye ++ "##mc")) vec.* = .{ .x = image_size.x / 2, .y = image_size.y / 2 }; // c

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(icons.arrow_right ++ "##mr")) vec.* = .{ .x = image_size.x, .y = image_size.y / 2 }; // mr

        // bottom row
        if (imgui.ogButton(icons.circle ++ "##bl")) vec.* = .{ .x = 0, .y = image_size.y }; // bl

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(icons.arrow_down ++ "##bm")) vec.* = .{ .x = image_size.x / 2, .y = image_size.y }; // bm

        imgui.igSameLine(0, 7);
        if (imgui.ogButton(icons.circle ++ "##br")) vec.* = .{ .x = image_size.x, .y = image_size.y }; // br

        imgui.igEndPopup();
    }
}

pub fn inspectSprite(state: *AppState, sprite: *root.data.Sprite) void {
    inspectSpriteTexture(state, sprite);
    inspectOrigin("Origin", &sprite.origin, .{ .x = @intToFloat(f32, sprite.rect.w), .y = @intToFloat(f32, sprite.rect.h) });
}

pub fn inspectCollider(collider: *root.data.Collider) void {
    switch (collider.*) {
        .box => |*box| {
            inspectBool("Trigger", &box.trigger, false);
            inspectVec2("Offset", &box.offset, .{});
            inspectFloatMinMax("Width", &box.w, 25, 1, std.math.f32_max);
            inspectFloatMinMax("Height", &box.h, 25, 1, std.math.f32_max);
        },
        .circle => |*circle| {
            inspectBool("Trigger", &circle.trigger, false);
            inspectVec2("Offset", &circle.offset, .{});
            inspectFloatMinMax("Radius", &circle.r, 25, 5, std.math.f32_max);
        },
    }
}

pub fn inspectTransform(transform: *root.data.Transform) void {
    inspectVec2("Position", &transform.pos, .{});
    inspectFloatMinMax("Rotation", &transform.rot, 0, -360, 360);
    inspectVec2("Scale", &transform.scale, .{ .x = 1, .y = 1 });
}

pub fn inspectEnum(label: [:0]const u8, value: *u8, enum_values: [][25:0]u8) void {
    beginColumns(label, value);
    defer endColumns();

    imgui.igPushItemWidth(-1);

    const line_height = imgui.GImGui.*.FontSize + imgui.igGetStyle().FramePadding.y * 2;
    const button_size = imgui.ImVec2{ .x = line_height + 3, .y = line_height };

    imgui.igPushStyleColorU32(imgui.ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (imgui.ogButtonEx(icons.redo, button_size)) value.* = 0;
    imgui.igPopStyleColor(1);

    imgui.igSameLine(0, 0);

    if (enum_values.len == 0) {
        imgui.igText("No enum values set");
    } else if (imgui.igBeginCombo("##enum", &enum_values[value.*], imgui.ImGuiComboFlags_None)) {
        defer imgui.igEndCombo();

        for (enum_values, 0..) |enum_label, i| {
            if (imgui.igSelectableBool(&enum_label, value.* == i, imgui.ImGuiSelectableFlags_None, .{ .y = line_height }))
                value.* = @intCast(u8, i);
        }
    }
}
