const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const data = @import("data.zig");

const Size = data.Size;
const Point = data.Point;
const Tileset = data.Tileset;
const TileRenderInfo = data.TileRenderInfo;

pub const Tilemap = struct {
    size: Size,
    data: []u16,

    pub fn init(size: Size) Tilemap {
        var tmp_data = aya.mem.allocator.alloc(u16, size.w * size.h) catch unreachable;
        std.mem.set(u16, tmp_data, 0);
        return .{
            .size = size,
            .data = tmp_data,
        };
    }

    pub fn initWithData(data: []const u16, size: Size) Tilemap {
        return .{
            .size = size,
            .data = std.mem.dupe(aya.mem.allocator, u16, data) catch unreachable,
        };
    }

    pub fn deinit(self: Tilemap) void {
        aya.mem.allocator.free(self.data);
    }

    pub fn clear(self: TilemapLayer) void {
        std.mem.set(u16, self.data, 0);
    }

    pub fn getTile(self: Tilemap, tile: Point) u16 {
        if (tile.x > self.size.w or tile.y > self.size.h) {
            return 0;
        }
        return self.data[tile.x + tile.y * self.size.w];
    }

    pub fn setTile(self: Tilemap, tile: Point, value: u16) void {
        self.data[tile.x + tile.y * self.size.w] = value;
    }

    pub fn draw(self: @This(), tileset: Tileset) void {
        var y: usize = 0;
        while (y < self.size.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.size.w) : (x += 1) {
                const tile = self.data[x + y * self.size.w];
                if (tile == 0) continue;

                var info = TileRenderInfo.init(tile - 1, tileset.tile_size);
                info.draw(tileset, .{ .x = @intToFloat(f32, x * tileset.tile_size), .y = @intToFloat(f32, y * tileset.tile_size) });
            }
        }
    }
};