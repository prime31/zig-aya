const std = @import("std");
const sdl = @import("sdl");
const fna = @import("fna");
const mem = @import("mem/mem.zig");

pub const WindowConfig = struct {
    title: []const u8 = "zig aya", // the window title as UTF-8 encoded string
    width: i32 = 640, // the preferred width of the window / canvas
    height: i32 = 480, // the preferred height of the window / canvas
    resizable: bool = true, // whether the window should be allowed to be resized
    fullscreen: bool = false, // whether the window should be created in fullscreen mode
    high_dpi: bool = false, // whether the backbuffer is full-resolution on HighDPI displays
};

pub const WindowMode = enum(u32) {
    windowed = 0,
    full_screen = 1,
    desktop = 4097,
};

pub const Window = struct {
    sdl_window: *sdl.SDL_Window = undefined,
    id: u32 = 0,
    focused: bool = undefined,

    pub fn init(config: WindowConfig) !Window {
        var window = Window{};

        var flags = fna.prepareWindowAttributes();
        if (config.resizable) flags |= @enumToInt(sdl.SDL_WindowFlags.SDL_WINDOW_RESIZABLE);
        if (config.high_dpi) flags |= @enumToInt(sdl.SDL_WindowFlags.SDL_WINDOW_ALLOW_HIGHDPI);
        if (config.fullscreen) flags |= @enumToInt(sdl.SDL_WindowFlags.SDL_WINDOW_FULLSCREEN_DESKTOP);

        const title = try std.cstr.addNullByte(mem.tmp_allocator, config.title);
        window.sdl_window = sdl.SDL_CreateWindow(title, sdl.SDL_WINDOWPOS_UNDEFINED, sdl.SDL_WINDOWPOS_UNDEFINED, config.width, config.height, @bitCast(u32, flags)) orelse {
            sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
            return error.SDLWindowInitializationFailed;
        };

        window.id = sdl.SDL_GetWindowID(window.sdl_window);
        return window;
    }

    pub fn deinit(self: Window) void {
        sdl.SDL_DestroyWindow(self.sdl_window);
    }

    pub fn handleEvent(self: *Window, event: *sdl.SDL_WindowEvent) void {
        switch (event.event) {
            @enumToInt(sdl.SDL_WindowEventID.SDL_WINDOWEVENT_SIZE_CHANGED) => {
                std.debug.warn("resize: {}x{}\n", .{ event.data1, event.data2 });
                // TODO: make a resized event and let gfx resize itself
                @import("aya.zig").gfx.resetBackbuffer(event.data1, event.data2);
                @import("aya.zig").time.resync();
            },
            @enumToInt(sdl.SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_GAINED) => self.focused = true,
            @enumToInt(sdl.SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_LOST) => self.focused = false,
            else => {},
        }
    }

    /// returns the drawable size / the window size. Used to scale mouse coords when the OS gives them to us in points.
    pub fn scale(self: Window) f32 {
        var wx = self.width();

        var dx: i32 = undefined;
        var dy: i32 = undefined;
        self.drawableSize(&dx, &dy);

        return @intToFloat(f32, dx) / @intToFloat(f32, wx);
    }

    pub fn width(self: Window) i32 {
        var w: i32 = undefined;
        var h: i32 = undefined;
        self.size(&w, &h);
        return w;
    }

    pub fn height(self: Self) i32 {
        var w: i32 = undefined;
        var h: i32 = undefined;
        self.size(&w, &h);
        return h;
    }

    pub fn drawableSize(self: Window, w: *i32, h: *i32) void {
        fna.getDrawableSize(self.sdl_window, w, h);
    }

    pub fn size(self: Window, w: *i32, h: *i32) void {
        sdl.SDL_GetWindowSize(self.sdl_window, w, h);
    }

    pub fn setSize(self: Window, w: i32, h: i32) void {
        sdl.SDL_SetWindowSize(self.sdl_window, w, h);
    }

    pub fn position(self: Window, x: *i32, y: *i32) void {
        sdl.SDL_GetWindowPosition(self.sdl_window, x, y);
    }

    pub fn setPosition(self: Window, x: i32, y: i32) void {
        sdl.SDL_SetWindowPosition(self.sdl_window, x, y);
    }

    pub fn setMode(self: Window, mode: WindowMode) void {
        sdl.SDL_SetWindowFullscreen(self.sdl_window, mode);
    }

    pub fn focused(self: Window) bool {
        return self.focused;
    }

    pub fn setResizable(self: Window, resizable: bool) void {
        sdl.SDL_SetWindowResizable(self.sdl_window, resizable);
    }

    pub fn resizable(self: Window) bool {
        return (sdl.SDL_GetWindowFlags(self.sdl_window) & @intCast(u32, @enumToInt(sdl.SDL_WindowFlags.SDL_WINDOW_RESIZABLE))) != 0;
    }
};
