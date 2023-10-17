const std = @import("std");
const aya = @import("../aya.zig");
const glfw = @import("mach-glfw");

pub const GamepadConnectionEvent = struct {
    gamepad: GamepadId,
    status: GamepadConnectionStatus,
};

const GamepadConnectionStatus = enum { connected, disconnected };

pub const GamepadId = @import("mach-glfw").Joystick.Id;

pub const GamepadButton = struct {
    gamepad: GamepadId,
    type: GamepadButtonType,
};

pub const GamepadButtonType = enum(u8) {
    /// The bottom action button of the action pad (i.e. PS: Cross, Xbox: A).
    south,
    /// The right action button of the action pad (i.e. PS: Circle, Xbox: B).
    east,
    /// The upper action button of the action pad (i.e. PS: Triangle, Xbox: Y).
    north,
    /// The left action button of the action pad (i.e. PS: Square, Xbox: X).
    west,

    left_shoulder,
    right_shoulder,
    back,
    guide,
    start,

    left_stick,
    right_stick,

    d_pad_up,
    d_pad_down,
    d_pad_left,
    d_pad_right,

    touch_pad,
    /// Additional button (e.g. Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button)
    misc1,
};

pub const GamepadAxisType = enum(u8) {
    left_x,
    left_y,
    right_x,
    right_y,
    left_trigger,
    right_trigger,
};

pub const GamepadAxis = struct {
    gamepad: GamepadId,
    type: GamepadAxisType,
};

pub const GamepadType = enum(u8) {
    unknown,
    standard,
    xbox_360,
    xbox_one,
    ps3,
    ps4,
    ps5,
    nintendo_switch_pro,
    nintendo_switch_joycon_left,
    nintendo_switch_joycon_right,
    nintendo_switch_joycon_pair,
    _,
};

/// Resource. A collection of connected gamepads
pub const Gamepads = struct {
    pads: std.AutoHashMap(GamepadId, void),

    pub fn init() Gamepads {
        return .{ .pads = std.AutoHashMap(GamepadId, void).init(aya.allocator) };
    }

    pub fn deinit(self: *Gamepads) void {
        self.pads.deinit();
    }

    pub fn contains(self: Gamepads, id: GamepadId) bool {
        return self.pads.contains(id);
    }

    /// Registers the `gamepad`, marking it as connected.
    pub fn register(self: *Gamepads, id: GamepadId) void {
        const pad = glfw.Joystick{ .jid = id };
        if (pad.present()) {
            self.pads.put(id, {}) catch unreachable;
        }
    }

    /// Deregisters the `gamepad`, marking it as disconnected.
    pub fn deregister(self: *Gamepads, id: GamepadId) void {
        _ = self.pads.remove(id);
    }

    pub fn nextGamepad(self: *const Gamepads) ?GamepadId {
        const I = struct {
            var iter: ?std.AutoHashMap(GamepadId, void).Iterator = null;
        };

        if (I.iter == null) I.iter = self.pads.iterator();

        if (I.iter) |*iter| {
            if (iter.next()) |next| return next.key_ptr.*;
            I.iter = null;
        }

        return null;
    }

    fn MimicReturnType(comptime T: type) type {
        const ti = @typeInfo(T);
        if (ti == .Fn) {
            return ti.Fn.return_type.?;
        }
        @compileError("T is not a Fn: " ++ T);
    }

    pub fn getGamepadState(_: *const Gamepads, id: GamepadId) MimicReturnType(@TypeOf(glfw.Joystick.getGamepadState)) {
        const pad = glfw.Joystick{ .jid = id };
        return pad.getGamepadState();
    }

    pub fn getAxis(_: *const Gamepads, id: GamepadId) ?[]const f32 {
        const pad = glfw.Joystick{ .jid = id };
        return pad.getAxes();
    }

    // method on SDL_GamePad. should we make these on a struct that wraps GamepadId?
    pub fn getName(self: *const Gamepads, id: GamepadId) ?[]const u8 {
        _ = id;
        _ = self;
        // if (self.pads.get(id)) |gamepad| {
        //     if (sdl.SDL_GetGamepadName(gamepad)) |name| {
        //         return std.mem.span(name);
        //     }
        // }
        return null;
    }

    pub fn getType(self: *const Gamepads, id: GamepadId) GamepadType {
        _ = id;
        _ = self;
        // if (self.pads.get(id)) |gamepad| {
        //     return @enumFromInt(sdl.SDL_GetGamepadType(gamepad));
        // }
        return .unknown;
    }

    /// get the type of an opened gamepad, ignoring any mapping override
    pub fn getRealType(self: *const Gamepads, id: GamepadId) GamepadType {
        _ = id;
        _ = self;
        // if (self.pads.get(id)) |gamepad| {
        //     return @enumFromInt(sdl.SDL_GetRealGamepadType(gamepad));
        // }
        return .unknown;
    }

    pub fn hasRumble(self: *const Gamepads, id: GamepadId) bool {
        _ = id;
        _ = self;
        // if (self.pads.get(id)) |gamepad| {
        //     return sdl.SDL_GamepadHasRumble(gamepad) == sdl.SDL_TRUE;
        // }
        return false;
    }

    pub fn hasRumbleTriggers(self: *const Gamepads, id: GamepadId) bool {
        _ = id;
        _ = self;
        // if (self.pads.get(id)) |gamepad| {
        //     return sdl.SDL_GamepadHasRumbleTriggers(gamepad) == sdl.SDL_TRUE;
        // }
        return false;
    }

    /// Each rumble request overrides the last. To stop rumble send an event with duration_ms = 0.
    /// low_freq_rumble: the intensity of the low frequency (left) rumble motor
    /// high_freq_rumble: the intensity of the high frequency (right) rumble motor
    pub fn rumble(self: *const Gamepads, id: GamepadId, low_freq_rumble: f32, high_freq_rumble: f32, duration_ms: u32) void {
        _ = duration_ms;
        _ = high_freq_rumble;
        _ = low_freq_rumble;
        _ = id;
        _ = self;
        // if (self.pads.get(id)) |gamepad| {
        //     _ = sdl.SDL_RumbleGamepad(
        //         gamepad,
        //         @intFromFloat(low_freq_rumble * std.math.maxInt(u16)),
        //         @intFromFloat(high_freq_rumble * std.math.maxInt(u16)),
        //         duration_ms,
        //     );
        // }
    }
};
