const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");
const icons = imgui.icons;
const ts = @import("tileset.zig");

const Tileset = @import("tileset.zig").Tileset;
const Animation = @import("tileset.zig").Animation;

/// draws a tileset animation editor allowing add/remove of animations. Animations consist of a key tile index and then
/// multiple tile indices for the animation itself.
pub fn draw(tileset: *Tileset) void {
    imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    imgui.ogSetNextWindowSize(.{ .x = 195, .y = 0 }, imgui.ImGuiCond_Always);
    if (imgui.igBeginPopup("##tileset-animations", imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEndPopup();

        var delete_index: usize = std.math.maxInt(usize);
        for (tileset.animations.items, 0..) |*anim, i| {
            imgui.igPushIDPtr(anim);

            if (tileset.tileImageButton(16, anim.tile))
                imgui.igOpenPopup("tile-chooser", imgui.ImGuiPopupFlags_None);
            imgui.igSameLine(0, 5);

            if (imgui.ogButton("Tiles"))
                imgui.igOpenPopup("animation-tiles", imgui.ImGuiPopupFlags_None);
            imgui.igSameLine(0, 5);

            imgui.igPushItemWidth(75);
            _ = imgui.ogDragUnsignedFormat(u16, "", &anim.rate, 1, 0, std.math.maxInt(u16), "%dms");
            imgui.igPopItemWidth();

            imgui.igSameLine(0, 5);
            if (imgui.ogButton(icons.trash)) delete_index = i;

            imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
            if (imgui.igBeginPopup("tile-chooser", imgui.ImGuiWindowFlags_None)) {
                animTileSelectorPopup(tileset, anim, .single);
                imgui.igEndPopup();
            }

            imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
            if (imgui.igBeginPopup("animation-tiles", imgui.ImGuiWindowFlags_None)) {
                animTileSelectorPopup(tileset, anim, .multi);
                imgui.igEndPopup();
            }

            imgui.igPopID();
        }

        if (delete_index < std.math.maxInt(usize))
            _ = tileset.animations.orderedRemove(delete_index);

        if (imgui.ogButtonEx("Add Animation", .{ .x = -1 })) imgui.igOpenPopup("add-anim", imgui.ImGuiPopupFlags_None);

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("add-anim", imgui.ImGuiWindowFlags_None)) {
            addAnimationPopup(tileset);
            imgui.igEndPopup();
        }
    }
}

fn addAnimationPopup(tileset: *Tileset) void {
    var content_start_pos = imgui.ogGetCursorScreenPos();
    const zoom: usize = if (tileset.tex.width < 200 and tileset.tex.height < 200) 2 else 1;
    imgui.ogImage(tileset.tex.imTextureID(), @floatToInt(i32, tileset.tex.width) * @intCast(i32, zoom), @floatToInt(i32, tileset.tex.height) * @intCast(i32, zoom));

    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None) and imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
        var tile = ts.tileIndexUnderPos(imgui.igGetIO().MousePos, @intCast(usize, tileset.tile_size * zoom), content_start_pos);
        var tile_index = @intCast(u8, tile.x + tile.y * tileset.tiles_per_row);
        tileset.animations.append(Animation.init(tile_index)) catch unreachable;
        imgui.igCloseCurrentPopup();
    }
}

fn animTileSelectorPopup(tileset: *Tileset, anim: *Animation, selection_type: enum { single, multi }) void {
    const per_row = tileset.tiles_per_row;

    var content_start_pos = imgui.ogGetCursorScreenPos();
    const zoom: usize = if (tileset.tex.width < 200 and tileset.tex.height < 200) 2 else 1;
    const tile_spacing = tileset.spacing * zoom;
    const tile_size = tileset.tile_size * zoom;

    imgui.ogImage(tileset.tex.imTextureID(), @floatToInt(i32, tileset.tex.width) * @intCast(i32, zoom), @floatToInt(i32, tileset.tex.height) * @intCast(i32, zoom));

    // const draw_list = imgui.igGetWindowDrawList();

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
    if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
        if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
            var tile = ts.tileIndexUnderPos(imgui.igGetIO().MousePos, @intCast(usize, tile_size + tile_spacing), content_start_pos);
            var tile_index = @intCast(u8, tile.x + tile.y * per_row);
            if (selection_type == .multi) {
                anim.toggleSelected(tile_index);
            } else {
                anim.tile = tile_index;
                imgui.igCloseCurrentPopup();
            }
        }
    }

    if (selection_type == .multi and imgui.igButton("Clear", imgui.ImVec2{ .x = -1 }))
        anim.tiles.clear();
}
