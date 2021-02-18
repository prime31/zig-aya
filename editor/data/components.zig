const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const data = @import("data.zig");

pub const Component = struct {
    id: u8,
    name: [25:0]u8 = undefined,
    props: []Property = &[_]Property{},
    next_property_id: u8 = 0,

    pub fn init(id: u8, name: []const u8) Component {
        var comp = Component{ .id = id };
        std.mem.set(u8, &comp.name, 0);
        aya.mem.copyZ(u8, &comp.name, name);
        return comp;
    }

    pub fn deinit(self: Component) void {
        for (self.props) |*prop| prop.deinit();
        aya.mem.allocator.free(self.props);
    }

    pub fn addProperty(self: *Component, prop: PropertyValue) void {
        defer self.next_property_id += 1;
        aya.utils.array.append(Property, &self.props, Property.init(self.next_property_id, prop)) catch unreachable;
    }

    pub fn spawnInstance(self: Component) ComponentInstance {
        return ComponentInstance.init(self);
    }

    pub fn propertyWithId(self: @This(), id: u8) *Property {
        for (self.props) |*prop| {
            if (prop.id == id) return prop;
        }
        unreachable;
    }
};

pub const Property = struct {
    id: u8,
    name: [25:0]u8,
    value: PropertyValue,

    pub fn init(id: u8, value: PropertyValue) Property {
        return .{ .id = id, .name = [_:0]u8{0} ** 25, .value = value };
    }

    pub fn deinit(self: Property) void {
        // if we have allocated memory clean it up
        if (self.value == .enum_values)
            aya.mem.allocator.free(self.value.enum_values);
    }
};

pub const PropertyValue = union(enum) {
    string: [25:0]u8,
    int: i32,
    float: f32,
    bool: bool,
    vec2: math.Vec2,
    enum_values: [][25:0]u8,
    entity_link: u8,

    pub fn propertyInstanceValue(self: @This()) PropertyInstanceValue {
        return switch (self) {
            .string => |str| .{ .string = str },
            .int => |i| .{ .int = i },
            .float => |f| .{ .float = f },
            .bool => |b| .{ .bool = b },
            .vec2 => |v| .{ .vec2 = v },
            .enum_values => .{ .enum_value = 0 },
            .entity_link => |link| .{ .entity_link = link },
        };
    }
};

pub const PropertyInstanceValue = union(enum) {
    string: [25:0]u8,
    int: i32,
    float: f32,
    bool: bool,
    vec2: math.Vec2,
    enum_value: u8,
    entity_link: u8,
};

/// ComponentInstances represent the component's data on an Entity. Only the actual values are stored along with the Component.id
/// so that the field names can be looked up and property add/delete can be identified and synced.
pub const ComponentInstance = struct {
    component_id: u8,
    props: std.ArrayList(PropertyInstance),

    pub fn init(src_component: Component) ComponentInstance {
        var comp = ComponentInstance{
            .component_id = src_component.id,
            .props = std.ArrayList(PropertyInstance).init(aya.mem.allocator),
        };

        for (src_component.props) |prop| comp.addProperty(prop);

        return comp;
    }

    pub fn deinit(self: ComponentInstance) void {
        for (self.props.items) |*prop| prop.deinit();
        self.props.deinit();
    }

    pub fn clone(self: ComponentInstance, state: *data.AppState) ComponentInstance {
        var src_component = state.componentWithId(self.component_id);
        var comp = init(src_component.*);
        for (self.props.items) |prop, i| comp.props.items[i] = prop;
        return comp;
    }

    pub fn removeProperty(self: *@This(), property_id: u8) void {
        var id = for (self.props.items) |prop, i| {
            if (prop.property_id == property_id) {
                break i;
            }
        } else std.math.maxInt(usize);
        _ = self.props.orderedRemove(id);
    }

    pub fn addProperty(self: *@This(), prop: Property) void {
        self.props.append(PropertyInstance.init(prop.id, prop.value.propertyInstanceValue())) catch unreachable;
    }
};

pub const PropertyInstance = struct {
    property_id: u8,
    value: PropertyInstanceValue,

    pub fn init(id: u8, value: PropertyInstanceValue) PropertyInstance {
        return .{ .property_id = id, .value = value };
    }

    pub fn deinit(self: PropertyInstance) void {}
};
