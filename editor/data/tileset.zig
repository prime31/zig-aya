const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const root = @import("../main.zig");
const Color = aya.math.Color;
const imgui = @import("imgui");
const icons = imgui.icons;

const tilset_animations = @import("tileset_animations.zig");

pub const AppState = @import("app_state.zig").AppState;
pub const Tile = @import("data.zig").Tile;

pub const Tileset = struct {
    tile_size: usize,
    spacing: usize,
    tex: aya.gfx.Texture = undefined,
    tex_name: []const u8 = &[_]u8{},
    tiles_per_row: usize = 0,
    tiles_per_col: usize = 0,
    tile_definitions: TileDefinitions = .{},
    animations: std.ArrayList(Animation),
    selected: Tile = Tile.init(0),

    pub fn init(tile_size: usize) Tileset {
        var ts = Tileset{
            .tile_size = tile_size,
            .spacing = 0,
            .animations = std.ArrayList(Animation).init(aya.mem.allocator),
        };
        ts.setTexture(generateTexture());
        return ts;
    }

    pub fn deinit(self: Tileset) void {
        self.tex.deinit();
        self.animations.deinit();
    }

    pub fn loadTexture(self: *Tileset, file: []const u8) !void {
        var spacing: usize = 0;
        if (!validateImage(file, self.tile_size, &spacing)) {
            std.log.warn("invalid file. failed validation", .{});
            return error.FailedValidation;
        }

        self.tex.deinit();
        self.spacing = spacing;
        self.setTexture(try aya.gfx.Texture.initFromFile(file, .nearest));
    }

    /// ensures the image is a valid tileset
    fn validateImage(file: []const u8, tile_size: usize, spacing: *usize) bool {
        spacing.* = 0;
        var w: c_int = 0;
        var h: c_int = 0;
        if (aya.gfx.Texture.getTextureSize(file, &w, &h)) {
            const max_tiles = @intCast(usize, w) / tile_size;

            while (spacing.* <= 4) : (spacing.* += 1) {
                var i: usize = 3;
                while (i <= max_tiles) : (i += 1) {
                    const space = (2 * spacing.*) + (i - 1) * spacing.*;
                    const filled = i * tile_size;
                    if (space + filled == w) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    /// generates a texture with 4x4, 16px blocks of color
    fn generateTexture() aya.gfx.Texture {
        var colors = [_]u32{
            Color.white.value,   Color.black.value,  Color.gray.value,   Color.aya.value,
            Color.yellow.value,  Color.orange.value, Color.pink.value,   Color.red.value,
            Color.lime.value,    Color.blue.value,   Color.beige.value,  Color.voilet.value,
            Color.magenta.value, Color.green.value,  Color.maroon.value, Color.sky_blue.value,
        };

        var pixels: [16 * 4 * 16 * 4]u32 = undefined;
        var y: usize = 0;
        while (y < 16 * 4) : (y += 1) {
            var x: usize = 0;
            while (x < 16 * 4) : (x += 1) {
                const xx = @divTrunc(x, 16);
                const yy = @divTrunc(y, 16);
                pixels[x + y * 16 * 4] = colors[xx + yy * 2];
            }
        }

        return aya.gfx.Texture.initWithData(u32, 16 * 4, 16 * 4, &pixels);
    }

    pub fn setTexture(self: *Tileset, tex: aya.gfx.Texture) void {
        self.tex = tex;
        self.tiles_per_row = 0;
        self.tiles_per_col = 0;

        // calculate tiles_per_row and tiles_per_col
        var accum: usize = self.spacing * 2;
        while (true) {
            self.tiles_per_row += 1;
            accum += self.tile_size + self.spacing;
            if (accum >= @floatToInt(usize, self.tex.width)) {
                break;
            }
        }

        accum = self.spacing * 2;
        while (true) {
            self.tiles_per_col += 1;
            accum += self.tile_size + 2 * self.spacing;
            if (accum >= @floatToInt(usize, self.tex.height)) {
                break;
            }
        }
    }

    pub fn draw(self: *Tileset, _: *AppState) void {
        const zoom: usize = if (self.tex.width < 200 and self.tex.height < 200) 2 else 1;
        const first_pos = imgui.igGetIO().DisplaySize.subtract(.{
            .x = 150 + self.tex.width * @intToFloat(f32, zoom),
            .y = 150 + self.tex.height * @intToFloat(f32, zoom),
        });
        imgui.ogSetNextWindowPos(first_pos, imgui.ImGuiCond_FirstUseEver, .{});

        defer imgui.igEnd();
        if (!imgui.igBegin("Palette", null, imgui.ImGuiWindowFlags_NoCollapse | imgui.ImGuiWindowFlags_NoResize | imgui.ImGuiWindowFlags_AlwaysAutoResize | imgui.ImGuiWindowFlags_NoFocusOnAppearing | imgui.ImGuiWindowFlags_NoDocking)) return;

        imgui.igSetCursorPosY(imgui.igGetCursorPosY() - 8);
        imgui.igSetCursorPosX(imgui.igGetWindowContentRegionWidth() - 40);

        if (imgui.ogButton(icons.adjust)) imgui.igOpenPopup("##tileset-definitions", imgui.ImGuiPopupFlags_None);
        imgui.ogUnformattedTooltip(100, "Tileset definitions");

        imgui.igSameLine(0, 2);
        if (imgui.ogButton(icons.universal_access)) imgui.igOpenPopup("##tileset-animations", imgui.ImGuiPopupFlags_None);
        imgui.ogUnformattedTooltip(100, "Animation editor");

        var origin = imgui.ogGetCursorScreenPos();
        imgui.ogImage(self.tex.imTextureID(), @floatToInt(i32, self.tex.width) * @intCast(i32, zoom), @floatToInt(i32, self.tex.height) * @intCast(i32, zoom));

        // draw selected tile
        addTileToDrawList(self.tile_size * zoom, origin, self.selected.comps.tile_index, self.tiles_per_row, self.spacing * zoom);

        // check input for toggling selected state
        if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
            if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
                var tile = tileIndexUnderPos(imgui.igGetIO().MousePos, @intCast(usize, self.tile_size * zoom + self.spacing * zoom), origin);
                self.selected.value = @intCast(u8, tile.x + tile.y * self.tiles_per_row);
            }
        }

        self.tile_definitions.drawPopup(self);
        tilset_animations.draw(self);
    }

    pub fn viewportForTile(self: Tileset, tile: usize) aya.math.RectI {
        const x = @mod(tile, self.tiles_per_row);
        const y = @divTrunc(tile, self.tiles_per_row);

        return .{
            .x = @intCast(i32, (x * self.tile_size + self.spacing) + self.spacing),
            .y = @intCast(i32, (y * self.tile_size + self.spacing) + self.spacing),
            .w = @intCast(i32, self.tile_size),
            .h = @intCast(i32, self.tile_size),
        };
    }

    /// helper to draw an image button with an image from the tileset
    pub fn tileImageButton(self: Tileset, size: f32, tile: usize) bool {
        const rect = uvsForTile(self, tile);
        const uv0 =  imgui.ImVec2{ .x = rect.x, .y = rect.y };
        const uv1 =  imgui.ImVec2{ .x = rect.x + rect.w, .y = rect.y + rect.h };

        // const tint = root.colors.rgbToVec4(255, 255, 255);
        return imgui.ogImageButton(self.tex.imTextureID(), .{ .x = size, .y = size }, uv0, uv1, 2);
    }

    pub fn uvsForTile(self: Tileset, tile: usize) math.Rect {
        const x = @intToFloat(f32, @mod(tile, self.tiles_per_row));
        const y = @intToFloat(f32, @divTrunc(tile, self.tiles_per_row));

        const inv_w = 1.0 / self.tex.width;
        const inv_h = 1.0 / self.tex.height;

        return .{
            .x = (x * @intToFloat(f32, self.tile_size + self.spacing) + @intToFloat(f32, self.spacing)) * inv_w,
            .y = (y * @intToFloat(f32, self.tile_size + self.spacing) + @intToFloat(f32, self.spacing)) * inv_h,
            .w = @intToFloat(f32, self.tile_size) * inv_w,
            .h = @intToFloat(f32, self.tile_size) * inv_h,
        };
    }
};

/// each tile can be assigned to a type (solid, various slopes, etc). This data does nothing in the editor and is only used for export
const TileDefinitions = struct {
    solid: aya.utils.FixedList(u16, 20) = aya.utils.FixedList(u16, 20).init(),
    slope_down: aya.utils.FixedList(u16, 10) = aya.utils.FixedList(u16, 10).init(),
    slope_down_steep: aya.utils.FixedList(u16, 10) = aya.utils.FixedList(u16, 10).init(),
    slope_up: aya.utils.FixedList(u16, 10) = aya.utils.FixedList(u16, 10).init(),
    slope_up_steep: aya.utils.FixedList(u16, 10) = aya.utils.FixedList(u16, 10).init(),

    pub fn toggleSelected(tiles: anytype, index: u16) void {
        if (tiles.indexOf(index)) |slice_index| {
            _ = tiles.swapRemove(slice_index);
        } else {
            tiles.append(index);
        }
    }

    pub fn drawPopup(self: *@This(), tileset: *Tileset) void {
        imgui.ogSetNextWindowSize(.{ .x = 210, .y = -1 }, imgui.ImGuiCond_Always);
        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##tileset-definitions", imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndPopup();

            inline for (@typeInfo(TileDefinitions).Struct.fields) |field, i| {
                imgui.igPushIDInt(@intCast(c_int, i));
                defer imgui.igPopID();

                drawTileIcon(field.name);

                imgui.ogDummy(.{});
                imgui.igSameLine(0, imgui.igGetFrameHeight() + 7);

                // replace underscores with spaces
                var buffer = aya.mem.tmp_allocator.alloc(u8, field.name.len) catch unreachable;
                for (field.name) |char, j| buffer[j] = if (char == '_') ' ' else char;

                imgui.igAlignTextToFramePadding();
                imgui.igText(buffer.ptr);

                imgui.igSameLine(0, 0);
                imgui.igSetCursorPosX(imgui.igGetWindowContentRegionWidth() - 35);

                if (imgui.ogButton("Tiles"))
                    imgui.igOpenPopup("tag-tiles", imgui.ImGuiWindowFlags_None);

                // imgui.igSetNextWindowPos(imgui.igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 1 });
                if (imgui.igBeginPopup("tag-tiles", imgui.ImGuiWindowFlags_None)) {
                    defer imgui.igEndPopup();
                    var list = &@field(self, field.name);
                    tileSelectorPopup(tileset, list);
                }
            }
        }
    }

    fn drawTileIcon(comptime name: []const u8) void {
        var tl = imgui.ogGetCursorScreenPos();
        var tr = tl;
        tr.x += imgui.igGetFrameHeight();
        var bl = tl;
        bl.y += imgui.igGetFrameHeight();
        var br = bl;
        br.x += imgui.igGetFrameHeight();

        var color = root.colors.rgbToU32(252, 186, 3);

        if (std.mem.eql(u8, name, "solid")) {
            imgui.ogImDrawList_AddQuadFilled(imgui.igGetWindowDrawList(), &tl, &tr, &br, &bl, color);
        } else if (std.mem.eql(u8, name, "slope_down")) {
            tl.y += imgui.igGetFrameHeight() / 2;
            imgui.ogImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), tl, bl, br, color);
        } else if (std.mem.eql(u8, name, "slope_down_steep")) {
            imgui.ogImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), tl, bl, br, color);
        } else if (std.mem.eql(u8, name, "slope_up")) {
            tr.y += imgui.igGetFrameHeight() / 2;
            imgui.ogImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), bl, br, tr, color);
        } else if (std.mem.eql(u8, name, "slope_up_steep")) {
            imgui.ogImDrawList_AddTriangleFilled(imgui.igGetWindowDrawList(), bl, br, tr, color);
        }
    }

    fn tileSelectorPopup(tileset: *Tileset, list: anytype) void {
        var content_start_pos = imgui.ogGetCursorScreenPos();
        const zoom: usize = if (tileset.tex.width < 200 and tileset.tex.height < 200) 2 else 1;
        const tile_spacing = tileset.spacing * zoom;
        const tile_size = tileset.tile_size * zoom;

        imgui.ogImage(tileset.tex.imTextureID(), @floatToInt(i32, tileset.tex.width * @intToFloat(f32, zoom)), @floatToInt(i32, tileset.tex.height * @intToFloat(f32, zoom)));

        // const draw_list = imgui.igGetWindowDrawList();

        // draw selected tiles
        var iter = list.iter();
        while (iter.next()) |value| {
            addTileToDrawList(tile_size, content_start_pos, value, tileset.tiles_per_row, tile_spacing);
        }

        // check input for toggling state
        if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
            if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
                var tile = tileIndexUnderPos(imgui.igGetIO().MousePos, @intCast(usize, tile_size + tile_spacing), content_start_pos);
                TileDefinitions.toggleSelected(list, @intCast(u16, tile.x + tile.y * tileset.tiles_per_row));
            }
        }

        if (imgui.igButton("Clear", .{ .x = -1 })) list.clear();
    }
};

