const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const editor = @import("../editor.zig");

pub const AppState = @import("app_state.zig").AppState;
pub const Tilemap = @import("tilemap.zig").Tilemap;
pub const Tileset = @import("tileset.zig").Tileset;
pub const Layer = @import("layer.zig").Layer;
pub const LayerType = @import("layer.zig").LayerType;
pub const TilemapLayer = @import("tilemap_layer.zig").TilemapLayer;
pub const AutoTilemapLayer = @import("auto_tilemap_layer.zig").AutoTilemapLayer;
pub const EntityLayer = @import("entity_layer.zig").EntityLayer;

const Camera = @import("../camera.zig").Camera;
pub const Point = struct { x: usize, y: usize };

pub const Size = struct {
    w: usize,
    h: usize,

    pub fn init(width: usize, height: usize) Size {
        return .{ .w = width, .h = height };
    }
};

/// convenience struct for housing a tile that saves the trouble of bitshifting for setting/getting upper bits
pub const Tile = extern union {
    value: u16,
    comps: packed struct {
        tile_index: u12,
        reserved: u1,
        horizontal: u1,
        vertical: u1,
        diagonal: u1,
    },

    pub fn init(value: u16) Tile {
        return .{ .value = value };
    }

    pub fn flipH(self: *Tile) void {
        self.comps.horizontal = @boolToInt(self.comps.horizontal != 1);
    }

    pub fn flipV(self: *Tile) void {
        self.comps.vertical = @boolToInt(self.comps.vertical != 1);
    }

    pub fn flipD(self: *Tile) void {
        self.comps.diagonal = @boolToInt(self.comps.diagonal != 1);
    }
};

pub const TileRenderInfo = struct {
    id: u16,
    rot: f32 = 0,
    sx: f32 = 1,
    sy: f32 = 1,
    ox: f32 = 0,
    oy: f32 = 0,

    pub fn init(tid: u16, tile_size: usize) TileRenderInfo {
        const tile = Tile{ .value = tid };
        var info = TileRenderInfo{ .id = tile.comps.tile_index };

        const flip_h = tile.comps.horizontal == 1;
        const flip_v = tile.comps.vertical == 1;

        // deal with flipping/rotating if necessary
        if (tile.comps.horizontal == 1 or tile.comps.vertical == 1 or tile.comps.diagonal == 1) {
            // set the origin based on the tile_size if we are rotated
            info.ox = @intToFloat(f32, tile_size) / 2.0;
            info.oy = @intToFloat(f32, tile_size) / 2.0;

            if (flip_h) info.sx *= -1;
            if (flip_v) info.sy *= -1;

            if (tile.comps.diagonal == 1) {
                if (flip_h and flip_v) {
                    info.rot = aya.math.pi_over_2;
                } else if (flip_h) {
                    info.rot = -aya.math.pi_over_2;
                } else if (flip_v) {
                    info.rot = aya.math.pi_over_2;
                } else {
                    info.rot = -aya.math.pi_over_2;
                }
            }
        }

        return info;
    }

    pub fn transformMatrix(self: TileRenderInfo, x: f32, y: f32) math.Mat32 {
        return aya.math.Mat32.initTransform(.{ .x = x, .y = y, .angle = self.rot, .sx = self.sx, .sy = self.sy, .ox = self.ox, .oy = self.oy });
    }

    pub fn draw(self: TileRenderInfo, tileset: Tileset, position: math.Vec2) void {
        const vp = tileset.viewportForTile(self.id);

        const tx = position.x + self.ox;
        const ty = position.y + self.oy;
        const mat = self.transformMatrix(tx, ty);

        aya.draw.texViewport(tileset.tex, vp, mat);
    }
};

pub const Entity = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8) Entity {
        return .{ .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
    }
};
