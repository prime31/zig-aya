const std = @import("std");
const aya = @import("../aya.zig");
usingnamespace aya.sokol;

pub const WindowConfig = struct {
    title: []const u8 = "zig aya", // the window title as UTF-8 encoded string
    width: i32 = 640, // the preferred width of the window / canvas
    height: i32 = 480, // the preferred height of the window / canvas
    resizable: bool = true, // whether the window should be allowed to be resized
    fullscreen: bool = false, // whether the window should be created in fullscreen mode
    high_dpi: bool = false, // whether the backbuffer is full-resolution on HighDPI displays
};

var window_active = true;

pub fn handleEvent(evt: *const sapp_event) void {
    switch (evt.type) {
        .SAPP_EVENTTYPE_RESIZED => {},
        .SAPP_EVENTTYPE_RESTORED, .SAPP_EVENTTYPE_RESUMED => window_active = true,
        .SAPP_EVENTTYPE_SUSPENDED, .SAPP_EVENTTYPE_ICONIFIED => window_active = false,
        else => {},
    }
}

/// returns the drawable size / the window size. Used to scale mouse coords when the OS gives them to us in points.
pub fn scale() f32 {
    return sapp_dpi_scale();
}

pub fn width() i32 {
    return sapp_width();
}

pub fn height() i32 {
    return sapp_height();
}

pub fn size() struct { w: i32, h: i32 } {
    return .{ .w = sapp_width(), .h = sapp_height() };
}

pub fn sizeVec2() aya.math.Vec2 {
    return .{ .x = @intToFloat(f32, sapp_width()), .y = @intToFloat(f32, sapp_height()) };
}

pub fn active() bool {
    return window_active;
}
