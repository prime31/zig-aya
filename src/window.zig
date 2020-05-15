const sdl = @import("deps/sdl/sdl.zig");
const mem = @import("mem/mem.zig");
const fna = @import("deps/fna/fna.zig");
const std = @import("std");

pub const WindowConfig = struct {
    title: []const u8 = "Zig FNA", // the window title as UTF-8 encoded string
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
    sdl_window: ?*sdl.SDL_Window = null,
    id: u32 = 0,
    focused: bool = undefined,

    pub fn init(config: WindowConfig) !Window {
        var window = Window{};

        var flags = @bitCast(c_int, fna.FNA3D_PrepareWindowAttributes());
        if (config.resizable) flags |= sdl.SDL_WINDOW_RESIZABLE;
        if (config.high_dpi) flags |= sdl.SDL_WINDOW_ALLOW_HIGHDPI;
        if (config.fullscreen) flags |= sdl.SDL_WINDOW_FULLSCREEN_DESKTOP;

        // TODO: use a temp allocator when we have one
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

    pub fn swap(self: Window, device: ?*fna.Device) void {
        fna.FNA3D_SwapBuffers(device, null, null, self.sdl_window);
    }

    pub fn handleEvent(self: *Window, event: *sdl.SDL_WindowEvent) void {
        switch (event.event) {
            sdl.SDL_WINDOWEVENT_SIZE_CHANGED => std.debug.warn("sizec \n", .{}),
            sdl.SDL_WINDOWEVENT_FOCUS_GAINED => self.focused = true,
            sdl.SDL_WINDOWEVENT_FOCUS_LOST => self.focused = false,
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
        fna.FNA3D_GetDrawableSize(self.sdl_window, w, h);
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
