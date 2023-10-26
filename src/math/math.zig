const std = @import("std");

pub const pi = std.math.pi;
pub const pi_over_2 = std.math.pi / 2.0;

pub const rand = @import("rand.zig");

/// Converts degrees to radian
pub fn toRadians(deg: anytype) @TypeOf(deg) {
    return pi * deg / 180.0;
}

/// Converts radian to degree
pub fn toDegrees(rad: anytype) @TypeOf(rad) {
    return 180.0 * rad / pi;
}

pub fn isEven(val: anytype) bool {
    std.debug.assert(@typeInfo(@TypeOf(val)) == .Int or @typeInfo(@TypeOf(val)) == .ComptimeInt);
    return @mod(val, 2) == 0;
}

pub fn ifloor(comptime T: type, val: f32) T {
    return @as(T, @intFromFloat(@floor(val)));
}

pub fn iclamp(x: i32, a: i32, b: i32) i32 {
    return @max(a, @min(b, x));
}

// returns true if val is between start and end
pub fn between(val: anytype, start: anytype, end: anytype) bool {
    return start <= val and val <= end;
}

pub fn repeat(t: f32, len: f32) f32 {
    return t - std.math.floor(t / len) * len;
}

pub fn pingpong(t: f32, len: f32) f32 {
    const tt = repeat(t, len * 2);
    return len - @abs(tt - len);
}

test "test math.rand" {
    rand.seed(0);

    try std.testing.expect(rand.int(i32) >= 0);

    try std.testing.expect(rand.range(i32, 5, 10) >= 5);
    try std.testing.expect(rand.range(i32, 5, 10) < 10);

    try std.testing.expect(rand.range(u32, 5, 10) >= 5);
    try std.testing.expect(rand.range(u32, 5, 10) < 10);

    try std.testing.expect(rand.range(f32, 5.0, 10.0) >= 5);
    try std.testing.expect(rand.range(f32, 5.0, 10.0) < 10);

    try std.testing.expect(rand.uintLessThan(u32, 5) < 5);

    try std.testing.expect(isEven(666));
}
