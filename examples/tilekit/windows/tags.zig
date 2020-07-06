const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
usingnamespace @import("imgui");
const brushes_win = @import("brushes.zig");

var buffer: [25]u8 = undefined;

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 100 });
    defer igPopStyleVar(1);

    if (state.windows.tag_editor and igBegin("Tags", &state.windows.tag_editor, ImGuiWindowFlags_None)) {
        defer igEnd();

        if (igBeginChildEx("##tag-child", igGetItemID(), ImVec2{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.tags.items) |*tag, i| {
                igPushIDInt(@intCast(c_int, i));

                if (ogInputText("##key", &tag.name, tag.name.len)) {}
                igSameLine(0, 5);

                igPushItemWidth(100);
                if (ogButton("Tiles")) {
                    igOpenPopup("tag-tiles");
                }
                igPopItemWidth();

                igSameLine(igGetWindowContentRegionWidth() - 20, 0);
                if (ogButton(icons.trash)) {
                    delete_index = i;
                }

                if (igBeginPopup("tag-tiles", ImGuiWindowFlags_None)) {
                    defer igEndPopup();
                    tagTileSelectorPopup(state, tag);
                }

                igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                _ = state.map.tags.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Tag", ImVec2{})) {
            state.map.addTag();
        }
    }
}

fn tagTileSelectorPopup(state: *tk.AppState, tag: *tk.data.Tag) void {
    var content_start_pos = ogGetCursorScreenPos();
    // should tags be allowed on tilesets? if so, we need to remove the hardcoded 6's
    // ogImage(state.texture);
    brushes_win.draw(state, @intToFloat(f32, state.map.tile_size), true);

    const draw_list = igGetWindowDrawList();

    // draw selected tiles
    var iter = tag.tiles.iter();
    while (iter.next()) |value| {
        const x = @mod(value, 6);
        const y = @divTrunc(value, 6);

        var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, state.map.tile_size), .y = @intToFloat(f32, y) * @intToFloat(f32, state.map.tile_size) };
        tl.x += content_start_pos.x + 1;
        tl.y += content_start_pos.y + 1;
        ogAddQuadFilled(draw_list, tl, @intToFloat(f32, state.map.tile_size), tk.colors.rule_result_selected_fill);
        ogAddQuad(draw_list, tl, @intToFloat(f32, state.map.tile_size), tk.colors.rule_result_selected_outline, 2);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, state.map.tile_size), content_start_pos);
            tag.toggleSelected(@intCast(u8, tile.x + tile.y * 6));
        }
    }

    if (igButton("Clear", ImVec2{ .x = -1 })) {
        tag.tiles.clear();
    }
}
