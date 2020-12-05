const std = @import("std");
const root = @import("../main.zig");
usingnamespace @import("imgui");

var selected_comp: usize = 0;
var asset_types = [_][:0]const u8{ "Tilesets", "Textures", "Atlases", "Levels" };

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
            3 => drawLevels(state),
            else => {},
        }
        igColumns(1, null, false);
    }
}

fn drawTilesets(state: *root.AppState) void {
    igText("tilesets");
}

fn drawTextures(state: *root.AppState) void {
    const num = 80;
    const win_visible_width = ogGetWindowPos().x + ogGetWindowContentRegionMax().x;
    const x_spacing = igGetStyle().ItemSpacing.x;

    var i: usize = 0;
    while (i < num) : (i += 1) {
        igPushIDInt(num);
        defer igPopID();

        _ = ogButtonEx("Box", .{.x = 50, .y = 50});
        if (igIsItemActive())
            ogImDrawList_AddLine(igGetForegroundDrawListNil(), igGetIO().MouseClickedPos[0], igGetIO().MousePos, igGetColorU32Col(ImGuiCol_Button, 1), 2);

        // Expected position if next button was on same line
        const next_x = ogGetItemRectMax().x + x_spacing + 50;
        if (i + 1 < num and next_x < win_visible_width)
            igSameLine(0, x_spacing);
    }
}

fn drawAtlases(state: *root.AppState) void {
    igText("atlases");
}

fn drawLevels(state: *root.AppState) void {
    igText("levels");
}
