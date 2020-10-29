const std = @import("std");
const aya = @import("aya");

const Size = @import("data.zig").Size;
const Layer = @import("data.zig").Layer;

pub const AppState = struct {
    map_size: Size = .{ .w = 64, .h = 64 },
    tile_size: usize = 16,
    layers: std.ArrayList(Layer),
    selected_layer_index: usize = 0,

    pub fn init() AppState {
        return .{
            .layers = std.ArrayList(Layer).init(aya.mem.allocator),
        };
    }

    pub fn initWithTestData() AppState {
        var state = AppState{
            .layers = std.ArrayList(Layer).init(aya.mem.allocator),
        };

        state.layers.append(Layer.init(.auto_tilemap, "Auto Tilemap 1", state.map_size, state.tile_size)) catch unreachable;
        state.layers.append(Layer.init(.tilemap, "Tilemap 1", state.map_size, state.tile_size)) catch unreachable;
        state.layers.append(Layer.init(.auto_tilemap, "Auto Tilemap 2", state.map_size, state.tile_size)) catch unreachable;
        state.layers.append(Layer.init(.tilemap, "Tilemap 2", state.map_size, state.tile_size)) catch unreachable;

        var entities = Layer.init(.entity, "Entities", state.map_size, state.tile_size);
        state.layers.append(entities) catch unreachable;
        var entity_layer = &state.layers.items[state.layers.items.len - 1].entity;
        entity_layer.addEntity("First");
        entity_layer.addEntity("Second");
        entity_layer.addEntity("Black Wall");

        return state;
    }

    pub fn deinit(self: AppState) void {
        self.layers.deinit();
    }
};
