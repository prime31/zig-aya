const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya.zig");

pub const Size = struct {
    w: c_int = 0,
    h: c_int = 0,
};

// TODO: add more window events
pub const WindowResized = struct { width: f32, height: f32 };
pub const WindowMoved = struct { x: f32, y: f32 };
pub const WindowFocused = struct { focused: bool };
pub const WindowScaleFactorChanged = struct { scale_factor: f32 };
pub const WindowMouseFocused = struct { focused: bool };
// SDL_EVENT_WINDOW_HIDDEN
// SDL_EVENT_WINDOW_EXPOSED
// SDL_EVENT_WINDOW_MINIMIZED
// SDL_EVENT_WINDOW_MAXIMIZED
// SDL_EVENT_WINDOW_RESTORED
// SDL_EVENT_WINDOW_TAKE_FOCUS
// SDL_EVENT_WINDOW_HIT_TEST
// SDL_EVENT_WINDOW_DISPLAY_CHANGED

pub const Vsync = enum { immediate, synchronized, adaptive };

pub const WindowConfig = struct {
    title: [:0]const u8 = "zig thing", // the window title as UTF-8 encoded string
    width: i32 = 1024, // the preferred width of the window / canvas
    height: i32 = 768, // the preferred height of the window / canvas
    resizable: bool = true, // whether the window should be allowed to be resized
    fullscreen: bool = false, // whether the window should be created in fullscreen mode
    high_dpi: bool = false, // whether the backbuffer is full-resolution on HighDPI displays
    vsync: Vsync = .synchronized, // whether vsync should be disabled
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

// pub const Window = struct {
pub var sdl_window: *sdl.SDL_Window = undefined;
pub var id: u32 = 0;
pub var focused: bool = true;
pub var gl_ctx: sdl.SDL_GLContext = null;

pub fn init(config: WindowConfig) void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_HAPTIC | sdl.SDL_INIT_GAMEPAD) != 0) {
        sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
        @panic("could not init SDL");
    }

    var flags: c_uint = @intFromEnum(WindowFlags.opengl);
    if (config.resizable) flags |= @intFromEnum(WindowFlags.resizable);
    if (config.high_dpi) flags |= @intFromEnum(WindowFlags.high_pixel_density);
    if (config.fullscreen) flags |= @intFromEnum(WindowFlags.fullscreen);

    sdl_window = sdl.SDL_CreateWindow(config.title, config.width, config.height, flags) orelse {
        sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
        @panic("no window created");
    };
    id = sdl.SDL_GetWindowID(sdl_window);

    switch (config.vsync) {
        .adaptive => _ = sdl.SDL_GL_SetSwapInterval(-1),
        .immediate => _ = sdl.SDL_GL_SetSwapInterval(0),
        .synchronized => _ = sdl.SDL_GL_SetSwapInterval(1),
    }
}

pub fn deinit() void {
    sdl.SDL_DestroyWindow(sdl_window);
    sdl.SDL_Quit();
}

pub fn sizeInPixels() Size {
    var sz = Size{};
    _ = sdl.SDL_GetWindowSizeInPixels(sdl_window, &sz.w, &sz.h);
    return sz;
}

pub fn scale() f32 {
    return sdl.SDL_GetWindowDisplayScale(sdl_window);
}

pub fn size() Size {
    var sz = Size{};
    _ = sdl.SDL_GetWindowSize(sdl_window, &sz.w, &sz.h);
    return sz;
}

pub fn setSize(w: i32, h: i32) void {
    sdl.SDL_SetWindowSize(sdl_window, w, h);
}

pub fn position() Size {
    var sz = Size{};
    sdl.SDL_GetWindowPosition(sdl_window, &sz.x, &sz.h);
    return sz;
}

pub fn setPosition(x: i32, y: i32) void {
    sdl.SDL_SetWindowPosition(sdl_window, x, y);
}

pub fn setFullscreen(fullscreen: bool) void {
    _ = sdl.SDL_SetWindowFullscreen(sdl_window, if (fullscreen) 1 else 0);
}

pub fn resizable() bool {
    return (sdl.SDL_GetWindowFlags(sdl_window) & @as(u32, @intCast(@intFromEnum(sdl.SDL_WINDOW_RESIZABLE)))) != 0;
}

pub fn setResizable(is_resizable: bool) void {
    sdl.SDL_SetWindowResizable(sdl_window, is_resizable);
}

pub fn setVsync(vsync: Vsync) void {
    switch (vsync) {
        .adaptive => _ = sdl.SDL_GL_SetSwapInterval(-1),
        .immediate => _ = sdl.SDL_GL_SetSwapInterval(0),
        .synchronized => _ = sdl.SDL_GL_SetSwapInterval(1),
    }
}
