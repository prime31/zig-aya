const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const data = @import("data.zig");

const ComponentInstance = data.ComponentInstance;

pub const Entity = struct {
    id: u8 = 0,
    name: [25:0]u8 = undefined,
    components: std.ArrayList(ComponentInstance),
    transform: Transform,
    sprite: ?Sprite = null,
    collider: ?Collider = null,

    pub fn init(id: u8, name: []const u8, position: math.Vec2) Entity {
        var entity = Entity{
            .id = id,
            .components = std.ArrayList(ComponentInstance).init(aya.mem.allocator),
            .transform = .{ .pos = position },
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

    pub fn transformMatrix(self: @This()) math.Mat32 {
        // we definitely have a sprite if this is called so its safe to access it
        const t = self.transform;
        return aya.math.Mat32.initTransform(.{ .x = t.pos.x, .y = t.pos.y, .angle = aya.math.toRadians(t.rot), .sx = t.scale.x, .sy = t.scale.y, .ox = self.sprite.?.origin.x, .oy = self.sprite.?.origin.y });
    }

    pub fn intersects(self: @This(), rect: math.Rect) bool {
        // we need to have either a collider or a sprite to be picked
        if (self.collider) |collider| return collider.bounds(self.transform.pos).intersects(rect);
        if (self.sprite) |sprite| return sprite.bounds(self.transform).intersects(rect);

        return false;
    }

    pub fn bounds(self: @This()) math.Rect {
        if (self.sprite == null and self.collider == null) return .{ .x = self.transform.pos.x, .y = self.transform.pos.y, .w = 2, .h = 2 };
        if (self.sprite != null and self.collider != null) {
            const spr_bounds = self.sprite.?.bounds(self.transform);
            const col_bounds = self.collider.?.bounds(self.transform.pos);
            return spr_bounds.unionRect(col_bounds);
        }
        if (self.sprite != null) return self.sprite.?.bounds(self.transform);
        return self.collider.?.bounds(self.transform.pos);
    }
};

pub const Transform = struct {
    pos: aya.math.Vec2 = .{},
    rot: f32 = 0,
    scale: aya.math.Vec2 = .{ .x = 1, .y = 1 },
};

pub const Sprite = struct {
    tex: aya.gfx.Texture = undefined,
    origin: aya.math.Vec2 = .{},

    pub fn bounds(self: Sprite, transform: Transform) math.Rect {
        // TODO: take rotation into account when calculating the bounds of the sprite texture
        const tl = transform.pos.subtract(self.origin);
        return .{ .x = tl.x * transform.scale.x, .y = tl.y * transform.scale.y, .w = self.tex.width * transform.scale.x, .h = self.tex.height * transform.scale.y };
    }
};

pub const Collider = union(enum) {
    box: BoxCollider,
    circle: CircleCollider,

    pub fn bounds(self: Collider, pos: math.Vec2) math.Rect {
        return switch (self) {
            .box => |box| box.bounds(pos),
            .circle => |circle| circle.bounds(pos),
        };
    }
};

pub const BoxCollider = struct {
    offset: aya.math.Vec2 = .{},
    w: f32,
    h: f32,

    pub fn init(w: f32, h: f32) BoxCollider {
        return .{ .w = w, .h = h };
    }

    pub fn bounds(self: @This(), pos: math.Vec2) math.Rect {
        const tl = pos.add(self.offset);
        return .{ .x = tl.x, .y = tl.y, .w = self.w, .h = self.h };
    }
};

pub const CircleCollider = struct {
    offset: aya.math.Vec2 = .{},
    r: f32,

    pub fn init(r: f32) CircleCollider {
        return .{ .r = r };
    }

    pub fn bounds(self: @This(), pos: math.Vec2) math.Rect {
        // tl will be the center position - the radius and then the w/h is double the radius
        const tl = pos.add(self.offset).subtract(.{ .x = self.r, .y = self.r });
        return .{ .x = tl.x, .y = tl.y, .w = self.r * 2, .h = self.r * 2 };
    }
};
