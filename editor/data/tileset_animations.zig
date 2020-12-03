const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");
const brushes_win = @import("brushes.zig");
const ts = @import("tileset.zig");

const Tileset = @import("tileset.zig").Tileset;
const Animation = @import("tileset.zig").Animation;


/// draws a tileset animation editor allowing add/remove of animations. Animations consist of a key tile index and then
/// multiple tile indices for the animation itself.
pub fn draw(tileset: *Tileset) void {
    ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
    ogSetNextWindowSize(.{ .x = 195, .y = -1 }, ImGuiCond_Always);
    if (igBeginPopup("##tileset-animations", ImGuiWindowFlags_None)) {
        defer igEndPopup();

        var delete_index: usize = std.math.maxInt(usize);
        for (tileset.animations.items) |*anim, i| {
            igPushIDPtr(anim);

            if (tileset.tileImageButton(16, anim.tile))
                igOpenPopup("tile-chooser", ImGuiPopupFlags_None);
            igSameLine(0, 5);

            if (ogButton("Tiles"))
                igOpenPopup("animation-tiles", ImGuiPopupFlags_None);
            igSameLine(0, 5);

            igPushItemWidth(75);
            _ = ogDragUnsignedFormat(u16, "", &anim.rate, 1, 0, std.math.maxInt(u16), "%dms");
            igPopItemWidth();

            igSameLine(0, 5);
            if (ogButton(icons.trash)) delete_index = i;

            ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
            if (igBeginPopup("tile-chooser", ImGuiWindowFlags_None)) {
                animTileSelectorPopup(tileset, anim, .single);
                igEndPopup();
            }

            ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
            if (igBeginPopup("animation-tiles", ImGuiWindowFlags_None)) {
                animTileSelectorPopup(tileset, anim, .multi);
                igEndPopup();
            }

            igPopID();
        }

        if (delete_index < std.math.maxInt(usize))
            _ = tileset.animations.orderedRemove(delete_index);

        if (ogButtonEx("Add Animation", .{ .x = -1 })) igOpenPopup("add-anim", ImGuiPopupFlags_None);

        igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("add-anim", ImGuiWindowFlags_None)) {
            addAnimationPopup(tileset);
            igEndPopup();
        }
    }
}

fn addAnimationPopup(tileset: *Tileset) void {
    var content_start_pos = ogGetCursorScreenPos();
    const zoom: usize = if (tileset.tex.width < 200 and tileset.tex.height < 200) 2 else 1;
    ogImage(tileset.tex.imTextureID(), @floatToInt(i32, tileset.tex.width) * @intCast(i32, zoom), @floatToInt(i32, tileset.tex.height) * @intCast(i32, zoom));

    if (igIsItemHovered(ImGuiHoveredFlags_None) and igIsMouseClicked(ImGuiMouseButton_Left, false)) {
        var tile = ts.tileIndexUnderPos(igGetIO().MousePos, @intCast(usize, tileset.tile_size * zoom), content_start_pos);
        var tile_index = @intCast(u8, tile.x + tile.y * tileset.tiles_per_row);
        tileset.animations.append(Animation.init(tile_index)) catch unreachable;
        igCloseCurrentPopup();
    }
}

fn animTileSelectorPopup(tileset: *Tileset, anim: *Animation, selection_type: enum { single, multi }) void {
    const per_row = tileset.tiles_per_row;

    var content_start_pos = ogGetCursorScreenPos();
    const zoom: usize = if (tileset.tex.width < 200 and tileset.tex.height < 200) 2 else 1;
    const tile_spacing = tileset.spacing * zoom;
    const tile_size = tileset.tile_size * zoom;

    ogImage(tileset.tex.imTextureID(), @floatToInt(i32, tileset.tex.width) * @intCast(i32, zoom), @floatToInt(i32, tileset.tex.height) * @intCast(i32, zoom));

    const draw_list = igGetWindowDrawList();

    // draw selected tile or tiles
    if (selection_type == .multi) {
        var iter = anim.tiles.iter();
        while (iter.next()) |value| {
            ts.addTileToDrawList(tile_size, content_start_pos, value, per_row, tile_spacing);
        }
    } else {
        ts.addTileToDrawList(tile_size, content_start_pos, anim.tile, per_row, tile_spacing);
    }

    // check input for toggling state
    if (igIsItemHovered(ImGuiHoveredFlags_None)) {
        if (igIsMouseClicked(ImGuiMouseButton_Left, false)) {
            var tile = ts.tileIndexUnderPos(igGetIO().MousePos, @intCast(usize, tile_size + tile_spacing), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * per_row);
            if (selection_type == .multi) {
                anim.toggleSelected(tile_index);
            } else {
                anim.tile = tile_index;
                igCloseCurrentPopup();
            }
        }
    }

    if (selection_type == .multi and igButton("Clear", ImVec2{ .x = -1 }))
        anim.tiles.clear();
}
