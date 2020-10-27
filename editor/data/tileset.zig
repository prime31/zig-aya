const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const root = @import("root");
const Color = aya.math.Color;
usingnamespace @import("imgui");

pub const AppState = @import("app_state.zig").AppState;
pub const Tile = @import("data.zig").Tile;

pub const Tileset = struct {
    tile_size: usize,
    spacing: usize,
    tex: aya.gfx.Texture = undefined,
    tiles_per_row: usize = 0,
    tiles_per_col: usize = 0,
    selected: Tile = Tile.init(0),

    pub fn init(tile_size: usize) Tileset {
        var ts = Tileset{
            .tile_size = tile_size,
            .spacing = 0,
        };
        ts.setTexture(generateTexture());
        return ts;
    }

    pub fn deinit(self: Tileset) void {
        self.tex.deinit();
    }

    pub fn loadTexture(self: *Tileset, file: []const u8) void {
        var spacing: usize = 0;
        if (!validateImage(file, self.tile_size, &spacing)) {
            std.debug.print("invalid file. failed validation\n", .{});
            return;
        }

        self.tex.deinit();
        self.spacing = spacing;
        self.setTexture(aya.gfx.Texture.initFromFile(file, .nearest) catch unreachable);
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

                // add a line for testing rotation/flipping
                if (x == 15 or x == 14) pixels[x + y * 16 * 4] = Color.white.value;
            }
        }

        return aya.gfx.Texture.initWithColorData(&pixels, 16 * 4, 16 * 4, .nearest);
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
            if (accum >= self.tex.width) {
                break;
            }
        }

        accum = self.spacing * 2;
        while (true) {
            self.tiles_per_col += 1;
            accum += self.tile_size + 2 * self.spacing;
            if (accum >= self.tex.height) {
                break;
            }
        }
    }

    pub fn draw(self: *Tileset) void {
        const zoom: usize = if (self.tex.width < 200 and self.tex.height < 200) 2 else 1;
        const first_pos = igGetIO().DisplaySize.subtract(.{
            .x = 150 + @intToFloat(f32, self.tex.width) * @intToFloat(f32, zoom),
            .y = 150 + @intToFloat(f32, self.tex.height) * @intToFloat(f32, zoom),
        });
        igSetNextWindowPos(first_pos, ImGuiCond_FirstUseEver, .{});

        defer igEnd();
        if (!igBegin("Palette", null, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize)) return;

        var origin = ogGetCursorScreenPos();
        ogImage(self.tex.imTextureID(), self.tex.width * @intCast(i32, zoom), self.tex.height * @intCast(i32, zoom));

        // draw selected tile
        addTileToDrawList(self.tile_size * zoom, origin, self.selected.comps.tile_index, self.tiles_per_row, self.spacing * zoom);

        // check input for toggling selected state
        if (igIsItemHovered(ImGuiHoveredFlags_None)) {
            if (igIsMouseClicked(ImGuiMouseButton_Left, false)) {
                var tile = tileIndexUnderPos(igGetIO().MousePos, @intCast(usize, self.tile_size * zoom + self.spacing * zoom), origin);
                self.selected.value = @intCast(u8, tile.x + tile.y * self.tiles_per_row);
            }
        }
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
};

pub fn tileIndexUnderPos(pos: ImVec2, rect_size: usize, origin: ImVec2) struct { x: usize, y: usize } {
    const final_pos = pos.subtract(origin);
    return .{ .x = @divTrunc(@floatToInt(usize, final_pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, final_pos.y), rect_size) };
}

/// adds a tile selection indicator to the draw list with an outline rectangle and a fill rectangle. Works for both tilesets and palettes.
pub fn addTileToDrawList(tile_size: usize, content_start_pos: ImVec2, tile: u16, per_row: usize, tile_spacing: usize) void {
    const x = @mod(tile, per_row);
    const y = @divTrunc(tile, per_row);

    var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, tile_size + tile_spacing), .y = @intToFloat(f32, y) * @intToFloat(f32, tile_size + tile_spacing) };
    tl.x += content_start_pos.x + @intToFloat(f32, tile_spacing);
    tl.y += content_start_pos.y + @intToFloat(f32, tile_spacing);
    ogAddQuadFilled(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size), root.colors.rgbaToU32(116, 252, 253, 100));

    // offset by 1 extra pixel because quad outlines are drawn larger than the size passed in and we shrink the size by our outline width
    tl.x += 1;
    tl.y += 1;
    ogAddQuad(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size - 2), root.colors.rgbToU32(116, 252, 253), 2);
}
