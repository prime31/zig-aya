const std = @import("std");
const math = std.math;

pub const Vec2 = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub fn init(x: f32, y: f32) Vec2 {
        return .{ .x = x, .y = y };
    }

    pub fn orthogonal(self: @This()) Vec2 {
        return .{ .x = -self.y, .y = self.x };
    }

    pub fn angleBetween(self: @This(), to: Vec2) f32 {
        return math.atan2(f32, to.y - self.y, to.x - self.x);
    }

    pub fn distanceSq(self: @This(), v: Vec2) f32 {
        const v1 = self.x - v.x;
        const v2 = self.y - v.y;
        return v1 * v1 + v2 * v2;
    }

    pub fn distance(self: @This(), v: Vec2) f32 {
        return math.sqrt(self.distanceSq(v));
    }

    pub fn perpindicular(self: @This(), v: Vec2) Vec2 {
        return .{ .x = -1 * (v.y - self.y), .y = v.x - self.x };
    }
};

test "vec2 tests" {
    const v = Vec2{ .x = 1, .y = 5 };
    const v2 = v.orthogonal();
    const v_orth = Vec2{ .x = -5, .y = 1 };

    std.testing.expectEqual(v2, v_orth);

    std.debug.warn("\nangleBetween: {}\n", .{v.angleBetween(v2)});
    std.debug.warn("\ndistanceSq: {}\n", .{v.distanceSq(v2)});
    std.debug.warn("\ndistance: {}\n", .{v.distance(v2)});
    std.debug.warn("\nperpindicular: {}\n", .{v.perpindicular(v2)});
}
