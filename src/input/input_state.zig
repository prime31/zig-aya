const std = @import("std");
const aya = @import("../aya.zig");

const MouseButtons = @import("pressable_input.zig").MouseButtons;
const Keys = @import("pressable_input.zig").Keys;
const Gamepads = @import("gamepad.zig").Gamepads;

const MouseButton = @import("mouse.zig").MouseButton;
const Scancode = @import("scancode.zig").Scancode;

pub const InputState = struct {
    const Mouse = struct {
        buttons: MouseButtons = .{},
        wheel_x: f32 = 0,
        wheel_y: f32 = 0,
        pos: aya.math.Vec2 = .{},
    };

    keys: Keys = .{},
    mouse: Mouse = .{},
    gamepads: Gamepads,

    pub fn init() InputState {
        return .{
            .gamepads = Gamepads.init(),
        };
    }

    pub fn deinit(self: *InputState) void {
        self.gamepads.deinit();
    }

    pub fn newFrame(self: *InputState) void {
        self.mouse.buttons.clear();
        self.keys.clear();
        self.gamepads.update();
    }

    // mouse
    pub fn mouseJustPressed(self: *const InputState, btn: MouseButton) bool {
        return self.mouse.buttons.justPressed(btn);
    }

    pub fn mousePressed(self: *const InputState, btn: MouseButton) bool {
        return self.mouse.buttons.pressed(btn);
    }

    pub fn mouseJustReleased(self: *const InputState, btn: MouseButton) bool {
        return self.mouse.buttons.justReleased(btn);
    }

    // keyboard
    pub fn keyJustPressed(self: *const InputState, btn: Scancode) bool {
        return self.keys.justPressed(btn);
    }

    pub fn keyPressed(self: *const InputState, btn: Scancode) bool {
        return self.keys.pressed(btn);
    }

    pub fn keyJustReleased(self: *const InputState, btn: Scancode) bool {
        return self.keys.justReleased(btn);
    }

    // keyboard iterators
    pub fn keyNextPressed(self: *const InputState) ?Scancode {
        return self.keys.getNextPressed();
    }

    pub fn keyNextJustPressed(self: *const InputState) ?Scancode {
        return self.keys.getNextJustPressed();
    }

    pub fn keyNextJustReleased(self: *const InputState) ?Scancode {
        return self.keys.getNextJustReleased();
    }
};
