const std = @import("std");
const aya = @import("aya");
const data = @import("data.zig");

const ComponentInstance = data.ComponentInstance;

pub const Entity = struct {
    id: u8 = 0,
    name: [25:0]u8 = undefined,
    components: std.ArrayList(ComponentInstance),
    sprite: ?Sprite = null,
    collider: ?Collider = null,

    pub fn init(id: u8, name: []const u8) Entity {
        var entity = Entity{
            .id = id,
            .components = std.ArrayList(ComponentInstance).init(aya.mem.allocator),
        };
        aya.mem.copyZ(u8, &entity.name, name);
        return entity;
    }

    pub fn deinit(self: @This()) void {
        for (self.components.items) |*comp| comp.deinit();
        self.components.deinit();
    }

    pub fn addComponent(self: *@This(), component: ComponentInstance) void {
        self.components.append(component) catch unreachable;
    }
};

pub const Sprite = struct {

};

pub const Collider = union(enum) {
    box: BoxCollider,
    circle: CircleCollider,
};

pub const BoxCollider = struct {
    pos: aya.math.Vec2,
    w: f32,
    h: f32,

    pub fn init(pos: aya.math.Vec2, w: f32, h: f32) BoxCollider {
        return .{ .pos = pos, .w = w, .h = h };
    }
};

pub const CircleCollider = struct {
    pos: aya.math.Vec2,
    r: f32,

    pub fn init(pos: aya.math.Vec2, r: f32) CircleCollider {
        return .{ .pos = pos, .r = r };
    }
};