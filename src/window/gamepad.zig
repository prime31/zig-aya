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
    gamepads: [4]?Gamepad = [_]?Gamepad{null} ** 4,

    pub fn update(self: *Gamepads) void {
        for (&self.gamepads) |*maybe_gamepad| {
            if (maybe_gamepad.*) |*gamepad| gamepad.update();
        }
    }

    /// Registers the `gamepad`, marking it as connected.
    pub fn register(self: *Gamepads, id: GamepadId) void {
        self.gamepads[@intCast(@intFromEnum(id))] = Gamepad{ .id = id };
    }

    /// Deregisters the `gamepad`, marking it as disconnected.
    pub fn deregister(self: *Gamepads, id: GamepadId) void {
        self.gamepads[@intCast(@intFromEnum(id))] = null;
    }

    pub fn getGamepad(self: *const Gamepads, id: GamepadId) ?*const Gamepad {
        if (self.gamepads[@intCast(@intFromEnum(id))]) |*gamepad| return gamepad;
        return null;
    }

    /// iterates all connected gamepads. Always fully use the iterator!
    pub fn nextGamepad(self: *const Gamepads) ?*const Gamepad {
        const I = struct {
            var index: ?usize = 0;
        };

        if (I.index == null) I.index = 0;

        while (I.index.? < 4) : (I.index.? += 1) {
            if (self.gamepads[I.index.?]) |*gamepad| {
                I.index.? += 1;
                return gamepad;
            }
        }

        I.index = null;

        return null;
    }
};
