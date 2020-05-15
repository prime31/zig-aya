const std = @import("std");

pub const WindowConfig = @import("window.zig").WindowConfig;

pub const sdl = @import("deps/sdl/sdl.zig");
pub const fna = @import("deps/fna/fna.zig");

pub const gfx = @import("gfx/gfx.zig");
pub const math = @import("math/math.zig");
pub const fs = @import("fs.zig");
pub const mem = @import("mem/mem.zig");
pub const utils = @import("utils/utils.zig");

pub var window = @import("window.zig").Window{};
pub var time = @import("time.zig").Time{};

pub const Config = struct {
    init: fn () void,
    update: fn () void,
    render: fn () void,

    update_rate: f64 = 60, // desired fps
    update_multiplicity: i64 = 1, // Makes the game always do a multiple of N updates at a time. Defaults to 1. 2 would be update_rate / multiplicity or 30fps.

    resolution_policy: gfx.ResolutionPolicy = .default, // defines how the main render texture should be blitted to the backbuffer
    design_width: i32 = 0, // the width of the main offscreen render texture when the policy is not .default
    design_height: i32 = 0, // the height of the main offscreen render texture when the policy is not .default

    win_config: WindowConfig = WindowConfig{}, // window configuration
    disable_debug_render: bool = false, // when true, debug rendering will be disabled

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

    try window.create(config.win_config);
    defer window.deinit();

    var params = fna.PresentationParameters{
        .backBufferWidth = config.win_config.width,
        .backBufferHeight = config.win_config.height,
        .deviceWindowHandle = window.sdl_window,
    };
    gfx.init(&params, config.disable_debug_render, config.design_width, config.design_height, config.resolution_policy);
    time.init(config.update_rate, config.update_multiplicity);

    config.init();
    runLoop(config.update, config.render);
}

fn runLoop(update: fn () void, render: fn () void) void {
    while (!pollEvents()) {
        fna.FNA3D_BeginFrame(gfx.device);

        // TODO: never clear automatically
        gfx.clear(.{ .x = 0.8, .y = 0.2, .z = 0.3, .w = 1 });

        time.tick(update);
        render();

        window.swap(gfx.device);
    }
}

/// returns true when its time to quit
fn pollEvents() bool {
    // input.newFrame();
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
            else => {}, // input.handleEvent(&event);
        }
    }
    return false;
}
