const std = @import("std");
const aya = @import("../aya.zig");

const MouseButtons = @import("pressable_input.zig").MouseButtons;

pub const MouseMotion = struct {
    x: f32,
    y: f32,
    /// The change in the position of the pointing device since the last event was sent.
    xrel: f32,
    yrel: f32,
};

pub const MouseWheel = struct {
    pub const Direction = enum { normal, flipped };

    /// The horizontal scroll value.
    x: f32,
    /// The vertical scroll value.
    y: f32,
    direction: Direction,
};

pub const MouseButton = enum(u8) {
    left = 1,
    middle = 2,
    right = 3,

    pub const max = MouseButton.right;
};

// state
pub var buttons: MouseButtons = .{};
pub var wheel_x: f32 = 0;
pub var wheel_y: f32 = 0;
pub var pos: aya.math.Vec2 = .{};

pub fn newFrame() void {
    buttons.clear();
}

pub fn justPressed(btn: MouseButton) bool {
    return buttons.justPressed(btn);
}

pub fn pressed(btn: MouseButton) bool {
    return buttons.pressed(btn);
}

pub fn justReleased(btn: MouseButton) bool {
    return buttons.justReleased(btn);
}
