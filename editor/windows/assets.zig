const std = @import("std");
const root = @import("../main.zig");
const imgui = @import("imgui");
const icons = imgui.icons;

var selected_comp: usize = 0;
var asset_types = [_][:0]const u8{ icons.th_list ++ " Tilesets", icons.image ++ " Textures", icons.atlas ++ " Atlases", icons.dungeon ++ " Levels" };
const thumb_size = 75;
const max_thumb_chars = 10;

pub fn draw(state: *root.AppState) void {
    defer imgui.igEnd();
    if (imgui.igBegin("Assets", null, imgui.ImGuiWindowFlags_None)) {
        imgui.igColumns(2, "assets", true);
        imgui.igSetColumnWidth(0, 115);

        imgui.ogPushStyleVarVec2(imgui.ImGuiStyleVar_ItemSpacing, .{ .x = 9, .y = 14 });
        imgui.ogPushStyleVarVec2(imgui.ImGuiStyleVar_FramePadding, .{ .x = 4, .y = 8 });
        imgui.igPushItemWidth(-1);
        if (imgui.ogListBoxHeaderVec2("", .{ .y = 110 })) {
            defer imgui.igListBoxFooter();

            for (asset_types, 0..) |asset_type, i| {
                if (imgui.ogSelectableBool(asset_type.ptr, selected_comp == i, imgui.ImGuiSelectableFlags_None, .{}))
                    selected_comp = i;
            }
        }
        imgui.igPopItemWidth();
        imgui.igPopStyleVar(2);

        imgui.igNextColumn();
        switch (selected_comp) {
            0 => drawTilesets(state),
            1 => drawTextures(state),
            2 => drawAtlases(state),
            3 => drawLevels(state),
            else => {},
        }
        imgui.igColumns(1, null, false);
    }
}

fn drawTilesets(state: *root.AppState) void {
    for (state.asset_man.tilesets) |tileset| {
        imgui.igText(tileset.ptr);
    }
}

fn drawTextures(state: *root.AppState) void {
    const win_visible_width = imgui.ogGetWindowPos().x + imgui.ogGetWindowContentRegionMax().x;
    const x_spacing = imgui.igGetStyle().ItemSpacing.x;

    const w = imgui.ogGetContentRegionAvail().x + 10;
    _ = imgui.ogBeginChildID(666, .{ .x = w }, false, imgui.ImGuiWindowFlags_None);
    defer imgui.igEndChildFrame();

    // we only drag/drop if the entity layer is active
    const entity_layer = if (state.level.layers.items.len > 0 and state.level.layers.items[state.selected_layer_index] == .entity) state.level.layers.items[state.selected_layer_index].entity else null;

    for (state.asset_man.thumbnails.names, 0..) |asset_name, i| {
        imgui.ogPushIDUsize(i);
        defer imgui.igPopID();

        imgui.igBeginGroup();
        const uvs = state.asset_man.getUvsForThumbnailAtIndex(i);
        _ = imgui.ogImageButtonEx(state.asset_man.thumbnails.tex.imTextureID(), .{ .x = thumb_size, .y = thumb_size }, uvs.tl, uvs.br, 0, root.colors.rgbToVec4(50, 50, 50), .{ .x = 1, .y = 1, .z = 1, .w = 1 });

        if (entity_layer != null and imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_None)) {
            defer imgui.igEndDragDropSource();
            const tex_uvs = state.asset_man.getTextureAndUvs(asset_name);

            // const scale = root.scene.cam.zoom;
            const tex_w = @intToFloat(f32, tex_uvs.rect.w) * root.scene.cam.zoom;
            const tex_h = @intToFloat(f32, tex_uvs.rect.h) * root.scene.cam.zoom;

            const cursor_pos = imgui.igGetIO().MousePos.subtract(.{ .x = tex_w / 2, .y = tex_h / 2 });
            const cursor_bl = cursor_pos.add(.{ .x = tex_w, .y = tex_h });
            imgui.ogImDrawList_AddImage(imgui.igGetForegroundDrawListNil(), tex_uvs.tex.imTextureID(), cursor_pos, cursor_bl, tex_uvs.uvs.tl, tex_uvs.uvs.br, 0xFFFFFFFF);
            _ = imgui.igSetDragDropPayload("TEXTURE_ASSET_DRAG", &i, @sizeOf(usize), imgui.ImGuiCond_Once);
            imgui.igText(asset_name);
        }

        if (entity_layer != null and imgui.igIsItemActive())
            imgui.ogImDrawList_AddLine(imgui.igGetForegroundDrawListNil(), imgui.igGetIO().MouseClickedPos[0], imgui.igGetIO().MousePos, imgui.igGetColorU32Col(imgui.ImGuiCol_Button, 1), 2);

        const base_name = asset_name[0..std.mem.indexOfScalar(u8, asset_name, '.').?];
        var name_buf: [max_thumb_chars + 1:0]u8 = undefined;
        std.mem.set(u8, &name_buf, 0);

        if (base_name.len > max_thumb_chars) {
            std.mem.copy(u8, &name_buf, base_name[0..max_thumb_chars]);
        } else {
            std.mem.copy(u8, &name_buf, base_name);
        }
        imgui.igText(&name_buf);
        imgui.igEndGroup();

        // Expected position if next button was on same line
        const next_x = imgui.ogGetItemRectMax().x + x_spacing + thumb_size;
        if (next_x < win_visible_width) {
            imgui.igSameLine(0, x_spacing);
        } else {
            imgui.ogDummy(.{ .y = 10 });
        }
    }
}

fn drawAtlases(_: *root.AppState) void {
    imgui.igText("atlases");
}

fn drawLevels(state: *root.AppState) void {
    // const win_visible_width = imgui.ogGetWindowPos().x + imgui.ogGetWindowContentRegionMax().x;
    // const x_spacing = imgui.igGetStyle().ItemSpacing.x;

    const w = imgui.ogGetContentRegionAvail().x + 10;
    _ = imgui.ogBeginChildID(777, .{ .x = w }, false, imgui.ImGuiWindowFlags_None);
    defer imgui.igEndChildFrame();

    for (state.asset_man.levels, 0..) |level, i| {
        imgui.ogPushIDUsize(i);
        defer imgui.igPopID();

        const base_name = level[0..std.mem.indexOfScalar(u8, level, '.').?];
        var name_buf: [25:0]u8 = undefined;
        std.mem.set(u8, &name_buf, 0);
        std.mem.copy(u8, &name_buf, base_name);

        if (imgui.ogButtonEx(&name_buf, .{ .x = -1 })) state.level = root.persistence.loadLevel(level) catch unreachable;
    }
}
