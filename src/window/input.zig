const std = @import("std");
const aya = @import("../aya.zig");
const core = @import("mach-core");

/// A pressable input of type `T`. When adding this resource for a new input type, you should:
/// * Call the `press` method for each press event.
/// * Call the `release` method for each release event.
/// * Call the `clear` method at each frame start, before processing events.
pub fn Input(comptime T: type) type {
    if (T == aya.GamepadButton) return struct {
        const Self = @This();

        pressed_set: std.AutoHashMap(T, void),
        just_pressed_set: std.AutoHashMap(T, void),
        just_released_set: std.AutoHashMap(T, void),

        pub fn init() Self {
            return .{
                .pressed_set = std.AutoHashMap(T, void).init(aya.allocator),
                .just_pressed_set = std.AutoHashMap(T, void).init(aya.allocator),
                .just_released_set = std.AutoHashMap(T, void).init(aya.allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.pressed_set.deinit();
            self.just_pressed_set.deinit();
            self.just_released_set.deinit();
        }

        pub fn initWithCapacity(capacity: u32) Self {
            var self = init();
            self.pressed_set.ensureTotalCapacity(capacity) catch unreachable;
            self.just_pressed_set.ensureTotalCapacity(capacity) catch unreachable;
            self.just_released_set.ensureTotalCapacity(capacity) catch unreachable;
            return self;
        }

        pub fn press(self: *Self, input: T) void {
            if (self.pressed_set.contains(input)) return;
            self.pressed_set.put(input, {}) catch unreachable;
            self.just_pressed_set.put(input, {}) catch unreachable;
        }

        pub fn pressed(self: Self, input: T) bool {
            return self.pressed_set.contains(input);
        }

        pub fn anyPressed(self: Self, input: []const T) bool {
            for (input) |i| {
                if (self.pressed_set.contains(i)) return true;
            }
            return false;
        }

        pub fn release(self: *Self, input: T) void {
            if (self.pressed_set.remove(input))
                self.just_released_set.put(input, {}) catch unreachable;
        }

        pub fn releaseAll(self: *Self) void {
            var iter = self.pressed_set.keyIterator();
            while (iter.next()) |input| {
                self.just_released_set.put(input, {}) catch unreachable;
            }
            self.pressed_set.clearRetainingCapacity();
        }

        pub fn justPressed(self: Self, input: T) bool {
            return self.just_pressed_set.contains(input);
        }

        pub fn anyJustPressed(self: Self, input: []const T) bool {
            for (input) |i| {
                if (self.just_pressed_set.contains(i)) return true;
            }
            return false;
        }

        pub fn clearJustPressed(self: Self) void {
            self.just_pressed_set.clearRetainingCapacity();
        }

        pub fn justReleased(self: Self, input: T) bool {
            return self.just_released_set.contains(input);
        }

        pub fn anyJustReleased(self: Self, input: []const T) bool {
            for (input) |i| {
                if (self.just_released_set.contains(i)) return true;
            }
            return false;
        }

        pub fn clearJustReleased(self: *Self) void {
            self.just_released_set.clearRetainingCapacity();
        }

        pub fn reset(self: *Self, input: T) void {
            _ = self.pressed_set.remove(input);
            _ = self.just_pressed_set.remove(input);
            _ = self.just_released_set.remove(input);
        }

        pub fn resetAll(self: *Self) void {
            self.pressed_set.clearRetainingCapacity();
            self.just_pressed_set.clearRetainingCapacity();
            self.just_released_set.clearRetainingCapacity();
        }

        /// clears the just_pressed and just_released sets
        pub fn clear(self: *Self) void {
            self.just_pressed_set.clearRetainingCapacity();
            self.just_released_set.clearRetainingCapacity();
        }

        pub fn getNextPressed(self: *const Self) ?T {
            const I = struct {
                var iter: ?std.AutoHashMap(T, void).KeyIterator = null;
            };

            if (I.iter == null) I.iter = self.pressed_set.keyIterator();

            if (I.iter) |*iter| {
                if (iter.next()) |next| return next.*;
                I.iter = null;
            }

            return null;
        }

        pub fn getNextJustPressed(self: *const Self) ?T {
            const I = struct {
                var iter: ?std.AutoHashMap(T, void).KeyIterator = null;
            };

            if (I.iter == null) I.iter = self.just_pressed_set.keyIterator();

            if (I.iter) |*iter| {
                if (iter.next()) |next| return next.*;
                I.iter = null;
            }

            return null;
        }

        pub fn getNextJustReleased(self: *const Self) ?T {
            const I = struct {
                var iter: ?std.AutoHashMap(T, void).KeyIterator = null;
            };

            if (I.iter == null) I.iter = self.just_released_set.keyIterator();

            if (I.iter) |*iter| {
                if (iter.next()) |next| return next.*;
                I.iter = null;
            }

            return null;
        }
    };

    return struct {
        const Self = @This();

        const InputBitSet = std.StaticBitSet(@as(usize, @intFromEnum(T.max)) + 1);
        pressed_set: InputBitSet,
        just_pressed_set: InputBitSet,
        just_released_set: InputBitSet,

        pub fn init() Self {
            return .{
                .pressed_set = InputBitSet.initEmpty(),
                .just_pressed_set = InputBitSet.initEmpty(),
                .just_released_set = InputBitSet.initEmpty(),
            };
        }

        pub fn deinit(_: *Self) void {}

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

        pub fn reset(self: *Self, input: T) void {
            self.pressed_set.unset(@intFromEnum(input));
            self.just_pressed_set.unset(@intFromEnum(input));
            self.just_released_set.unset(@intFromEnum(input));
        }

        pub fn resetAll(self: *Self) void {
            self.pressed_set = InputBitSet.initEmpty();
            self.just_pressed_set = InputBitSet.initEmpty();
            self.just_released_set = InputBitSet.initEmpty();
        }

        /// clears the just_pressed and just_released sets
        pub fn clear(self: *Self) void {
            self.just_pressed_set = InputBitSet.initEmpty();
            self.just_released_set = InputBitSet.initEmpty();
        }

        pub fn getNextPressed(self: *const Self) ?T {
            const I = struct {
                var iter: ?InputBitSet.Iterator = null;
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
                var iter: ?InputBitSet.Iterator = null;
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
    var state = Input(u8).init();
    try std.testing.expect(!state.justPressed(4));
    try std.testing.expect(!state.pressed(4));
    state.press(4);
    try std.testing.expect(state.justPressed(4));
    try std.testing.expect(state.pressed(4));
    state.release(4);
    try std.testing.expect(!state.pressed(4));
    try std.testing.expect(state.justReleased(4));

    state.press(5);
    state.press(6);
    while (state.getNextPressed()) |p| {
        try std.testing.expect(p == 5 or p == 6);
    }

    try std.testing.expect(!state.anyPressed(&.{ 1, 2, 3 }));
    try std.testing.expect(state.anyPressed(&.{ 6, 7, 8 }));
}
