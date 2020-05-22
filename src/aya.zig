const std = @import("std");

pub const WindowConfig = @import("window.zig").WindowConfig;

// libs
pub const sdl = @import("deps/sdl/sdl.zig");
pub const fna = @import("deps/fna/fna.zig");

// aya namespaces
pub const gfx = @import("gfx/gfx.zig");
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

pub const Config = struct {
    init: fn () void,
    update: fn () void,
    render: fn () void,

    update_rate: f64 = 60, // desired fps
    update_multiplicity: i64 = 1, // Makes the game always do a multiple of N updates at a time. Defaults to 1. 2 would be update_rate / multiplicity or 30fps.

    gfx_config: gfx.Config = gfx.Config{
        .resolution_policy = .default, // defines how the main render texture should be blitted to the backbuffer
        .design_width = 0, // the width of the main offscreen render texture when the policy is not .default
        .design_height = 0, // the height of the main offscreen render texture when the policy is not .default
        .batcher_max_sprites = 1000, // defined the size of the vertex/index buffers based on the number of sprites/quads
        .disable_debug_render = false, // when true, debug rendering will be disabled
    },

    win_config: WindowConfig = WindowConfig{
        .title = "Zig FNA", // the window title as UTF-8 encoded string
        .width = 640, // the preferred width of the window / canvas
        .height = 480, // the preferred height of the window / canvas
        .resizable = true, // whether the window should be allowed to be resized
        .fullscreen = false, // whether the window should be created in fullscreen mode
        .high_dpi = false, // whether the backbuffer is full-resolution on HighDPI displays
    },

    imgui_disabled: bool = false, // whether imgui should be disabled
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

    window = try Window.init(config.win_config);
    defer window.deinit();

    var params = fna.PresentationParameters{
        .backBufferWidth = config.win_config.width,
        .backBufferHeight = config.win_config.height,
        .deviceWindowHandle = window.sdl_window,
    };
    try gfx.init(&params, config.gfx_config);

    time = Time.init(config.update_rate, config.update_multiplicity);
    input = Input.init(window.scale());
    debug = try Debug.init();
    defer debug.deinit();

    config.init();
    runLoop(config.update, config.render);
}

fn runLoop(update: fn () void, render: fn () void) void {
    while (!pollEvents()) {
        gfx.device.beginFrame();

        // TODO: never clear automatically
        gfx.clear(math.Color.aya);

        time.tick(update);
        render();

        gfx.commit();
        window.swap(gfx.device);
    }
}

/// returns true when its time to quit
fn pollEvents() bool {
    input.newFrame();
    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            sdl.SDL_QUIT => return true,
            sdl.SDL_WINDOWEVENT => {
                if (event.window.windowID == window.id) {
                    if (event.window.event == sdl.SDL_WINDOWEVENT_CLOSE) return true;
                    window.handleEvent(&event.window);
                }
            },
            else => input.handleEvent(&event),
        }
    }
    return false;
}
