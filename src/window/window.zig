const std = @import("std");
const aya = @import("../aya.zig");

const App = aya.App;
const Input = aya.Input;
const Scancode = aya.Scancode;
const Events = aya.Events;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

// const eventLoop = @import("runner.zig").eventLoop;

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
            _ = app
            // .setRunner(eventLoop)
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
                .initResource(Input(Scancode));
            // gamepad
            // .addEvent(aya.GamepadConnectionEvent)
            // .initResource(aya.Gamepads)
            // .initResource(Input(aya.GamepadButton))
            // .initResource(aya.Axis(aya.GamepadAxis));
        }
    }
};

pub const Window = struct {
    sdl_window: *anyopaque = undefined,
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

pub const WindowFlags = enum(c_int) {
    fullscreen = 1,
    opengl = 2,
    occluded = 4,
    hidden = 8,
    borderless = 16,
    resizable = 32,
    minimized = 64,
    maximized = 128,
    mouse_grabbed = 256,
    input_focus = 512,
    mouse_focus = 1024,
    foreign = 2048,
    high_pixel_density = 8192,
    mouse_capture = 16384,
    always_on_top = 32768,
    utility = 131072,
    tooltip = 262144,
    popupmenu = 524288,
    keyboard_grabbed = 1048576,
    vulkan = 268435456,
    metal = 536870912,
    transparent = 1073741824,
};
