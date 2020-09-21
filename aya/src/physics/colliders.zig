const math = @import("../math/math.zig");
const CollisionFilter = @import("collision_filter.zig").CollisionFilter;

pub const Collider = struct {
    filter: CollisionFilter,
    trigger: bool = false,
    kind: ColliderKind,

    pub fn init(kind: ColliderKind) Collider {
        return .{
            .filter = CollisionFilter.init(),
            .kind = kind,
        };
    }

    pub fn bounds(self: Collider) math.Rect {
        return .{};
    }
};

pub const ColliderKind = union(enum) {
    box: BoxCollider,
    circle: CircleCollider,
    polygon: PolygonCollider,
};

pub const BoxCollider = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub fn init(x: f32, y: f32, w: f32, h: f32) BoxCollider {
        return .{ .x = x, .y = y, .w = w, .h = h };
    }
};

pub const CircleCollider = struct {
    x: f32,
    y: f32,
    r: f32,
};

pub const PolygonCollider = struct {
    x: f32,
    y: f32,
    verts: []math.Vec2,
};
