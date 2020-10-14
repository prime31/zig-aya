const std = @import("std");
const aya = @import("aya");

pub const AppState = @import("app_state.zig").AppState;

pub const TilemapLayer = struct {
    name: [:0]const u8,

    pub fn init(name: []const u8) TilemapLayer {
        return .{ .name = aya.mem.allocator.dupeZ(u8, name) catch unreachable };
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.name);
    }

    pub fn draw(self: @This(), state: *AppState) void {
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

    pub fn draw(self: @This(), state: *AppState) void {
        aya.draw.text(self.name, 100, 20, null);
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

    pub fn draw(self: @This(), state: *AppState) void {
        aya.draw.text(self.name, 100, 40, null);
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

    pub fn deinit(self: Layer) void {
        switch (self) {
            .tilemap => |layer| layer.deinit(),
            .auto_tilemap => |layer| layer.deinit(),
            .entity => |layer| layer.deinit(),
        }
    }

    pub fn name(self: Layer) [:0]const u8 {
        return switch (self) {
            .tilemap => |layer| layer.name,
            .auto_tilemap => |layer| layer.name,
            .entity => |layer| layer.name,
        };
    }

    pub fn draw(self: Layer, state: *AppState) void {
        switch (self) {
            .tilemap => |layer| layer.draw(state),
            .auto_tilemap => |layer| layer.draw(state),
            .entity => |layer| layer.draw(state),
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
