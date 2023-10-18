const std = @import("std");
const aya = @import("../aya.zig");
const glfw = @import("mach-glfw");

const Input = aya.Input;

pub const GamepadConnectionEvent = struct {
    gamepad: GamepadId,
    status: GamepadConnectionStatus,
};

const GamepadConnectionStatus = enum { connected, disconnected };

pub const GamepadId = glfw.Joystick.Id;

pub const GamepadButton = enum {
    /// The bottom action button of the action pad (i.e. PS: Cross, Xbox: A).
    south,
    /// The right action button of the action pad (i.e. PS: Circle, Xbox: B).
    east,
    /// The left action button of the action pad (i.e. PS: Square, Xbox: X).
    west,
    /// The upper action button of the action pad (i.e. PS: Triangle, Xbox: Y).
    north,

    left_bumper,
    right_bumper,
    back,
    start,
    guide,

    left_stick,
    right_stick,

    dpad_up,
    dpad_right,
    dpad_down,
    dpad_left,

    pub const max = GamepadButton.dpad_left;
};

pub const GamepadAxis = enum(u8) {
    left_x,
    left_y,
    right_x,
    right_y,
    left_trigger,
    right_trigger,
};

pub const Gamepad = struct {
    const ButtonBitSet = std.StaticBitSet(@as(usize, @intFromEnum(GamepadButton.max)) + 1);

    id: GamepadId,
    buttons: Input(GamepadButton) = .{},
    axes: [6]f32 = [_]f32{0} ** 6,

    pub fn update(self: *Gamepad) void {
        std.debug.print("clear pressed and released\n", .{});
        self.buttons.clear();

        const joystick = glfw.Joystick{ .jid = self.id };
        const state = joystick.getGamepadState() orelse {
            std.log.warn("getGamepadState returned null for live gamepad with id: {}\n", .{self.id});
            return;
        };

        inline for (std.meta.fields(GamepadButton)) |field| {
            switch (state.getButton(@enumFromInt(field.value))) {
                .press => {
                    // .press stays true as long as the button is down so ignore it if we already have it pressed
                    if (!self.buttons.pressed_set.isSet(field.value))
                        self.buttons.press(@enumFromInt(field.value));
                },
                .release => self.buttons.release(@enumFromInt(field.value)),
                else => {},
            }
        }

        self.axes = state.axes;
    }

    pub fn getAxis(self: *const Gamepad, axis: GamepadAxis) f32 {
        return self.axes[@as(u32, @intCast(@intFromEnum(axis)))];
    }

    pub fn getName(self: *const Gamepad) ?[]const u8 {
        const joystick = glfw.Joystick{ .jid = self.id };
        return joystick.getName();
    }

    pub fn getGUID(self: *const Gamepad) ?[:0]const u8 {
        const joystick = glfw.Joystick{ .jid = self.id };
        return joystick.getGUID();
    }
};

/// Resource. A collection of connected gamepads
pub const Gamepads = struct {
    pads: std.AutoHashMap(GamepadId, Gamepad),
    gamepads: [4]?Gamepad = [_]?Gamepad{null} ** 4,

    pub fn init() Gamepads {
        return .{ .pads = std.AutoHashMap(GamepadId, Gamepad).init(aya.allocator) };
    }

    pub fn deinit(self: *Gamepads) void {
        self.pads.deinit();
    }

    pub fn update(self: *Gamepads) void {
        // var iter = self.pads.valueIterator();
        // while (iter.next()) |gamepad| gamepad.update();

        for (&self.gamepads) |*maybe_gamepad| {
            if (maybe_gamepad.*) |*gamepad| gamepad.update();
        }
    }

    /// Registers the `gamepad`, marking it as connected.
    pub fn register(self: *Gamepads, id: GamepadId) void {
        self.pads.put(id, Gamepad{ .id = id }) catch unreachable;
        self.gamepads[@intCast(@intFromEnum(id))] = Gamepad{ .id = id };
    }

    /// Deregisters the `gamepad`, marking it as disconnected.
    pub fn deregister(self: *Gamepads, id: GamepadId) void {
        _ = self.pads.remove(id);
        self.gamepads[@intCast(@intFromEnum(id))] = null;
    }

    pub fn getGamepad(self: *const Gamepads, id: GamepadId) ?*const Gamepad {
        if (self.pads.contains(id)) return self.pads.getPtr(id);
        // if (self.gamepads[@intCast(@intFromEnum(id))]) |*gamepad| return gamepad;
        return null;
    }

    /// iterates all connected gamepads. Always fully use the iterator!
    pub fn nextGamepad(self: *const Gamepads) ?*const Gamepad {
        const I = struct {
            var iter: ?Iterator = null;
        };

        if (I.iter == null) I.iter = .{ .gamepads = self };

        if (I.iter) |*iter| {
            if (iter.next()) |next| return next;
            I.iter = null;
        }

        return null;
    }

    const Iterator = struct {
        gamepads: *const Gamepads,
        index: usize = 0,

        pub fn next(it: *Iterator) ?*const Gamepad {
            if (it.index == 4) return null;

            while (it.index < 4) : (it.index += 1) {
                const maybe_gamepad = it.gamepads.gamepads[it.index];
                if (maybe_gamepad) |*gamepad| {
                    it.index += 1;
                    return gamepad;
                }
            }

            return null;
        }
    };
};
