const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    std.debug.print("wtf: {}\n", .{sdl.SDL_Init(sdl.SDL_INIT_GAMEPAD)});

    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_HAPTIC | sdl.SDL_INIT_GAMEPAD) != 0) {
        sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    const window = createOpenGlWindow(sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_HIGH_PIXEL_DENSITY);

    while (true) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => return,
                sdl.SDL_EVENT_WINDOW_CLOSE_REQUESTED => {
                    std.debug.print("window evt: {}\n", .{event.window.type});
                },
                else => {},
            }
            _ = sdl.SDL_GL_SwapWindow(window.window);
        }
    }
}

fn createOpenGlWindow(flags: c_int) struct { window: ?*sdl.SDL_Window, gl_ctx: sdl.SDL_GLContext } {
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_FLAGS, sdl.SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_PROFILE_MASK, sdl.SDL_GL_CONTEXT_PROFILE_CORE);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 3);

    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_DOUBLEBUFFER, 1);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_DEPTH_SIZE, 24);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_STENCIL_SIZE, 8);

    var window_flags = flags | sdl.SDL_WINDOW_OPENGL;
    const sdl_window = sdl.SDL_CreateWindow("window title a-hole", 1024, 768, @as(u32, @bitCast(window_flags))) orelse {
        sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
        @panic("no window");
    };

    return .{
        .window = sdl_window,
        .gl_ctx = sdl.SDL_GL_CreateContext(sdl_window),
    };
}
