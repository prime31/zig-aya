const std = @import("std");
const sdl = @import("sdl");
const aya = @import("../aya.zig");

const App = aya.App;
const Input = @import("input.zig").Input;
const Events = aya.Events;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

// TODO: add way more events

pub const WindowResized = struct {
    width: f32,
    height: f32,
};

pub const WindowMoved = struct {
    x: f32,
    y: f32,
};

pub const WindowFocused = struct { focused: bool };

pub const WindowScaleFactorChanged = struct { scale_factor: f32 };

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
                .addEvent(WindowMoved)
                .addEvent(WindowScaleFactorChanged)
                .addEvent(WindowFocused)
                .initResource(Input)
                .insertResource(Window{
                .sdl_window = window,
                .id = sdl.SDL_GetWindowID(window),
            });

            _ = app.setRunner(eventLoop);
        }
    }
};

fn eventLoop(app: *App) void {
    const window = app.world.getResource(Window).?;
    const input = app.world.getResourceMut(Input).?;

    const exit_event_reader = getEventReader(aya.AppExitEvent, app);
    const window_resized_writer = getEventWriter(WindowResized, app);
    const window_moved_writer = getEventWriter(WindowMoved, app);
    const window_scale_factor_writer = getEventWriter(WindowScaleFactorChanged, app);

    blk: while (true) {
        if (exit_event_reader.get().len > 0) break :blk;

        input.newFrame();

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
                sdl.SDL_EVENT_WINDOW_MOVED => window_moved_writer.send(.{
                    .x = @floatFromInt(event.window.data1),
                    .y = @floatFromInt(event.window.data2),
                }),
                sdl.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => window_scale_factor_writer.send(.{
                    .scale_factor = sdl.SDL_GetWindowDisplayScale(window.sdl_window),
                }),
                sdl.SDL_EVENT_MOUSE_BUTTON_UP, sdl.SDL_EVENT_MOUSE_BUTTON_DOWN => input.handleEvent(&event),
                sdl.SDL_EVENT_MOUSE_MOTION => {},
                sdl.SDL_EVENT_MOUSE_WHEEL => {},
                else => input.handleEvent(&event),
            }
        }

        app.world.progress(0);
    }

    if (app.world.getResource(Window)) |win| sdl.SDL_DestroyWindow(win.sdl_window);
    sdl.SDL_Quit();
}

fn getEventWriter(comptime T: type, app: *App) EventWriter(T) {
    return EventWriter(T){
        .events = app.world.getResourceMut(Events(T)) orelse @panic("no EventWriter found for " ++ @typeName(T)),
    };
}

fn getEventReader(comptime T: type, app: *App) EventReader(T) {
    return EventReader(T){
        .events = app.world.getResourceMut(Events(T)) orelse @panic("no EventReader found for " ++ @typeName(T)),
    };
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
