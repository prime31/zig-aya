const std = @import("std");
const aya = @import("../aya.zig");

const MouseButton = @import("mouse.zig").MouseButton;
const Scancode = @import("scancode.zig").Scancode;
const GamepadButton = @import("gamepad.zig").GamepadButton;

pub const MouseButtons = PressableInput(MouseButton);
pub const Keys = PressableInput(Scancode);
pub const GamepadButtons = PressableInput(GamepadButton);

/// A pressable input of type `T`. When adding this resource for a new input type, you should:
/// * Call the `clear` method at each frame start, before processing events.
/// * Call the `press` method for each press event.
/// * Call the `release` method for each release event.
fn PressableInput(comptime T: type) type {
    return struct {
        const Self = @This();
        const InputBitSet = std.StaticBitSet(@as(usize, @intFromEnum(T.max)) + 1);

        pressed_set: InputBitSet = InputBitSet.initEmpty(),
        just_pressed_set: InputBitSet = InputBitSet.initEmpty(),
        just_released_set: InputBitSet = InputBitSet.initEmpty(),

        pub fn press(self: *Self, input: T) void {
            if (self.just_pressed_set.isSet(@intFromEnum(input))) return;
            self.pressed_set.set(@intFromEnum(input));
            self.just_pressed_set.set(@intFromEnum(input));
        }

        pub fn pressed(self: Self, input: T) bool {
            return self.pressed_set.isSet(@intFromEnum(input));
        }

        pub fn anyPressed(self: Self, input: []const T) bool {
            for (input) |i| {
                if (self.pressed(i)) return true;
            }
            return false;
        }

        pub fn release(self: *Self, input: T) void {
            if (self.pressed_set.isSet(@intFromEnum(input))) {
                self.pressed_set.unset(@intFromEnum(input));
                self.just_released_set.set(@intFromEnum(input));
            }
        }

        pub fn releaseAll(self: *Self) void {
            var iter = self.pressed_set.iterator(.{});
            while (iter.next()) |input| {
                self.just_released_set.set(@intFromEnum(input));
            }
            self.just_released_set.mask = 0;
        }

        pub fn justPressed(self: Self, input: T) bool {
            return self.just_pressed_set.isSet(@intFromEnum(input));
        }

        pub fn anyJustPressed(self: Self, input: []const T) bool {
            for (input) |i| {
                if (self.justPressed(i)) return true;
            }
            return false;
        }

        pub fn clearJustPressed(self: Self) void {
            self.just_pressed_set.mask = 0;
        }

        pub fn justReleased(self: Self, input: T) bool {
            return self.just_released_set.isSet(@intFromEnum(input));
        }

        pub fn anyJustReleased(self: Self, input: []const T) bool {
            for (input) |i| {
                if (self.justReleased(i)) return true;
            }
            return false;
        }

        pub fn clearJustReleased(self: *Self) void {
            self.just_released_set.mask = 0;
        }

        /// resets the state of `input` in all sets
        pub fn reset(self: *Self, input: T) void {
            self.pressed_set.unset(@intFromEnum(input));
            self.just_pressed_set.unset(@intFromEnum(input));
            self.just_released_set.unset(@intFromEnum(input));
        }

        /// resets all sets to the empty state
        pub fn resetAll(self: *Self) void {
            self.pressed_set = InputBitSet.initEmpty();
            self.just_pressed_set = InputBitSet.initEmpty();
            self.just_released_set = InputBitSet.initEmpty();
        }

        /// clears the just_pressed and just_released sets. Should be called at the beginning of the frame
        /// before adding new events.
        pub fn clear(self: *Self) void {
            self.just_pressed_set = InputBitSet.initEmpty();
            self.just_released_set = InputBitSet.initEmpty();
        }

        pub fn getNextPressed(self: *const Self) ?T {
            const I = struct {
                var iter: ?InputBitSet.Iterator(.{}) = null;
            };

            if (I.iter == null) I.iter = self.pressed_set.iterator(.{});

            if (I.iter) |*iter| {
                if (iter.next()) |next| return @enumFromInt(next);
                I.iter = null;
            }

            return null;
        }

        pub fn getNextJustPressed(self: *const Self) ?T {
            const I = struct {
                var iter: ?InputBitSet.Iterator(.{}) = null;
            };

            if (I.iter == null) I.iter = self.just_pressed_set.iterator(.{});

            if (I.iter) |*iter| {
                if (iter.next()) |next| return @enumFromInt(next);
                I.iter = null;
            }

            return null;
        }

        pub fn getNextJustReleased(self: *const Self) ?T {
            const I = struct {
                var iter: ?InputBitSet.Iterator(.{}) = null;
            };

            if (I.iter == null) I.iter = self.just_released_set.iterator(.{});

            if (I.iter) |*iter| {
                if (iter.next()) |next| return @enumFromInt(next);
                I.iter = null;
            }

            return null;
        }
    };
}

test "Input(T)" {
    const TestEnum = enum(u8) {
        first,
        second,
        third,
        fourth,
        fifth,
        sixth,

        pub const max = @This().sixth;
    };

    var state = PressableInput(TestEnum){};
    try std.testing.expect(!state.justPressed(.first));
    try std.testing.expect(!state.pressed(.first));
    state.press(.first);
    try std.testing.expect(state.justPressed(.first));
    try std.testing.expect(state.pressed(.first));
    state.release(.first);
    try std.testing.expect(!state.pressed(.first));
    try std.testing.expect(state.justReleased(.first));

    state.press(.second);
    state.press(.third);
    while (state.getNextPressed()) |p| {
        try std.testing.expect(p == .second or p == .third);
    }

    try std.testing.expect(state.anyPressed(&.{ .first, .second, .third }));
    try std.testing.expect(!state.anyPressed(&.{ .fourth, .fifth }));
}
