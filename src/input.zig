const std = @import("std");
const aya = @import("aya.zig");

const Keys = aya.win.Keys;
const MouseButtons = aya.win.MouseButtons;
const GamePads = aya.win.Gamepads;

const MouseButton = aya.win.MouseButton;
const Scancode = aya.win.Scancode;

pub const Input = struct {
    const Mouse = struct {
        buttons: MouseButtons = .{},
        wheel_x: f32 = 0,
        wheel_y: f32 = 0,
        pos: aya.Vec2 = .{},
    };

    keys: Keys = .{},
    mouse: Mouse = .{},
    gamepads: GamePads,

    pub fn init() Input {
        return .{
            .gamepads = GamePads.init(),
        };
    }

    pub fn deinit(self: *Input) void {
        self.gamepads.deinit();
    }

    pub fn newFrame(self: *Input) void {
        self.mouse.buttons.clear();
        self.keys.clear();
        self.gamepads.update();
    }

    pub fn mouseJustPressed(self: *const Input, btn: MouseButton) bool {
        return self.mouse.buttons.justPressed(btn);
    }

    pub fn mousePressed(self: *const Input, btn: MouseButton) bool {
        return self.mouse.buttons.pressed(btn);
    }

    pub fn mouseJustReleased(self: *const Input, btn: MouseButton) bool {
        return self.mouse.buttons.justReleased(btn);
    }

    pub fn keyJustPressed(self: *const Input, btn: Scancode) bool {
        return self.keys.justPressed(btn);
    }

    pub fn keyPressed(self: *const Input, btn: Scancode) bool {
        return self.keys.pressed(btn);
    }

    pub fn keyJustReleased(self: *const Input, btn: Scancode) bool {
        return self.keys.justReleased(btn);
    }
};
