const sdl = @import("deps/sdl/sdl.zig");
const mem = @import("mem/mem.zig");
const fna = @import("deps/fna/fna.zig");
const std = @import("std");

pub const WindowConfig = struct {
    title: []const u8,
    width: i32,
    height: i32,
    resizable: bool,
    fullscreen: bool,
    high_dpi: bool,
};

pub const WindowMode = enum(u32) {
    windowed = 0,
    full_screen = 1,
    desktop = 4097,
};

pub const Window = struct {
    sdl_window: ?*sdl.SDL_Window = null,
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

    pub fn swap(self: Window, device: *fna.Device) void {
        device.swapBuffers(self.sdl_window);
    }

    pub fn handleEvent(self: *Window, event: *sdl.SDL_WindowEvent) void {
        switch (event.event) {
            @enumToInt(sdl.SDL_WindowEventID.SDL_WINDOWEVENT_SIZE_CHANGED) => std.debug.warn("sizec \n", .{}),
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

    pub fn drawableSize(self: Window, w: *i32, h: *i32) void {
        fna.getDrawableSize(self.sdl_window, w, h);
    }

    pub fn size(self: Window, w: *i32, h: *i32) void {
        sdl.SDL_GetWindowSize(self.sdl_window, w, h);
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

    pub fn setSize(self: Window, w: i32, h: i32) void {
        sdl.SDL_SetWindowSize(self.sdl_window, w, h);
    }

    pub fn setMode(self: Window, mode: WindowMode) void {
        sdl.SDL_SetWindowFullscreen(self.sdl_window, mode);
    }

    pub fn focused(self: Window) bool {
        return self.focused;
    }
};
