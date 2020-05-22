const std = @import("std");

pub const pi = std.math.pi;
pub const pi_over_2 = std.math.pi / 2.0;

pub const Vec2 = @import("vec2.zig").Vec2;
pub const Vec4 = @import("vec4.zig").Vec4;
pub const Rect = @import("rect.zig").Rect;
pub const RectI = @import("rect.zig").RectI;
pub const Mat32 = @import("mat32.zig").Mat32;
pub const Color = @import("color.zig").Color;
pub const Quad = @import("quad.zig").Quad;

pub const rand = @import("rand.zig");

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
