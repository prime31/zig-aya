const std = @import("std");

pub const WindowConfig = @import("window.zig").WindowConfig;

// libs
pub const sdl = @import("deps/sdl/sdl.zig");
pub const fna = @import("deps/fna/fna.zig");

// aya namespaces
pub const gfx = @import("gfx/gfx.zig");
pub const draw = gfx.draw;
pub const fs = @import("fs.zig");

pub const math = @import("math/math.zig");
pub const mem = @import("mem/mem.zig");
pub const utils = @import("utils/utils.zig");

// aya objects
pub var window: Window = undefined;
pub var time: Time = undefined;
pub var input: Input = undefined;
pub var debug: Debug = undefined;

const Window = @import("window.zig").Window;
const Input = @import("input.zig").Input;
const Time = @import("time.zig").Time;
const Debug = @import("debug.zig").Debug;

const imgui = @import("imgui/implementation.zig");

pub const Config = struct {
    init: fn () void,
    update: fn () void,
    render: fn () void,

    update_rate: f64 = 60, // desired fps
    gfx: gfx.Config = gfx.Config{},
    window: WindowConfig = WindowConfig{},

    imgui: bool = false, // whether imgui should be disabled
    imgui_viewports: bool = false, // whether imgui viewports should be enabled
    imgui_docking: bool = true, // whether imgui docking should be enabled
};

pub fn run(config: Config) !void {
    // _ = sdl.SDL_SetHint("FNA3D_FORCE_DRIVER", "OpenGL");
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    window = try Window.init(config.window);
    defer window.deinit();

    var params = fna.PresentationParameters{
        .backBufferWidth = config.window.width,
        .backBufferHeight = config.window.height,
        .deviceWindowHandle = window.sdl_window,
    };
    try gfx.init(&params, config.gfx);
    defer gfx.deinit();

    time = Time.init(config.update_rate);
    input = Input.init(window.scale());
    debug = try Debug.init();
    defer debug.deinit();

    if (config.imgui) imgui.init(gfx.device, window.sdl_window, config.imgui_docking, config.imgui_viewports);

    config.init();
    runLoop(config.update, config.render, config.imgui);

    if (config.imgui) imgui.deinit();
}

fn runLoop(update: fn () void, render: fn () void, imgui_enabled: bool) void {
    while (!pollEvents(imgui_enabled)) {
        // if ImGui is running we force a timer resync every frame. This ensures we get exactly one update call and one render call
        // each frame which prevents ImGui from flickering due to skipped/doubled update calls.
        if (imgui_enabled) {
            imgui.newFrame();
            time.resync();
        }

        gfx.device.beginFrame();

        time.tick(update);
        render();

        gfx.commit();
        if (imgui_enabled) imgui.render();
        window.swap(gfx.device);
    }
}

/// returns true when its time to quit
fn pollEvents(imgui_enabled: bool) bool {
    input.newFrame();
    var event: sdl.SDL_Event = undefined;

    while (sdl.SDL_PollEvent(&event) != 0) {
        // ignore events imgui eats
        if (imgui_enabled and imgui.handleEvent(&event)) continue;

        switch (event.type) {
            sdl.SDL_QUIT => return true,
            sdl.SDL_WINDOWEVENT => {
                if (event.window.windowID == window.id) {
                    if (event.window.event == @enumToInt(sdl.SDL_WindowEventID.SDL_WINDOWEVENT_CLOSE)) return true;
                    window.handleEvent(&event.window);
                }
            },
            else => input.handleEvent(&event),
        }
    }
    return false;
}
