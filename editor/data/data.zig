const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

const fixme_tile_size: usize = 16;

const Camera = @import("../camera.zig").Camera;
pub const AppState = @import("app_state.zig").AppState;

pub const Tileset = @import("tileset.zig").Tileset;
const Point = struct { x: usize, y: usize };

/// given a world-space position returns the tile under it
pub fn tileIndexUnderPos(position: ImVec2, tile_size: usize) ?Point {
    if (position.x < 0 or position.y < 0) return null;
    return Point{ .x = @divTrunc(@floatToInt(usize, position.x), tile_size), .y = @divTrunc(@floatToInt(usize, position.y), tile_size) };
}

pub const Size = struct {
    w: usize,
    h: usize,

    pub fn init(width: usize, height: usize) Size {
        return .{ .w = width, .h = height };
    }
};

pub const Tile = extern union {
    value: u16,
    comps: packed struct {
        tile: u12,
        reserved: u1,
        horizontal: u1,
        vertical: u1,
        diagonal: u1,
    },
};

pub const Tilemap = struct {
    size: Size,
    tileset: Tileset,
    data: []u16,

    pub fn init(size: Size) Tilemap {
        return .{
            .size = size,
            .tileset = Tileset.init(fixme_tile_size),
            .data = aya.mem.allocator.alloc(u16, size.w * size.h) catch unreachable,
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

    pub fn getTile(self: Tilemap, x: usize, y: usize) u16 {
        if (x > self.w or y > self.h) {
            return 0;
        }
        return self.data[x + y * self.w];
    }

    pub fn setTile(self: Tilemap, x: usize, y: usize, value: u16) void {
        self.data[x + y * self.w] = value;
    }
};

pub const TilemapLayer = struct {
    name: [:0]const u8,
    tilemap: Tilemap,

    pub fn init(name: []const u8, size: Size) TilemapLayer {
        return .{
            .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable,
            .tilemap = Tilemap.init(size),
        };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
        self.tilemap.deinit();
    }

    pub fn draw(self: @This(), state: *AppState) void {}

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        // mouse positions need to be subtracted from origin to get into screen space (window space really)
        const origin = ogGetCursorScreenPos();
        // const mouse_screen = igGetIO().MousePos.subtract(ogGetCursorScreenPos());
        // const mouse_world = self.cam.igScreenToWorld(mouse_screen);

        if (tileIndexUnderPos(mouse_world, 16)) |tile| {
            const pos = math.Vec2{ .x = @intToFloat(f32, tile.x * self.tilemap.tileset.tile_size), .y = @intToFloat(f32, tile.y * self.tilemap.tileset.tile_size) };
            aya.draw.hollowRect(pos, 16, 16, 1, math.Color.yellow);
        }

        aya.draw.text(self.name, 100, 0, null);
    }
};

pub const AutoTilemapLayer = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8, size: Size) AutoTilemapLayer {
        return .{ .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
    }

    pub fn draw(self: @This(), state: *AppState) void {}

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        aya.draw.text(self.name, 100, 0, null);
    }
};

pub const EntityLayer = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8, size: Size) EntityLayer {
        return .{ .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
    }

    pub fn draw(self: @This(), state: *AppState) void {}

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        aya.draw.text(self.name, 100, 0, null);
    }
};

pub const LayerType = enum(u8) {
    tilemap,
    auto_tilemap,
    entity,
};

pub const Layer = union(LayerType) {
    tilemap: TilemapLayer,
    auto_tilemap: AutoTilemapLayer,
    entity: EntityLayer,

    pub fn init(layer_type: LayerType, layer_name: []const u8, size: Size) Layer {
        return switch (layer_type) {
            .tilemap => .{
                .tilemap = TilemapLayer.init(layer_name, size),
            },
            .auto_tilemap => .{
                .auto_tilemap = AutoTilemapLayer.init(layer_name, size),
            },
            .entity => .{
                .entity = EntityLayer.init(layer_name, size),
            },
        };
    }

    pub fn deinit(self: @This()) void {
        switch (self) {
            .tilemap => |layer| layer.deinit(),
            .auto_tilemap => |layer| layer.deinit(),
            .entity => |layer| layer.deinit(),
        }
    }

    pub fn name(self: @This()) [:0]const u8 {
        return switch (self) {
            .tilemap => |layer| layer.name,
            .auto_tilemap => |layer| layer.name,
            .entity => |layer| layer.name,
        };
    }

    /// used for doing the actual drawing of the layer as it appears in-game, not the editing UI
    pub fn draw(self: @This(), state: *AppState) void {
        switch (self) {
            .tilemap => |layer| layer.draw(state),
            .auto_tilemap => |layer| layer.draw(state),
            .entity => |layer| layer.draw(state),
        }
    }

    /// used for the editing UI, called after all other drawing so it can render on top of everything.
    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        switch (self) {
            .tilemap => |layer| layer.handleSceneInput(state, camera, mouse_world),
            .auto_tilemap => |layer| layer.handleSceneInput(state, camera, mouse_world),
            .entity => |layer| layer.handleSceneInput(state, camera, mouse_world),
        }
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
