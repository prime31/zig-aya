const std = @import("std");

pub const Vec2 = @import("vec2.zig").Vec2;
pub const Rect = @import("rect.zig").Rect;
pub const RectI = @import("rect.zig").RectI;
pub const Mat32 = @import("mat32.zig").Mat32;
pub const Color = @import("color.zig").Color;
pub const Quad = @import("quad.zig").Quad;

pub const rand = struct {
    var rng = std.rand.DefaultPrng.init(0x12345678);

    pub fn seed(init_s: u64) void {
        rng = std.rand.DefaultPrng.init(init_s);
    }

    pub fn boolean() bool {
        return rng.random.boolean();
    }

    /// Returns a random int `i` such that `0 <= i <= maxInt(T)`
    pub fn int(comptime T: type) T {
        return rng.random.int(T);
    }

    /// Return a floating point value evenly distributed in the range [0, 1).
    pub fn float(comptime T: type) T {
        return rng.random.float(T);
    }

    pub fn color() Color {
        return Color{ .value = rng.random.int(u32) };
    }

    /// Returns an evenly distributed random integer `at_least <= i < less_than`.
    pub fn range(comptime T: type, at_least: T, less_than: T) T {
        if (@typeInfo(T) == .Int) {
            return rng.random.intRangeLessThanBiased(T, at_least, less_than);
        } else if (@typeInfo(T) == .Float) {
            return at_least + rng.random.float(T) * (less_than - at_least);
        }
        unreachable;
    }

    /// Returns an evenly distributed random unsigned integer `0 <= i < less_than`.
    pub fn uintLessThan(comptime T: type, less_than: T) T {
        return rng.random.uintLessThanBiased(T, less_than);
    }

    /// returns true if the next random is less than percent. Percent should be between 0 and 1
    pub fn chance(percent: f32) bool {
        return rng.random.float(f32) < percent;
    }

    pub fn choose(comptime T: type, first: T, second: T) T {
        if (rng.random.int(u1) == 0) return first;
        return second;
    }

    pub fn choose3(comptime T: type, first: T, second: T, third: T) T {
        return switch (rng.random.int(u2)) {
            0 => first,
            1 => second,
            2 => third,
        };
    }
};

test "test math.rand" {
    rand.seed(0);

    std.testing.expect(rand.int(i32) >= 0);

    std.testing.expect(rand.range(i32, 5, 10) >= 5);
    std.testing.expect(rand.range(i32, 5, 10) < 10);

    std.testing.expect(rand.range(u32, 5, 10) >= 5);
    std.testing.expect(rand.range(u32, 5, 10) < 10);

    std.testing.expect(rand.range(f32, 5.0, 10.0) >= 5);
    std.testing.expect(rand.range(f32, 5.0, 10.0) < 10);

    std.testing.expect(rand.uintLessThan(u32, 5) < 5);
}
