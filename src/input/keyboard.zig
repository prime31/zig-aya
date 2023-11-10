const std = @import("std");
const aya = @import("../aya.zig");

const Keys = @import("pressable_input.zig").Keys;

pub const Scancode = @import("scancode.zig").Scancode;

pub var keys: Keys = .{};

pub fn newFrame() void {
    keys.clear();
}

pub fn justPressed(btn: Scancode) bool {
    return keys.justPressed(btn);
}

pub fn pressed(btn: Scancode) bool {
    return keys.pressed(btn);
}

pub fn justReleased(btn: Scancode) bool {
    return keys.justReleased(btn);
}

// groups
pub fn anyPressed(input: []const Scancode) bool {
    return keys.anyPressed(input);
}

pub fn anyJustPressed(input: []const Scancode) bool {
    return keys.anyJustPressed(input);
}

pub fn anyJustReleased(input: []const Scancode) bool {
    return keys.anyJustReleased(input);
}

// iterators
pub fn nextPressed() ?Scancode {
    return keys.getNextPressed();
}

pub fn nextJustPressed() ?Scancode {
    return keys.getNextJustPressed();
}

pub fn nextJustReleased() ?Scancode {
    return keys.getNextJustReleased();
}
