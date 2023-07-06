const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const root = @import("../main.zig");
const utils = root.utils;
const imgui = @import("imgui");

const Color = aya.math.Color;
const AppState = @import("app_state.zig").AppState;
const Tile = @import("data.zig").Tile;

// TODO: strip out all the stuff not needed in here since it is locked to a single generated texture
pub const Brushset = struct {
    tile_size: usize,
    spacing: usize,
    tex: aya.gfx.Texture = undefined,
    tiles_per_row: usize = 0,
    selected: Tile = Tile.init(0),

    pub fn init(tile_size: usize) Brushset {
        var bs = Brushset{
            .tile_size = tile_size,
            .spacing = 0,
        };
        bs.setTexture(generateTexture());
        return bs;
    }

    pub fn deinit(self: Brushset) void {
        self.tex.deinit();
    }

    /// generates a texture with 3x3, 16px blocks of color
    fn generateTexture() aya.gfx.Texture {
        const tile_size = 16;
        var pixels: [tile_size * 3 * tile_size * 3]u32 = undefined;
        var y: usize = 0;
        while (y < tile_size * 3) : (y += 1) {
            var x: usize = 0;
            while (x < tile_size * 3) : (x += 1) {
                const xx = @divTrunc(x, tile_size);
                const yy = @divTrunc(y, tile_size);
                pixels[x + y * tile_size * 3] = root.colors.brushes[xx + yy * 3];
            }
        }

        return aya.gfx.Texture.initWithData(u32, tile_size * 3, tile_size * 3, &pixels);
    }

    fn setTexture(self: *Brushset, tex: aya.gfx.Texture) void {
        self.tex = tex;

        // calculate tiles_per_row
        var accum: usize = self.spacing * 2;
        while (true) {
            self.tiles_per_row += 1;
            accum += self.tile_size + self.spacing;
            if (accum >= @as(usize, @intFromFloat(self.tex.width))) {
                break;
            }
        }
    }

    /// draws the floating Brushes window
    pub fn draw(self: *Brushset) void {
        const zoom: usize = if (self.tex.width < 200 and self.tex.height < 200) 2 else 1;
        const first_pos = imgui.igGetIO().DisplaySize.subtract(.{
            .x = 150 + self.tex.width * @as(f32, @floatFromInt(zoom)),
            .y = 150 + self.tex.height * @as(f32, @floatFromInt(zoom)),
        });
        imgui.ogSetNextWindowPos(first_pos, imgui.ImGuiCond_FirstUseEver, .{});

        if (imgui.igBegin("Brushes", null, imgui.ImGuiWindowFlags_NoCollapse | imgui.ImGuiWindowFlags_NoResize | imgui.ImGuiWindowFlags_AlwaysAutoResize | imgui.ImGuiWindowFlags_NoFocusOnAppearing | imgui.ImGuiWindowFlags_NoDocking)) {
            self.drawWithoutWindow();
            imgui.igEnd();
        }
    }

    pub fn drawWithoutWindow(self: *Brushset) void {
        const zoom: usize = if (self.tex.width < 200 and self.tex.height < 200) 2 else 1;
        var origin = imgui.ogGetCursorScreenPos();
        imgui.ogImage(self.tex.imTextureID(), @as(i32, @intFromFloat(self.tex.width)) * @as(i32, @intCast(zoom)), @as(i32, @intFromFloat(self.tex.height)) * @as(i32, @intCast(zoom)));

        // draw selected tile
        addTileToDrawList(self.tile_size * zoom, origin, self.selected.comps.tile_index, self.tiles_per_row, self.spacing * zoom);

        // check input for toggling selected state
        if (imgui.igIsItemHovered(imgui.ImGuiHoveredFlags_None)) {
            if (imgui.igIsMouseClicked(imgui.ImGuiMouseButton_Left, false)) {
                var tile = tileIndexUnderPos(imgui.igGetIO().MousePos, @as(usize, @intCast(self.tile_size * zoom + self.spacing * zoom)), origin);
                self.selected.value = @as(u8, @intCast(tile.x + tile.y * self.tiles_per_row));
                //imgui.igCloseCurrentPopup(); // TODO: why does this close this popup and the one under it?
            }
        }
    }

    pub fn viewportForTile(self: Brushset, tile: usize) aya.math.RectI {
        const x = @mod(tile, self.tiles_per_row);
        const y = @divTrunc(tile, self.tiles_per_row);

        return .{
            .x = @as(i32, @intCast((x * self.tile_size + self.spacing) + self.spacing)),
            .y = @as(i32, @intCast((y * self.tile_size + self.spacing) + self.spacing)),
            .w = @as(i32, @intCast(self.tile_size)),
            .h = @as(i32, @intCast(self.tile_size)),
        };
    }
};

pub fn tileIndexUnderPos(pos: imgui.ImVec2, rect_size: usize, origin: imgui.ImVec2) struct { x: usize, y: usize } {
    const final_pos = pos.subtract(origin);
    return .{ .x = @divTrunc(@as(usize, @intFromFloat(final_pos.x)), rect_size), .y = @divTrunc(@as(usize, @intFromFloat(final_pos.y)), rect_size) };
}

/// adds a tile selection indicator to the draw list with an outline rectangle and a fill rectangle. Works for both tilesets and palettes.
pub fn addTileToDrawList(tile_size: usize, content_start_pos: imgui.ImVec2, tile: u16, per_row: usize, tile_spacing: usize) void {
    const x = @mod(tile, per_row);
    const y = @divTrunc(tile, per_row);

    var tl = imgui.ImVec2{ .x = @as(f32, @floatFromInt(x)) * @as(f32, @floatFromInt(tile_size + tile_spacing)), .y = @as(f32, @floatFromInt(y)) * @as(f32, @floatFromInt(tile_size + tile_spacing)) };
    tl.x += content_start_pos.x + @as(f32, @floatFromInt(tile_spacing));
    tl.y += content_start_pos.y + @as(f32, @floatFromInt(tile_spacing));
    imgui.ogAddQuadFilled(imgui.igGetWindowDrawList(), tl, @as(f32, @floatFromInt(tile_size)), root.colors.rgbaToU32(116, 252, 253, 100));

    // offset by 1 extra pixel because quad outlines are drawn larger than the size passed in and we shrink the size by our outline width
    tl.x += 1;
    tl.y += 1;
    imgui.ogAddQuad(imgui.igGetWindowDrawList(), tl, @as(f32, @floatFromInt(tile_size - 2)), root.colors.rgbToU32(116, 252, 253), 2);
}
