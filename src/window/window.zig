const std = @import("std");
const sdl = @import("sdl");
const aya = @import("../aya.zig");

const App = aya.App;
const Input = aya.Input;
const Scancode = aya.Scancode;
const Events = aya.Events;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

const eventLoop = @import("runner.zig").eventLoop;

// TODO: add way more window events
pub const WindowResized = struct { width: f32, height: f32 };
pub const WindowMoved = struct { x: f32, y: f32 };
pub const WindowFocused = struct { focused: bool };
pub const WindowScaleFactorChanged = struct { scale_factor: f32 };
// SDL_EVENT_WINDOW_HIDDEN
// SDL_EVENT_WINDOW_EXPOSED
// SDL_EVENT_WINDOW_SIZE_CHANGED
// SDL_EVENT_WINDOW_MINIMIZED
// SDL_EVENT_WINDOW_MAXIMIZED
// SDL_EVENT_WINDOW_RESTORED
// SDL_EVENT_WINDOW_MOUSE_ENTER
// SDL_EVENT_WINDOW_MOUSE_LEAVE
// SDL_EVENT_WINDOW_FOCUS_GAINED
// SDL_EVENT_WINDOW_FOCUS_LOST
// SDL_EVENT_WINDOW_CLOSE_REQUESTED
// SDL_EVENT_WINDOW_TAKE_FOCUS
// SDL_EVENT_WINDOW_HIT_TEST
// SDL_EVENT_WINDOW_ICCPROF_CHANGED
// SDL_EVENT_WINDOW_DISPLAY_CHANGED

pub const WindowPlugin = struct {
    window_config: ?WindowConfig = .{},

    pub fn build(self: WindowPlugin, app: *App) void {
        if (self.window_config) |config| {
            if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_HAPTIC | sdl.SDL_INIT_GAMEPAD) != 0) {
                sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
                @panic("could not init SDL");
            }

            var flags: c_uint = 0;
            if (config.resizable) flags |= @intFromEnum(WindowFlags.resizable);
            if (config.high_dpi) flags |= @intFromEnum(WindowFlags.high_pixel_density);
            if (config.fullscreen) flags |= @intFromEnum(WindowFlags.fullscreen);

            const window = sdl.SDL_CreateWindow(config.title, config.width, config.height, flags) orelse {
                sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
                @panic("no window created");
            };

            _ = app
                .setRunner(eventLoop)
            // window
                .addEvent(WindowResized)
                .addEvent(WindowMoved)
                .addEvent(WindowScaleFactorChanged)
                .addEvent(WindowFocused)
                .insertResource(Window{ .sdl_window = window, .id = sdl.SDL_GetWindowID(window) })
            // mouse
                .addEvent(aya.MouseMotion)
                .addEvent(aya.MouseWheel)
                .initResource(Input(aya.MouseButton))
            // keyboard
                .initResource(Input(Scancode))
            // gamepad
                .addEvent(aya.GamepadConnectionEvent)
                .initResource(aya.Gamepads)
                .initResource(Input(aya.GamepadButton))
                .initResource(aya.Axis(aya.GamepadAxis));
        }
    }
};

pub const Window = struct {
    sdl_window: *sdl.SDL_Window = undefined,
    focused: bool = true,
    id: u32 = 0,
};

pub const WindowConfig = struct {
    title: [:0]const u8 = "zig aya", // the window title as UTF-8 encoded string
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
