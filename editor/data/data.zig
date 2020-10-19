const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");

const Camera = @import("../camera.zig").Camera;
pub const AppState = @import("app_state.zig").AppState;

pub fn tileIndexUnderPos(position: ImVec2, origin: ImVec2, tile_size: usize) struct { x: usize, y: usize } {
    var pos = position;
    pos.x -= origin.x;
    pos.y -= origin.y;

    if (pos.x < 0 or pos.y < 0) return .{ .x = 0, .y = 0 };
    return .{ .x = @divTrunc(@floatToInt(usize, pos.x), tile_size), .y = @divTrunc(@floatToInt(usize, pos.y), tile_size) };
}

pub const Tilemap = struct {
    w: usize,
    h: usize,
    data: []u8,

    pub fn init(width: usize, height: usize) Tilemap {
        return .{
            .w = width,
            .h = height,
            .data = aya.mem.allocator.alloc(u8, width * height) catch unreachable,
        };
    }

    pub fn initWithData(width: usize, height: usize, data: []const u8) Tilemap {
        return .{
            .w = width,
            .h = height,
            .data = std.mem.dupe(aya.mem.allocator, u8, data) catch unreachable,
        };
    }

    pub fn deinit(self: Tilemap) void {
        aya.mem.allocator.free(self.data);
    }

    pub fn clear(self: TilemapLayer) void {
        std.mem.set(u8, self.data, 0);
    }

    pub fn getTile(self: Tilemap, x: usize, y: usize) u8 {
        if (x > self.w or y > self.h) {
            return 0;
        }
        return self.layers[self.current_layer].data[x + y * self.w];
    }

    pub fn setTile(self: Tilemap, x: usize, y: usize, value: u8) void {
        self.layers[self.current_layer].data[x + y * self.w] = value;
    }
};

pub const TilemapLayer = struct {
    name: [:0]const u8,
    tilemap: Tilemap,

    pub fn init(name: []const u8) TilemapLayer {
        return .{
            .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable,
            .tilemap = Tilemap.init(200, 200),
        };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
        self.tilemap.deinit();
    }

    pub fn draw(self: @This(), state: *AppState) void {}

    pub fn handleSceneInput(self: @This(), state: *AppState, camera: Camera, mouse_world: ImVec2) void {
        const origin = ogGetCursorScreenPos();
        // const mouse_screen = igGetIO().MousePos.subtract(ogGetCursorScreenPos());
        // const mouse_world = self.cam.igScreenToWorld(mouse_screen);

        var tile = tileIndexUnderPos(mouse_world, origin, 16);
        std.debug.print("tile: {d}\n", .{tile});
        aya.draw.text(self.name, 100, 0, null);
    }
};

pub const AutoTilemapLayer = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8) AutoTilemapLayer {
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

    pub fn init(name: []const u8) EntityLayer {
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

    pub fn init(layer_type: LayerType, layer_name: []const u8) Layer {
        return switch (layer_type) {
            .tilemap => .{
                .tilemap = TilemapLayer.init(layer_name),
            },
            .auto_tilemap => .{
                .auto_tilemap = AutoTilemapLayer.init(layer_name),
            },
            .entity => .{
                .entity = EntityLayer.init(layer_name),
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
