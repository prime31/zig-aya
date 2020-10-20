const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const Color = aya.math.Color;
usingnamespace @import("imgui");


pub const Tileset = struct {
    tile_size: usize,
    spacing: usize,
    tex: aya.gfx.Texture = undefined,
    tiles_per_row: usize = 0,
    selected: u8 = 0,

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

            return false;
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

        return aya.gfx.Texture.initWithColorData(&pixels, 16 * 4, 16 * 4, .nearest);
    }

    pub fn setTexture(self: *Tileset, tex: aya.gfx.Texture) void {
        self.tex = tex;

        // calculate tiles_per_row
        var accum: usize = self.spacing * 2;
        while (true) {
            self.tiles_per_row += 1;
            accum += self.tile_size + self.spacing;
            if (accum >= self.tex.width) {
                break;
            }
        }
    }
};