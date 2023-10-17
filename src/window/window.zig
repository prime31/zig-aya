const std = @import("std");
const aya = @import("../aya.zig");
const core = @import("mach-core");
const glfw = @import("mach-glfw");

const App = aya.App;
const Input = aya.Input;
const Events = aya.Events;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

// TODO: add way more window events
pub const WindowResized = struct { width: f32, height: f32 };
pub const WindowMoved = struct { x: f32, y: f32 };
pub const WindowFocused = struct { focused: bool };
pub const WindowScaleFactorChanged = struct { scale_factor: f32 };

pub const WindowPlugin = struct {
    window_config: ?WindowConfig = .{},

    pub fn build(self: WindowPlugin, app: *App) void {
        if (self.window_config) |config| {
            _ = config;
            if (!glfw.Joystick.updateGamepadMappings(@embedFile("gamecontrollerdb.txt")))
                std.log.warn("updateGamepadMappings returned false\n", .{});

            _ = app
            // window
                .addEvent(WindowResized)
                .addEvent(WindowMoved)
                .addEvent(WindowScaleFactorChanged)
                .addEvent(WindowFocused)
            // .insertResource(Window{ .sdl_window = window, .id = sdl.SDL_GetWindowID(window) })
            // mouse
                .addEvent(aya.MouseMotion)
                .addEvent(aya.MouseWheel)
                .initResource(Input(aya.MouseButton))
            // keyboard
                .initResource(Input(aya.Key))
            // gamepad
                .addEvent(aya.GamepadConnectionEvent)
                .initResource(aya.Gamepads)
                .initResource(Input(aya.GamepadButton))
                .initResource(aya.Axis(aya.GamepadAxis));
        }
    }
};

pub const Window = struct {
    glfw_window: *anyopaque = undefined,
    focused: bool = true,
    id: u32 = 0,

    pub fn sizeInPixels(self: Window) struct { w: c_int, h: c_int } {
        _ = self;
        var w: c_int = 0;
        var h: c_int = 0;
        // _ = sdl.SDL_GetWindowSizeInPixels(self.sdl_window, &w, &h);
        return .{ .w = w, .h = h };
    }

    pub fn size(self: Window) struct { w: c_int, h: c_int } {
        _ = self;
        var w: c_int = 0;
        var h: c_int = 0;
        // _ = sdl.SDL_GetWindowSize(self.sdl_window, &w, &h);
        return .{ .w = w, .h = h };
    }
};

pub const WindowConfig = struct {
    title: [:0]const u8 = "zig bevyish", // the window title as UTF-8 encoded string
    width: i32 = 1024, // the preferred width of the window / canvas
    height: i32 = 768, // the preferred height of the window / canvas
    resizable: bool = true, // whether the window should be allowed to be resized
    fullscreen: bool = false, // whether the window should be created in fullscreen mode
    high_dpi: bool = false, // whether the backbuffer is full-resolution on HighDPI displays
};
