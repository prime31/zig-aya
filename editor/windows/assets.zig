const std = @import("std");
const root = @import("../main.zig");
usingnamespace @import("imgui");

var selected_comp: usize = 0;
var asset_types = [_][:0]const u8{ icons.th_list ++ " Tilesets", icons.image ++ " Textures", icons.atlas ++ " Atlases", icons.dungeon ++ " Levels" };
const thumb_size = 75;
const max_thumb_chars = 10;

pub fn draw(state: *root.AppState) void {
    defer igEnd();
    if (igBegin("Assets", null, ImGuiWindowFlags_None)) {
        igColumns(2, "assets", true);
        igSetColumnWidth(0, 115);

        ogPushStyleVarVec2(ImGuiStyleVar_ItemSpacing, .{ .x = 9, .y = 14 });
        ogPushStyleVarVec2(ImGuiStyleVar_FramePadding, .{ .x = 4, .y = 8 });
        igPushItemWidth(-1);
        if (ogListBoxHeaderVec2("", .{ .y = 110 })) {
            defer igListBoxFooter();

            for (asset_types) |asset_type, i| {
                if (ogSelectableBool(asset_type.ptr, selected_comp == i, ImGuiSelectableFlags_None, .{}))
                    selected_comp = i;
            }
        }
        igPopItemWidth();
        igPopStyleVar(2);

        igNextColumn();
        switch (selected_comp) {
            0 => drawTilesets(state),
            1 => drawTextures(state),
            2 => drawAtlases(state),
            3 => drawLevels(state),
            else => {},
        }
        igColumns(1, null, false);
    }
}

fn drawTilesets(state: *root.AppState) void {
    for (state.asset_man.tilesets) |tileset| {
        igText(tileset.ptr);
    }
}

fn drawTextures(state: *root.AppState) void {
    const win_visible_width = ogGetWindowPos().x + ogGetWindowContentRegionMax().x;
    const x_spacing = igGetStyle().ItemSpacing.x;

    const w = ogGetContentRegionAvail().x + 10;
    _ = ogBeginChildID(666, .{ .x = w }, false, ImGuiWindowFlags_None);
    defer igEndChildFrame();

    // we only drag/drop if the entity layer is active
    const entity_layer = if (state.level.layers.items.len > 0 and state.level.layers.items[state.selected_layer_index] == .entity) state.level.layers.items[state.selected_layer_index].entity else null;

    for (state.asset_man.thumbnails.names) |asset_name, i| {
        ogPushIDUsize(i);
        defer igPopID();

        igBeginGroup();
        const uvs = state.asset_man.getUvsForThumbnailAtIndex(i);
        _ = ogImageButtonEx(state.asset_man.thumbnails.tex.imTextureID(), .{ .x = thumb_size, .y = thumb_size }, uvs.tl, uvs.br, 0, root.colors.rgbToVec4(50, 50, 50), .{ .x = 1, .y = 1, .z = 1, .w = 1 });

        if (entity_layer != null and igBeginDragDropSource(ImGuiDragDropFlags_None)) {
            defer igEndDragDropSource();
            const tex_uvs = state.asset_man.getTextureAndUvs(asset_name);

            const scale = root.scene.cam.zoom;
            const tex_w = @intToFloat(f32, tex_uvs.rect.w) * root.scene.cam.zoom;
            const tex_h = @intToFloat(f32, tex_uvs.rect.h) * root.scene.cam.zoom;

            const cursor_pos = igGetIO().MousePos.subtract(.{ .x = tex_w / 2, .y = tex_h / 2 });
            const cursor_bl = cursor_pos.add(.{ .x = tex_w, .y = tex_h });
            ogImDrawList_AddImage(igGetForegroundDrawListNil(), tex_uvs.tex.imTextureID(), cursor_pos, cursor_bl, tex_uvs.uvs.tl, tex_uvs.uvs.br, 0xFFFFFFFF);
            _ = igSetDragDropPayload("TEXTURE_ASSET_DRAG", &i, @sizeOf(usize), ImGuiCond_Once);
            igText(asset_name);
        }

        if (entity_layer != null and igIsItemActive())
            ogImDrawList_AddLine(igGetForegroundDrawListNil(), igGetIO().MouseClickedPos[0], igGetIO().MousePos, igGetColorU32Col(ImGuiCol_Button, 1), 2);

        const base_name = asset_name[0..std.mem.indexOfScalar(u8, asset_name, '.').?];
        var name_buf: [max_thumb_chars + 1:0]u8 = undefined;
        std.mem.set(u8, &name_buf, 0);

        if (base_name.len > max_thumb_chars) {
            std.mem.copy(u8, &name_buf, base_name[0..max_thumb_chars]);
        } else {
            std.mem.copy(u8, &name_buf, base_name);
        }
        igText(&name_buf);
        igEndGroup();

        // Expected position if next button was on same line
        const next_x = ogGetItemRectMax().x + x_spacing + thumb_size;
        if (next_x < win_visible_width) {
            igSameLine(0, x_spacing);
        } else {
            ogDummy(.{ .y = 10 });
        }
    }
}

fn drawAtlases(state: *root.AppState) void {
    igText("atlases");
}

fn drawLevels(state: *root.AppState) void {
    const win_visible_width = ogGetWindowPos().x + ogGetWindowContentRegionMax().x;
    const x_spacing = igGetStyle().ItemSpacing.x;

    const w = ogGetContentRegionAvail().x + 10;
    _ = ogBeginChildID(777, .{ .x = w }, false, ImGuiWindowFlags_None);
    defer igEndChildFrame();

    for (state.asset_man.levels) |level, i| {
        ogPushIDUsize(i);
        defer igPopID();

        if (ogButtonEx(level.ptr, .{ .x = -1 })) {}
    }
}
