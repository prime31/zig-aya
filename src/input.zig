const std = @import("std");
const aya = @import("aya.zig");

const Keys = aya.Keys;
const MouseButtons = aya.MouseButtons;
const GamePads = aya.Gamepads;

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
};
