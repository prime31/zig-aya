const std = @import("std");
const sdl = @import("sdl");
const aya = @import("../aya.zig");

const App = aya.App;

// TODO: add way more events

pub const WindowResized = struct {
    width: f32,
    height: f32,
};

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

            _ = app.addEvent(WindowResized)
                .insertResource(Window{
                .sdl_window = window,
                .id = sdl.SDL_GetWindowID(window),
            });

            _ = app.setRunner(eventLoop);
        }
    }
};

fn eventLoop(app: *App) void {
    const exit_event_reader = aya.EventReader(aya.AppExitEvent){
        .events = app.world.getResourceMut(aya.Events(aya.AppExitEvent)) orelse @panic("no AppExitEvent reader"),
    };
    const window_resized_writer = aya.EventWriter(WindowResized){
        .events = app.world.getResourceMut(aya.Events(WindowResized)) orelse @panic("no WindowResizedEvent reader"),
    };

    blk: while (true) {
        if (exit_event_reader.get().len > 0) break :blk;

        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            // if (imgui.sdl.handleEvent(&event)) continue;
            switch (event.type) {
                sdl.SDL_EVENT_QUIT => break :blk,
                sdl.SDL_EVENT_WINDOW_CLOSE_REQUESTED => {
                    std.debug.print("window evt: {}\n", .{event.window.type});
                },
                sdl.SDL_EVENT_WINDOW_RESIZED => window_resized_writer.send(.{
                    .width = @floatFromInt(event.window.data1),
                    .height = @floatFromInt(event.window.data2),
                }),
                sdl.SDL_EVENT_MOUSE_BUTTON_UP, sdl.SDL_EVENT_MOUSE_BUTTON_DOWN => {},
                sdl.SDL_EVENT_MOUSE_MOTION => {},
                sdl.SDL_EVENT_MOUSE_WHEEL => {},
                else => {},
            }
        }

        app.world.progress(0);
    }

    if (app.world.getResource(Window)) |window| sdl.SDL_DestroyWindow(window.sdl_window);
    sdl.SDL_Quit();
}

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
