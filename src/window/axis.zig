const std = @import("std");
const aya = @import("../aya.zig");
const sdl = @import("sdl");

pub fn Axis(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const min: f32 = -1;
        pub const max: f32 = 1;

        /// The position data of the input devices
        axis_data: std.AutoHashMap(T, f32),

        pub fn init() Self {
            return .{ .axis_data = std.AutoHashMap(T, f32).init(aya.allocator) };
        }

        pub fn deinit(self: *Self) void {
            self.axis_data.deinit();
        }

        pub fn set(self: *Self, input: T, data: f32) void {
            self.axis_data.put(input, data) catch unreachable;
        }

        /// Returns the position data clamped between min and max
        pub fn get(self: *const Self, input: T) ?f32 {
            if (self.axis_data.get(input)) |value| return std.math.clamp(value, min, max);
            return null;
        }

        pub fn getUnclamped(self: *const Self, input: T) ?f32 {
            if (self.axis_data.get(input)) |value| return value;
            return null;
        }

        pub fn remove(self: *Self, input: T) void {
            _ = self.axis_data.remove(input);
        }
    };
}

test "Axis" {}
