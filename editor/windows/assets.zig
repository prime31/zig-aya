const std = @import("std");
const root = @import("../main.zig");
usingnamespace @import("imgui");

var selected_comp: usize = 0;
var asset_types = [_][:0]const u8{ "Tilesets", "Textures", "Atlases" };

pub fn draw(state: *root.AppState) void {
    defer igEnd();
    if (igBegin("Assets", null, ImGuiWindowFlags_None)) {
        igColumns(2, "assets", true);
        igSetColumnWidth(0, 85);

        igPushItemWidth(-1);
        if (ogListBoxHeaderVec2("", .{})) {
            defer igListBoxFooter();

            for (asset_types) |asset_type, i| {
                if (ogSelectableBool(asset_type.ptr, selected_comp == i, ImGuiSelectableFlags_None, .{}))
                    selected_comp = i;
            }
        }
        igPopItemWidth();

        igNextColumn();
        switch (selected_comp) {
            0 => drawTilesets(state),
            1 => drawTextures(state),
            2 => drawAtlases(state),
            else => {},
        }
        igColumns(1, null, false);
    }
}

fn drawTilesets(state: *root.AppState) void {
    igText("tilesets");
}

fn drawTextures(state: *root.AppState) void {
    igText("textures");
}

fn drawAtlases(state: *root.AppState) void {
    igText("atlases");
}