pub const Animation = struct {
    tile: u8,
    rate: u16 = 500,
    tiles: aya.utils.FixedList(u16, 10) = aya.utils.FixedList(u16, 10).init(),

    pub fn init(tile: u8) Animation {
        var anim = Animation{ .tile = tile };
        anim.toggleSelected(tile);
        return anim;
    }

    pub fn toggleSelected(self: *Animation, index: u8) void {
        if (self.tiles.indexOf(index)) |slice_index| {
            _ = self.tiles.swapRemove(slice_index);
        } else {
            self.tiles.append(index);
        }
    }
};

pub fn tileIndexUnderPos(pos:  imgui.ImVec2, rect_size: usize, origin:  imgui.ImVec2) struct { x: usize, y: usize } {
    const final_pos = pos.subtract(origin);
    return .{ .x = @divTrunc(@floatToInt(usize, final_pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, final_pos.y), rect_size) };
}

/// adds a tile selection indicator to the draw list with an outline rectangle and a fill rectangle. Works for both tilesets and palettes.
pub fn addTileToDrawList(tile_size: usize, content_start_pos:  imgui.ImVec2, tile: u16, per_row: usize, tile_spacing: usize) void {
    const x = @mod(tile, per_row);
    const y = @divTrunc(tile, per_row);

    var tl =  imgui.ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, tile_size + tile_spacing), .y = @intToFloat(f32, y) * @intToFloat(f32, tile_size + tile_spacing) };
    tl.x += content_start_pos.x + @intToFloat(f32, tile_spacing);
    tl.y += content_start_pos.y + @intToFloat(f32, tile_spacing);
    imgui.ogAddQuadFilled(imgui.igGetWindowDrawList(), tl, @intToFloat(f32, tile_size), root.colors.rgbaToU32(116, 252, 253, 100));

    // offset by 1 extra pixel because quad outlines are drawn larger than the size passed in and we shrink the size by our outline width
    tl.x += 1;
    tl.y += 1;
    imgui.ogAddQuad(imgui.igGetWindowDrawList(), tl, @intToFloat(f32, tile_size - 2), root.colors.rgbToU32(116, 252, 253), 2);
}
