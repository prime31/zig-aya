const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
usingnamespace @import("imgui");
const brushes_win = @import("brushes.zig");

var buffer: [25]u8 = undefined;

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 200 });
    defer igPopStyleVar(1);

    if (state.windows.animations and igBegin("Animations", &state.windows.animations, ImGuiWindowFlags_None)) {
        defer igEnd();

        if (igBeginChildEx("##animations-child", igGetItemID(), ImVec2{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.animations.items) |*anim, i| {
                igPushIDInt(@intCast(c_int, i));

                if (tk.tileImageButton(state, 16, anim.tile)) {
                    igOpenPopup("tile-chooser");
                }
                igSameLine(0, 5);

                // igPushItemWidth(100);
                if (ogButton("Tiles")) {
                    igOpenPopup("animation-tiles");
                }
                // igPopItemWidth();
                igSameLine(0, 5);

                igPushItemWidth(75);
                _ = ogDragUnsignedFormat(u16, "", &anim.rate, 0.5, 0, std.math.maxInt(u16), "%dms");
                igPopItemWidth();
                igSameLine(igGetWindowContentRegionWidth() - 20, 0);

                if (ogButton(icons.trash)) {
                    delete_index = i;
                }

                if (igBeginPopup("tile-chooser", ImGuiWindowFlags_None)) {
                    animTileSelectorPopup(state, anim, .single);
                    igEndPopup();
                }

                if (igBeginPopup("animation-tiles", ImGuiWindowFlags_None)) {
                    animTileSelectorPopup(state, anim, .multi);
                    igEndPopup();
                }

                igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                _ = state.map.animations.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Animation", ImVec2{})) {
            igOpenPopup("add-anim");
        }

        if (igBeginPopup("add-anim", ImGuiWindowFlags_None)) {
            addAnimationPopup(state);
        }
    }
}

fn addAnimationPopup(state: *tk.AppState) void {
    var content_start_pos = ogGetCursorScreenPos();
    ogImage(state.texture);

    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, state.map.tile_size), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * state.tilesPerRow());
            state.map.addAnimation(tile_index);
            igCloseCurrentPopup();
        }
    }
}

fn animTileSelectorPopup(state: *tk.AppState, anim: *tk.data.Animation, selection_type: enum { single, multi }) void {
    const per_row = if (false) 6 else state.tilesPerRow();

    var content_start_pos = ogGetCursorScreenPos();
    ogImage(state.texture);

    const draw_list = igGetWindowDrawList();

    // draw selected tile or tiles
    if (selection_type == .multi) {
        var iter = anim.tiles.iter();
        while (iter.next()) |value| {
            addTileToDrawList(state.map.tile_size, content_start_pos, value, per_row);
        }
    } else {
        addTileToDrawList(state.map.tile_size, content_start_pos, anim.tile, per_row);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(0, false)) {
            var tile = tk.tileIndexUnderMouse(@intCast(usize, state.map.tile_size), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * per_row);
            if (selection_type == .multi) {
                anim.toggleSelected(tile_index);
            } else {
                anim.tile = tile_index;
                igCloseCurrentPopup();
            }
        }
    }

    if (selection_type == .multi and igButton("Clear", ImVec2{ .x = -1 })) {
        anim.tiles.clear();
    }
}

fn addTileToDrawList(tile_size: usize, content_start_pos: ImVec2, tile: u8, per_row: usize) void {
    const x = @mod(tile, per_row);
    const y = @divTrunc(tile, per_row);

    var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, tile_size), .y = @intToFloat(f32, y) * @intToFloat(f32, tile_size) };
    tl.x += content_start_pos.x + 1;
    tl.y += content_start_pos.y + 1;
    ogAddQuadFilled(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size), tk.colors.rule_result_selected_fill);
    ogAddQuad(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size), tk.colors.rule_result_selected_outline, 2);
}