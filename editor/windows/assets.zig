const std = @import("std");
const root = @import("../main.zig");
usingnamespace @import("imgui");

var selected_comp: usize = 0;
var asset_types = [_][:0]const u8{ icons.th_list ++ " Tilesets", icons.image ++ " Textures", icons.atlas ++ " Atlases", icons.dungeon ++ " Levels" };
const thumb_size = 75;
const max_thumb_chars = 7;

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
    _ = igBeginChildID(666, .{.x = w}, false, ImGuiWindowFlags_None);
    defer igEndChildFrame();

    for (state.asset_man.thumbnail_atlas.names) |asset_name, i| {
        igPushIDInt(@intCast(c_int, i));
        defer igPopID();

        igBeginGroup();
        const uvs = state.asset_man.getUvsForThumbnailAtIndex(i);
        _ = ogImageButtonEx(state.asset_man.thumbnail_texture.imTextureID(), .{ .x = thumb_size, .y = thumb_size }, uvs[0], uvs[1], 0, root.colors.rgbToVec4(50, 50, 50), .{ .x = 1, .y = 1, .z = 1, .w = 1 });

        if (igBeginDragDropSource(ImGuiDragDropFlags_None)) {
            defer igEndDragDropSource();
            _ = igSetDragDropPayload("TEXTURE_ASSET_DRAG", &i, @sizeOf(usize), ImGuiCond_Once);
            _ = ogButtonEx("Texy", .{ .x = thumb_size, .y = thumb_size });
        }

        if (igIsItemActive())
            ogImDrawList_AddLine(igGetForegroundDrawListNil(), igGetIO().MouseClickedPos[0], igGetIO().MousePos, igGetColorU32Col(ImGuiCol_Button, 1), 2);

        const base_name = asset_name[0..std.mem.indexOfScalar(u8, asset_name, '.').?];
        var name_buf: [10]u8 = undefined;
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
    igText("levels");
}
