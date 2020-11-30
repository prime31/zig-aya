const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const editor = @import("../editor.zig");

pub const AppState = @import("app_state.zig").AppState;
pub const Tilemap = @import("tilemap.zig").Tilemap;
pub const Tileset = @import("tileset.zig").Tileset;
pub const Brushset = @import("brushset.zig").Brushset;

pub const Rule = @import("rules.zig").Rule;
pub const RuleSet = @import("rules.zig").RuleSet;
pub const RuleTile = @import("rules.zig").RuleTile;

// entity and built-in components
pub const Entity = @import("entity.zig").Entity;
pub const Transform = @import("entity.zig").Transform;
pub const Sprite = @import("entity.zig").Sprite;
pub const Collider = @import("entity.zig").Collider;
pub const BoxCollider = @import("entity.zig").BoxCollider;
pub const CircleCollider = @import("entity.zig").CircleCollider;

pub const Component = @import("components.zig").Component;
pub const ComponentInstance = @import("components.zig").ComponentInstance;

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
        if (flip_h or flip_v or tile.comps.diagonal == 1) {
            // set the origin based on the tile_size if we are rotated
            info.ox = @intToFloat(f32, tile_size) / 2.0;
            info.oy = @intToFloat(f32, tile_size) / 2.0;

            if (flip_h) info.sx *= -1;
            if (flip_v) info.sy *= -1;

            if (tile.comps.diagonal == 1) {
                if (flip_h and flip_v) {
                    info.rot = aya.math.pi_over_2;
                    info.sy *= -1;
                } else if (flip_h) {
                    info.rot = -aya.math.pi_over_2;
                    info.sy *= -1;
                } else if (flip_v) {
                    info.rot = aya.math.pi_over_2;
                    info.sx *= -1;
                } else {
                    info.rot = -aya.math.pi_over_2;
                    info.sx *= -1;
                }
            }
        }

        return info;
    }

    pub fn transformMatrix(self: TileRenderInfo, x: f32, y: f32) math.Mat32 {
        return aya.math.Mat32.initTransform(.{ .x = x, .y = y, .angle = self.rot, .sx = self.sx, .sy = self.sy, .ox = self.ox, .oy = self.oy });
    }

    /// tileset can be a Tileset or a Brushset
    pub fn draw(self: TileRenderInfo, tileset: anytype, position: math.Vec2) void {
        const vp = tileset.viewportForTile(self.id);

        const tx = position.x + self.ox;
        const ty = position.y + self.oy;
        const mat = self.transformMatrix(tx, ty);

        aya.draw.texViewport(tileset.tex, vp, mat);
    }
};

