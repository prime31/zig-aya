const std = @import("std");
const aya = @import("aya.zig");
usingnamespace aya.sokol;

pub const WindowConfig = struct {
    title: []const u8 = "zig aya", // the window title as UTF-8 encoded string
    width: i32 = 640, // the preferred width of the window / canvas
    height: i32 = 480, // the preferred height of the window / canvas
    resizable: bool = true, // whether the window should be allowed to be resized
    fullscreen: bool = false, // whether the window should be created in fullscreen mode
    high_dpi: bool = false, // whether the backbuffer is full-resolution on HighDPI displays
};

pub fn handleEvent(event: anytype) void {}

/// returns the drawable size / the window size. Used to scale mouse coords when the OS gives them to us in points.
pub fn scale() f32 {
    return @intToFloat(f32, sapp_width()) / @intToFloat(f32, sapp_height());
}

pub fn width() i32 {
    return sapp_width();
}

pub fn height() i32 {
    return sapp_height();
}
