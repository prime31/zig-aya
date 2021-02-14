const std = @import("std");
const aya = @import("aya");
const root = @import("root");
usingnamespace @import("imgui");
const AppState = root.data.AppState;

// entity link state
var filter_buffer: [25:0]u8 = undefined;
var filter_entities = false;

fn beginColumns(label: [:0]const u8, ptr_id: ?*const c_void) void {
    igPushIDPtr(ptr_id);

    igColumns(2, null, false);
    igSetColumnWidth(0, 100);
    igText(label);
    igNextColumn();
}

fn endColumns() void {
    igColumns(1, null, false);
    igPopID();
}

pub fn inspectBool(label: [:0]const u8, value: *bool, reset_value: bool) void {
    beginColumns(label, value);
    defer endColumns();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (ogButtonEx(icons.redo, button_size)) value.* = reset_value;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = igCheckbox("##bool", value);
    igPopItemWidth();
}

pub fn inspectInt(label: [:0]const u8, value: *i32, reset_value: i32) void {
    beginColumns(label, value);
    defer endColumns();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (ogButtonEx(icons.redo, button_size)) value.* = reset_value;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(i32, "##int", value, 0.1, 0, 0, null);
    igPopItemWidth();
}

pub fn inspectFloat(label: [:0]const u8, value: *f32, reset_value: f32) void {
    inspectFloatMinMax(label, value, reset_value, 0, 0);
}

/// note that BOTH min and max must be non-zero or Dear ImGui seems to ignore them entirely...
pub fn inspectFloatMinMax(label: [:0]const u8, value: *f32, reset_value: f32, min: f32, max: f32) void {
    beginColumns(label, value);
    defer endColumns();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (ogButtonEx(icons.redo, button_size)) value.* = reset_value;
    igPopStyleColor(1);

    igSameLine(0, 0);
    _ = ogDragSignedFormat(f32, "##x", value, 0.1, min, max, "%.2f");
    igPopItemWidth();
}

pub fn inspectVec2(label: [:0]const u8, vec: *aya.math.Vec2, reset_value: aya.math.Vec2) void {
    beginColumns(label, vec);
    defer endColumns();

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
}

pub fn inspectString(label: [:0]const u8, buf: [*c]u8, buf_size: usize, reset_value: ?[:0]const u8) void {
    beginColumns(label, buf);
    defer endColumns();

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
}

pub fn inspectEntityLink(label: [:0]const u8, entity_id: u8, link: *u8, entities: std.ArrayList(root.data.Entity)) void {
    beginColumns(label, link);
    defer endColumns();

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (ogButtonEx(icons.redo, button_size)) link.* = 0;
    igPopStyleColor(1);

    igSameLine(0, 0);

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

    if (ogButtonEx(&name, .{ .x = -1 })) igOpenPopup("##entity-chooser", ImGuiPopupFlags_None);
    igPopItemWidth();

    // entity chooser popup
    if (igBeginPopup("##entity-chooser", ImGuiWindowFlags_None)) {
        defer igEndPopup();

        igPushItemWidth(igGetWindowContentRegionWidth());
        if (ogInputText("##obj-filter", &filter_buffer, filter_buffer.len)) {
            const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
            filter_entities = null_index > 0;
        }
        igPopItemWidth();

        for (entities.items) |entity| {
            if (filter_entities) {
                const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                if (std.mem.indexOf(u8, &entity.name, filter_buffer[0..null_index]) == null)
                    continue;
            }

            // dont allow linking to self
            if (entity.id == entity_id) continue;

            if (igSelectableBool(&entity.name, entity.id == link.*, ImGuiSelectableFlags_None, .{})) {
                link.* = entity.id;
                std.mem.set(u8, &filter_buffer, 0);
                filter_entities = false;
                igCloseCurrentPopup();
            }
        }
    }
}

