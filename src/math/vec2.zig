const std = @import("std");
const math = std.math;

pub const Vec2 = extern struct {
    x: f32 = 0,
    y: f32 = 0,

    pub fn init(x: f32, y: f32) Vec2 {
        return .{ .x = x, .y = y };
    }

    fn getField(vec: Vec2, comptime index: comptime_int) f32 {
        switch (index) {
            0 => return vec.x,
            1 => return vec.y,
            else => @compileError("index out of bounds!"),
        }
    }

    pub fn angleToVec(radians: f32, len: f32) Vec2 {
        return .{ .x = math.cos(radians) * len, .y = math.sin(radians) * len };
    }

    pub fn orthogonal(self: Vec2) Vec2 {
        return .{ .x = -self.y, .y = self.x };
    }

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn subtract(self: Vec2, other: Vec2) Vec2 {
        return .{ .x = self.x - other.x, .y = self.y - other.y };
    }

    pub fn mul(self: Vec2, other: Vec2) Vec2 {
        return .{ .x = self.x * other.x, .y = self.y * other.y };
    }

    pub fn scaleInPlace(self: *Vec2, s: f32) void {
        self.x *= s;
        self.y *= s;
    }

    pub fn scale(self: Vec2, s: f32) Vec2 {
        return .{ .x = self.x * s, .y = self.y * s };
    }

    pub fn dot(a: Vec2, b: Vec2) f32 {
        var result: f32 = 0;
        inline for (@typeInfo(Vec2).Struct.fields) |fld| {
            result += @field(a, fld.name) * @field(b, fld.name);
        }
        return result;
    }

    pub fn lengthSq(a: Vec2) f32 {
        return Vec2.dot(a, a);
    }

    pub fn length(a: Vec2) f32 {
        return std.math.sqrt(a.lengthSq());
    }

    pub fn normalize(vec: Vec2) Vec2 {
        return vec.scale(1.0 / vec.length());
    }

    pub fn clamp(self: Vec2, min: Vec2, max: Vec2) Vec2 {
        return .{ .x = math.clamp(self.x, min.x, max.x), .y = math.clamp(self.y, min.y, max.y) };
    }

    /// snaps the Vec2 parts to the nearest snap value. ex: 53 snapTo 5 would be 55.
    pub fn snapTo(self: Vec2, snap: f32) Vec2 {
        if (snap <= 0) return self;
        return .{ .x = @round(self.x / snap) * snap, .y = @round(self.y / snap) * snap };
    }

    pub fn angleBetween(self: Vec2, to: Vec2) f32 {
        return math.atan2(f32, to.y - self.y, to.x - self.x);
    }

    pub fn distanceSq(self: Vec2, v: Vec2) f32 {
        const v1 = self.x - v.x;
        const v2 = self.y - v.y;
        return v1 * v1 + v2 * v2;
    }

    pub fn distance(self: Vec2, v: Vec2) f32 {
        return math.sqrt(self.distanceSq(v));
    }

    pub fn perpindicular(self: Vec2, v: Vec2) Vec2 {
        return .{ .x = -1 * (v.y - self.y), .y = v.x - self.x };
    }
};

test "vec2 tests" {
    const v = Vec2{ .x = 1, .y = 5 };
    const v2 = v.orthogonal();
    const v_orth = Vec2{ .x = -5, .y = 1 };

    std.testing.expectEqual(v2, v_orth);
    std.testing.expect(math.approxEq(f32, -2.55, v.angleBetween(v2), 0.01));
    std.testing.expect(math.approxEq(f32, 52, v.distanceSq(v2), 0.01));
    std.testing.expect(math.approxEq(f32, 7.21, v.distance(v2), 0.01));
    std.testing.expect(math.approxEq(f32, -6, v.perpindicular(v2).y, 0.01));
}
