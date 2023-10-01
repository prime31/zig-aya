const std = @import("std");
const aya = @import("../aya.zig");
const sdl = @import("sdl");

pub const GamepadConnectionEvent = struct {
    gamepad: GamepadId,
    status: GamepadConnectionStatus,
};

const GamepadConnectionStatus = enum { connected, disconnected };

pub const GamepadId = u32;

pub const GamepadButton = struct {
    gamepad: GamepadId,
    type: GamepadButtonType,
};

pub const GamepadButtonType = enum(u8) {
    /// The bottom action button of the action pad (i.e. PS: Cross, Xbox: A).
    south = sdl.SDL_GAMEPAD_BUTTON_A,
    /// The right action button of the action pad (i.e. PS: Circle, Xbox: B).
    east = sdl.SDL_GAMEPAD_BUTTON_B,
    /// The upper action button of the action pad (i.e. PS: Triangle, Xbox: Y).
    north = sdl.SDL_GAMEPAD_BUTTON_Y,
    /// The left action button of the action pad (i.e. PS: Square, Xbox: X).
    west = sdl.SDL_GAMEPAD_BUTTON_X,

    left_shoulder = sdl.SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
    right_shoulder = sdl.SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
    back = sdl.SDL_GAMEPAD_BUTTON_BACK,
    guide = sdl.SDL_GAMEPAD_BUTTON_GUIDE,
    start = sdl.SDL_GAMEPAD_BUTTON_START,

    left_stick = sdl.SDL_GAMEPAD_BUTTON_LEFT_STICK,
    right_stick = sdl.SDL_GAMEPAD_BUTTON_RIGHT_STICK,

    d_pad_up = sdl.SDL_GAMEPAD_BUTTON_DPAD_UP,
    d_pad_down = sdl.SDL_GAMEPAD_BUTTON_DPAD_DOWN,
    d_pad_left = sdl.SDL_GAMEPAD_BUTTON_DPAD_LEFT,
    d_pad_right = sdl.SDL_GAMEPAD_BUTTON_DPAD_RIGHT,

    touch_pad = sdl.SDL_GAMEPAD_BUTTON_TOUCHPAD,
    /// Additional button (e.g. Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button)
    misc1 = sdl.SDL_GAMEPAD_BUTTON_MISC1,
};

pub const GamepadAxisType = enum(u8) {
    left_x = sdl.SDL_GAMEPAD_AXIS_LEFTX,
    left_y = sdl.SDL_GAMEPAD_AXIS_LEFTY,
    right_x = sdl.SDL_GAMEPAD_AXIS_RIGHTX,
    right_y = sdl.SDL_GAMEPAD_AXIS_RIGHTY,
    left_trigger = sdl.SDL_GAMEPAD_AXIS_LEFT_TRIGGER,
    right_trigger = sdl.SDL_GAMEPAD_AXIS_RIGHT_TRIGGER,
};

pub const GamepadAxis = struct {
    gamepad: GamepadId,
    type: GamepadAxisType,
};

pub const GamepadType = enum(u8) {
    unknown = sdl.SDL_GAMEPAD_TYPE_UNKNOWN,
    standard = sdl.SDL_GAMEPAD_TYPE_STANDARD,
    xbox_360 = sdl.SDL_GAMEPAD_TYPE_XBOX360,
    xbox_one = sdl.SDL_GAMEPAD_TYPE_XBOXONE,
    ps3 = sdl.SDL_GAMEPAD_TYPE_PS3,
    ps4 = sdl.SDL_GAMEPAD_TYPE_PS4,
    ps5 = sdl.SDL_GAMEPAD_TYPE_PS5,
    nintendo_switch_pro = sdl.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO,
    nintendo_switch_joycon_left = sdl.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT,
    nintendo_switch_joycon_right = sdl.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT,
    nintendo_switch_joycon_pair = sdl.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR,
    _,
};

/// Resource. A collection of connected gamepads
pub const Gamepads = struct {
    pads: std.AutoHashMap(GamepadId, *sdl.SDL_Gamepad),

    pub fn init() Gamepads {
        return .{ .pads = std.AutoHashMap(GamepadId, *sdl.SDL_Gamepad).init(aya.allocator) };
    }

    pub fn deinit(self: *Gamepads) void {
        self.pads.deinit();
    }

    pub fn contains(self: Gamepads, id: GamepadId) bool {
        return self.pads.contains(id);
    }

    /// Registers the `gamepad`, marking it as connected.
    pub fn register(self: *Gamepads, id: GamepadId) void {
        if (sdl.SDL_OpenGamepad(id)) |pad| {
            self.pads.put(id, pad) catch unreachable;
        }
    }

    /// Deregisters the `gamepad`, marking it as disconnected.
    pub fn deregister(self: *Gamepads, id: GamepadId) void {
        _ = self.pads.remove(id);
    }

    pub fn nextGamepad(self: *const Gamepads) ?GamepadId {
        const I = struct {
            var iter: ?std.AutoHashMap(GamepadId, *sdl.SDL_Gamepad).Iterator = null;
        };

        if (I.iter == null) I.iter = self.pads.iterator();

        if (I.iter) |*iter| {
            if (iter.next()) |next| return next.key_ptr.*;
            I.iter = null;
        }

        return null;
    }

    // method on SDL_GamePad. should we make these on a struct that wraps GamepadId?
    pub fn getName(self: *const Gamepads, id: GamepadId) ?[]const u8 {
        if (self.pads.get(id)) |gamepad| {
            if (sdl.SDL_GetGamepadName(gamepad)) |name| {
                return std.mem.span(name);
            }
        }
        return null;
    }

    pub fn getType(self: *const Gamepads, id: GamepadId) GamepadType {
        if (self.pads.get(id)) |gamepad| {
            return @enumFromInt(sdl.SDL_GetGamepadType(gamepad));
        }
        return .unknown;
    }

    /// get the type of an opened gamepad, ignoring any mapping override
    pub fn getRealType(self: *const Gamepads, id: GamepadId) GamepadType {
        if (self.pads.get(id)) |gamepad| {
            return @enumFromInt(sdl.SDL_GetRealGamepadType(gamepad));
        }
        return .unknown;
    }

    pub fn hasRumble(self: *const Gamepads, id: GamepadId) bool {
        if (self.pads.get(id)) |gamepad| {
            return sdl.SDL_GamepadHasRumble(gamepad) == sdl.SDL_TRUE;
        }
        return false;
    }

    pub fn hasRumbleTriggers(self: *const Gamepads, id: GamepadId) bool {
        if (self.pads.get(id)) |gamepad| {
            return sdl.SDL_GamepadHasRumbleTriggers(gamepad) == sdl.SDL_TRUE;
        }
        return false;
    }

    /// Each rumble request overrides the last. To stop rumble send an event with duration_ms = 0.
    /// low_freq_rumble: the intensity of the low frequency (left) rumble motor
    /// high_freq_rumble: the intensity of the high frequency (right) rumble motor
    pub fn rumble(self: *const Gamepads, id: GamepadId, low_freq_rumble: f32, high_freq_rumble: f32, duration_ms: u32) void {
        if (self.pads.get(id)) |gamepad| {
            _ = sdl.SDL_RumbleGamepad(
                gamepad,
                @intFromFloat(low_freq_rumble * std.math.maxInt(u16)),
                @intFromFloat(high_freq_rumble * std.math.maxInt(u16)),
                duration_ms,
            );
        }
    }
};
