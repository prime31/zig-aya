const std = @import("std");

pub const WindowConfig = @import("src/window.zig").WindowConfig;

// libs
const renderkit = @import("renderkit");
const sdl = @import("sdl");
pub const imgui = @import("imgui");

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

    update_rate: f64 = 60, // desired fps
    gfx: gfx.Config = gfx.Config{},
    window: WindowConfig = WindowConfig{},
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
        .metal = metal_setup,
    });

    gfx.init(config.gfx);
    time = Time.init(config.update_rate);
    input = Input.init(window.scale());
    debug = try Debug.init();
    defer debug.deinit();

    try config.init();

    while (!pollEvents()) {
        time.tick();
        if (config.update) |update| try update();
        try config.render();

        if (renderkit.current_renderer == .opengl) sdl.SDL_GL_SwapWindow(window.sdl_window);
        gfx.commitFrame();
        input.newFrame();
    }

    if (config.shutdown) |shutdown| try shutdown();

    gfx.deinit();
    renderkit.renderer.shutdown();
    window.deinit();
    sdl.SDL_Quit();
}

fn loadDefaultImGuiFont() void {
    var io = imgui.igGetIO();
    _ = imgui.ImFontAtlas_AddFontDefault(io.Fonts, null);

    // add FontAwesome
    const font_awesome_range: [3]imgui.ImWchar = [_]imgui.ImWchar{ imgui.icons.icon_range_min, imgui.icons.icon_range_max, 0 };

    var icons_config = imgui.ImFontConfig_ImFontConfig();
    icons_config[0].MergeMode = true;
    icons_config[0].PixelSnapH = true;
    icons_config[0].FontDataOwnedByAtlas = false;

    var data = @embedFile("assets/" ++ imgui.icons.font_icon_filename_fas);
    _ = imgui.ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 13, icons_config, &font_awesome_range[0]);

    var w: i32 = undefined;
    var h: i32 = undefined;
    var bytes_per_pixel: i32 = undefined;
    var pixels: [*c]u8 = undefined;
    imgui.ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

    var tex = gfx.Texture.initWithData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h, .nearest);
    imgui.ImFontAtlas_SetTexID(io.Fonts, tex.imTextureID());
}

fn pollEvents() bool {
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
