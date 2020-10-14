const std = @import("std");
const aya = @import("aya");

const Layer = @import("data.zig").Layer;
const Entity = @import("data.zig").Entity;

pub const AppState = struct {
    layers: std.ArrayList(Layer),
    entities: std.ArrayList(Entity),
    selected_layer_index: usize = 0,

    pub fn init() AppState {
        return .{
            .layers = std.ArrayList(Layer).init(aya.mem.allocator),
            .entities = std.ArrayList(Entity).init(aya.mem.allocator),
        };
    }

    pub fn initWithTestData() AppState {
        var state = AppState{
            .layers = std.ArrayList(Layer).init(aya.mem.allocator),
            .entities = std.ArrayList(Entity).init(aya.mem.allocator),
        };

        state.layers.append(Layer.init(.tilemap, "Tilemap 1")) catch unreachable;
        state.layers.append(Layer.init(.auto_tilemap, "Auto Tilemap")) catch unreachable;
        state.layers.append(Layer.init(.tilemap, "Tilemap 2")) catch unreachable;
        state.layers.append(Layer.init(.entity, "Entities")) catch unreachable;

        return state;
    }

    pub fn deinit(self: AppState) void {
        self.layers.deinit();
        self.entities.deinit();
    }
};