pub fn inspectSpriteTexture(state: *AppState, sprite: *root.data.Sprite) void {
    beginColumns("Texture", &sprite.tex);
    defer endColumns();

    igPushItemWidth(-1);

    const max_dim = std.math.max(sprite.tex.width, sprite.tex.height);
    const multiplier = 50 / max_dim;

    const thumb_uvs = state.asset_man.getUvsForThumbnail(sprite.tex_name);
    const thumb_tex = if (sprite.tex.img == state.asset_man.default_tex.img) sprite.tex else state.asset_man.thumbnails.tex;
    if (ogImageButton(thumb_tex.imTextureID(), .{ .x = 75, .y = 75 }, thumb_uvs.tl, thumb_uvs.br, 5)) {
        igOpenPopup("##texture-chooser", ImGuiPopupFlags_None);
        std.mem.set(u8, &filter_buffer, 0);
    }
    igPopItemWidth();

    // texture chooser popup
    const popup_height = ogGetWindowSize().y - ogGetCursorScreenPos().y;
    ogSetNextWindowPos(ogGetCursorScreenPos(), ImGuiCond_Appearing, .{ .x = 0.5 });
    ogSetNextWindowSize(.{ .x = 75 * 3 + igGetStyle().ItemSpacing.x * 6, .y = popup_height }, ImGuiCond_Always);

    if (igBeginPopup("##texture-chooser", ImGuiWindowFlags_None)) {
        defer igEndPopup();

        igPushItemWidth(igGetWindowContentRegionWidth());
        if (ogInputText("##texture-filter", &filter_buffer, filter_buffer.len)) {
            const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
            filter_entities = null_index > 0;
        }
        igPopItemWidth();

        var displayed_count: usize = 0;
        for (state.asset_man.thumbnails.names) |asset_name, i| {
            if (filter_entities) {
                const null_index = std.mem.indexOfScalar(u8, &filter_buffer, 0) orelse 0;
                if (std.mem.indexOf(u8, asset_name, filter_buffer[0..null_index]) == null)
                    continue;
            }

            igPushIDInt(@intCast(c_int, i));
            defer igPopID();
            displayed_count += 1;

            igBeginGroup();

            const uvs = state.asset_man.getUvsForThumbnailAtIndex(i);
            if (ogImageButton(state.asset_man.thumbnails.tex.imTextureID(), .{ .x = 75, .y = 75 }, uvs.tl, uvs.br, 0)) {
                const tex_rect = state.asset_man.getTextureAndRect(asset_name);
                sprite.updateTexture(tex_rect.tex, tex_rect.rect, asset_name);
                igCloseCurrentPopup();
            }

            const base_name = asset_name[0..std.mem.indexOfScalar(u8, asset_name, '.').?];
            var name_buf: [12:0]u8 = undefined;
            std.mem.set(u8, &name_buf, 0);

            if (base_name.len > 11) {
                std.mem.copy(u8, &name_buf, base_name[0..11]);
            } else {
                std.mem.copy(u8, &name_buf, base_name);
            }

            igText(&name_buf);
            igEndGroup();

            if (displayed_count % 3 == 0) {
                ogDummy(.{ .y = 10 });
            } else {
                igSameLine(0, igGetStyle().ItemSpacing.x);
            }
        }
    }
}

pub fn inspectOrigin(label: [:0]const u8, vec: *aya.math.Vec2, image_size: aya.math.Vec2) void {
    beginColumns(label, vec);
    defer endColumns();

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

    if (igBeginPopup("##origin-selector", ImGuiWindowFlags_None)) {
        igText("Origin:");

        if (ogButton(icons.circle ++ "##tl")) vec.* = .{}; // tl

        igSameLine(0, 7);
        if (ogButton(icons.arrow_up ++ "##tc")) vec.* = .{ .x = image_size.x / 2 }; // tc

        igSameLine(0, 7);
        if (ogButton(icons.circle ++ "##tr")) vec.* = .{ .x = image_size.x }; // tr

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

pub fn inspectSprite(state: *AppState, sprite: *root.data.Sprite) void {
    inspectSpriteTexture(state, sprite);
    inspectOrigin("Origin", &sprite.origin, .{ .x = @intToFloat(f32, sprite.rect.w), .y = @intToFloat(f32, sprite.rect.h) });
}

pub fn inspectCollider(collider: *root.data.Collider) void {
    switch (collider.*) {
        .box => |*box| {
            inspectVec2("Offset", &box.offset, .{});
            inspectFloatMinMax("Width", &box.w, 25, 1, std.math.f32_max);
            inspectFloatMinMax("Height", &box.h, 25, 1, std.math.f32_max);
        },
        .circle => |*circle| {
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

    igPushItemWidth(-1);

    const line_height = GImGui.*.FontSize + igGetStyle().FramePadding.y * 2;
    const button_size = ImVec2{ .x = line_height + 3, .y = line_height };

    igPushStyleColorU32(ImGuiCol_Button, root.colors.rgbToU32(104, 26, 38));
    if (ogButtonEx(icons.redo, button_size)) value.* = 0;
    igPopStyleColor(1);

    igSameLine(0, 0);

    if (enum_values.len == 0) {
        igText("No enum values set");
    } else if (igBeginCombo("##enum", &enum_values[value.*], ImGuiComboFlags_None)) {
        defer igEndCombo();

        for (enum_values) |enum_label, i| {
            if (igSelectableBool(&enum_label, value.* == i, ImGuiSelectableFlags_None, .{ .y = line_height }))
                value.* = @intCast(u8, i);
        }
    }
}
