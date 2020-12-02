const std = @import("std");
const aya = @import("aya");

const Size = @import("data.zig").Size;
const Layer = @import("root").layers.Layer;
const Component = @import("data.zig").Component;

pub const AppState = struct {
    map_size: Size = .{ .w = 64, .h = 64 },
    tile_size: usize = 16,
    snap_size: u8 = 0,
    layers: std.ArrayList(Layer),
    components: std.ArrayList(Component),
    next_component_id: u8 = 0,
    selected_layer_index: usize = 0,

    pub fn init() AppState {
        return .{
            .layers = std.ArrayList(Layer).init(aya.mem.allocator),
            .components = std.ArrayList(Component).init(aya.mem.allocator),
        };
    }

    pub fn initWithTestData() AppState {
        var state = init();

        state.layers.append(Layer.init(.auto_tilemap, "Auto Tilemap 1", state.map_size, state.tile_size)) catch unreachable;
        state.layers.append(Layer.init(.tilemap, "Tilemap 1", state.map_size, state.tile_size)) catch unreachable;
        state.layers.append(Layer.init(.auto_tilemap, "Auto Tilemap 2", state.map_size, state.tile_size)) catch unreachable;
        state.layers.append(Layer.init(.tilemap, "Tilemap 2", state.map_size, state.tile_size)) catch unreachable;

        // components
        var comp1 = state.createComponent("SomeComponent");
        comp1.addProperty(.{ .float = 6.666 });
        aya.mem.copyZ(u8, &comp1.props.items[comp1.props.items.len - 1].name, "some_float");

        comp1.addProperty(.{ .bool = true });
        aya.mem.copyZ(u8, &comp1.props.items[comp1.props.items.len - 1].name, "toggle_bool");

        comp1.addProperty(.{ .string = undefined });
        aya.mem.copyZ(u8, &comp1.props.items[comp1.props.items.len - 1].name, "the_string");

        comp1.addProperty(.{ .int = 55 });
        aya.mem.copyZ(u8, &comp1.props.items[comp1.props.items.len - 1].name, "an_int");

        comp1.addProperty(.{ .vec2 = .{ .x = 5, .y = 10 } });
        aya.mem.copyZ(u8, &comp1.props.items[comp1.props.items.len - 1].name, "a_vec2");

        var comp2 = state.createComponent("Thingy");
        comp2.addProperty(.{ .float = 55 });
        aya.mem.copyZ(u8, &comp2.props.items[comp2.props.items.len - 1].name, "width");
        comp2.addProperty(.{ .float = 55 });
        aya.mem.copyZ(u8, &comp2.props.items[comp2.props.items.len - 1].name, "height");

        // entities
        state.layers.append(Layer.init(.entity, "Entities", state.map_size, state.tile_size)) catch unreachable;

        var entity_layer = &state.layers.items[state.layers.items.len - 1].entity;
        entity_layer.addEntity("First", .{ .x = 10, .y = 10 });
        entity_layer.addEntity("Second", .{ .x = 50, .y = 50 });
        entity_layer.addEntity("Black Wall", .{ .x = 90, .y = 20 });

        entity_layer.entities.items[0].addComponent(comp1.spawnInstance());
        entity_layer.entities.items[1].collider = .{ .box = .{ .w = 25, .h = 25 } };
        entity_layer.entities.items[2].collider = .{ .circle = .{ .r = 25 } };

        return state;
    }

    pub fn deinit(self: AppState) void {
        for (self.layers.items) |*layer| layer.deinit();
        self.layers.deinit();

        for (self.components.items) |*comp| comp.deinit();
        self.components.deinit();
    }

    pub fn createComponent(self: *@This(), name: []const u8) *Component {
        defer self.next_component_id += 1;

        var comp = self.components.addOne() catch unreachable;
        comp.* = Component.init(self.next_component_id, name);
        return comp;
    }

    pub fn componentWithId(self: @This(), id: u8) *Component {
        for (self.components.items) |*comp| {
            if (comp.id == id) return comp;
        }
        unreachable;
    }
};
