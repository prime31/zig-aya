const std = @import("std");

pub const WindowConfig = @import("src/window.zig").WindowConfig;

// libs
pub const renderkit = @import("renderkit");
pub const sdl = @import("sdl");
pub const imgui = @import("imgui");
const imgui_impl = @import("src/imgui/implementation.zig");

// aya namespaces
pub const gfx = @import("src/gfx/gfx.zig");
pub const draw = gfx.draw;
pub const fs = @import("src/fs.zig");

pub const math = @import("src/math/math.zig");
pub const mem = @import("src/mem/mem.zig");
pub const utils = @import("src/utils/utils.zig");
pub const tilemap = @import("src/tilemap/tilemap.zig");

// aya objects
pub var window: Window = undefined;
pub var time: Time = undefined;
pub var input: Input = undefined;
pub var debug: Debug = undefined;

const Window = @import("src/window.zig").Window;
const Time = @import("src/time.zig").Time;
const Input = @import("src/input.zig").Input;
const Debug = @import("src/debug.zig").Debug;

// search path: root.build_options, root.enable_imgui, default to false
pub const enable_imgui: bool = if (@hasDecl(@import("root"), "build_options")) blk: {
    break :blk @field(@import("root"), "build_options").enable_imgui;
} else if (@hasDecl(@import("root"), "enable_imgui"))
blk: {
    break :blk @field(@import("root"), "enable_imgui");
} else blk: {
    break :blk false;
};

pub const Config = struct {
    init: fn () anyerror!void,
    update: ?fn () anyerror!void,
    render: fn () anyerror!void,
    shutdown: ?fn () anyerror!void = null,
    onFileDropped: ?fn ([]const u8) void = null,

    gfx: gfx.Config = gfx.Config{},
    window: WindowConfig = WindowConfig{},

    update_rate: f64 = 60, // desired fps
    imgui_icon_font: bool = true,
    imgui_viewports: bool = false, // whether imgui viewports should be enabled
    imgui_docking: bool = true, // whether imgui docking should be enabled
};

pub fn run(config: Config) !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_HAPTIC | sdl.SDL_INIT_GAMECONTROLLER) != 0) {
        sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    mem.initTmpAllocator();
    window = try Window.init(config.window);

    var metal_setup = renderkit.MetalSetup{};
    if (renderkit.current_renderer == .metal) {
        var metal_view = sdl.SDL_Metal_CreateView(window.sdl_window);
        metal_setup.ca_layer = sdl.SDL_Metal_GetLayer(metal_view);
    }

    renderkit.renderer.setup(.{
        .allocator = std.testing.allocator,
        .gl_loader = sdl.SDL_GL_GetProcAddress,
        .disable_vsync = config.window.disable_vsync,
        .metal = metal_setup,
    });

    gfx.init(config.gfx);
    time = Time.init(config.update_rate);
    input = Input.init(window.scale());
    debug = try Debug.init();
    defer debug.deinit();

    if (enable_imgui) imgui_impl.init(window.sdl_window, config.imgui_docking, config.imgui_viewports, config.imgui_icon_font);

    try config.init();

    while (!pollEvents(config.onFileDropped)) {
        time.tick();
        gfx.beginFrame();

        if (config.update) |update| try update();
        try config.render();

        if (enable_imgui) {
            gfx.blitToScreen(math.Color.black);
            gfx.beginPass(.{ .color_action = .load });
            imgui_impl.render();
            gfx.endPass();
            if (renderkit.current_renderer == .opengl) _ = sdl.SDL_GL_MakeCurrent(window.sdl_window, window.gl_ctx);
        }

        if (renderkit.current_renderer == .opengl) sdl.SDL_GL_SwapWindow(window.sdl_window);
        gfx.commitFrame();
        input.newFrame();
    }

    if (config.shutdown) |shutdown| try shutdown();

    if (enable_imgui) imgui_impl.deinit();
    gfx.deinit();
    renderkit.renderer.shutdown();
    window.deinit();
    sdl.SDL_Quit();
}

fn pollEvents(onFileDropped: ?fn ([]const u8) void) bool {
    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) != 0) {
        if (enable_imgui and imgui_impl.handleEvent(&event)) continue;

        switch (event.type) {
            sdl.SDL_QUIT => return true,
            sdl.SDL_WINDOWEVENT => {
                if (event.window.windowID == window.id) {
                    if (event.window.event == sdl.SDL_WINDOWEVENT_CLOSE) return true;
                    window.handleEvent(&event.window);
                }
            },
            sdl.SDL_DROPFILE => {
                if (onFileDropped) |fileDropped| fileDropped(std.mem.spanZ(event.drop.file));
                sdl.SDL_free(event.drop.file);
            },
            else => input.handleEvent(&event),
        }
    }

    // if ImGui is running we force a timer resync every frame. This ensures we get exactly one update call and one render call
    // each frame which prevents ImGui from flickering due to skipped/doubled update calls.
    if (enable_imgui) {
        imgui_impl.newFrame();
        time.resync();
    }

    return false;
}
