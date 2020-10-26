const std = @import("std");

pub const WindowConfig = @import("window.zig").WindowConfig;

// libs
pub const sokol = @import("sokol");
pub const imgui = @import("imgui");

// aya namespaces
pub const gfx = @import("gfx/gfx.zig");
pub const draw = gfx.draw;
pub const fs = @import("fs.zig");

pub const math = @import("math/math.zig");
pub const mem = @import("mem/mem.zig");
pub const utils = @import("utils/utils.zig");
pub const tilemap = @import("tilemap/tilemap.zig");
pub const window = @import("window.zig");

// aya objects
pub var time: Time = undefined;
pub var input: Input = undefined;
pub var debug: Debug = undefined;

const Input = @import("input.zig").Input;
const Time = @import("time.zig").Time;
const Debug = @import("debug.zig").Debug;

pub const has_imgui: bool = if (@hasDecl(@import("root"), "imgui")) @import("root").imgui else false;
usingnamespace sokol;

pub const Config = struct {
    init: fn () void,
    update: fn () void,
    render: fn () void,
    shutdown: ?fn () void = null,
    onFileDropped: ?fn ([]const u8) void = null,

    sample_count: c_int = 1,
    swap_interval: c_int = 1,
    gfx: gfx.Config = gfx.Config{},
    window: WindowConfig = WindowConfig{},
};

var state = struct {
    config: Config = undefined,
    cmd_down: bool = false,
}{};

pub fn run(config: Config) !void {
    state.config = config;

    var app_desc = std.mem.zeroInit(sapp_desc, .{
        .init_cb = init,
        .frame_cb = update,
        .cleanup_cb = cleanup,
        .event_cb = event,

        .sample_count = config.sample_count,
        .width = config.window.width,
        .height = config.window.height,
        .swap_interval = config.swap_interval,
        .high_dpi = config.window.high_dpi,
        .window_title = config.window.title.ptr,

        .alpha = false,
    });

    if (state.config.onFileDropped == null) {
        app_desc.max_dropped_files = 0;
    } else {
        app_desc.enable_dragndrop = true;
    }

    _ = sapp_run(&app_desc);
}

// Event functions
export fn init() void {
    time = Time.init();
    mem.initTmpAllocator();

    var desc = std.mem.zeroInit(sg_desc, .{ .context = sapp_sgcontext() });
    sg_setup(&desc);

    debug = Debug.init() catch unreachable;
    input = Input.init(window.scale());

    gfx.init(state.config.gfx);

    if (has_imgui) {
        var imgui_desc = std.mem.zeroes(simgui_desc_t);
        imgui_desc.no_default_font = true;
        imgui_desc.dpi_scale = sapp_dpi_scale();
        imgui_desc.ini_filename = "imgui.ini";
        simgui_setup(&imgui_desc);

        loadDefaultFont();
    }
    state.config.init();
}

fn loadDefaultFont() void {
    var io = imgui.igGetIO();
    _ = imgui.ImFontAtlas_AddFontDefault(io.Fonts, null);

    // add FontAwesome
    const font_awesome_range: [3]imgui.ImWchar = [_]imgui.ImWchar{ imgui.icons.icon_range_min, imgui.icons.icon_range_max, 0 };

    var icons_config = imgui.ImFontConfig_ImFontConfig();
    icons_config[0].MergeMode = true;
    icons_config[0].PixelSnapH = true;
    icons_config[0].FontDataOwnedByAtlas = false;

    var data = @embedFile("../assets/" ++ imgui.icons.font_icon_filename_fas);
    _ = imgui.ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, &font_awesome_range[0]);

    var w: i32 = undefined;
    var h: i32 = undefined;
    var bytes_per_pixel: i32 = undefined;
    var pixels: [*c]u8 = undefined;
    imgui.ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

    var tex = gfx.Texture.initWithData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h, .nearest);
    imgui.ImFontAtlas_SetTexID(io.Fonts, tex.imTextureID());
}

export fn update() void {
    time.tick();
    if (has_imgui) simgui_new_frame(window.width(), window.height(), 0.017);

    state.config.update();
    state.config.render();

    if (has_imgui) {
        gfx.blitToScreen(math.Color.black);
        gfx.beginPass(.{ .color_action = .SG_ACTION_DONTCARE });
        simgui_render();
        gfx.endPass();
    }

    gfx.commit();
    input.newFrame();
}

export fn event(e: [*c]const sapp_event) void {
    // special handling of dropped files
    if (e[0].type == .SAPP_EVENTTYPE_FILES_DROPPED) {
        if (state.config.onFileDropped) |onFileDropped| {
            const dropped_file_cnt = sapp_get_num_dropped_files();
            var i: usize = 0;
            while (i < dropped_file_cnt) : (i += 1) {
                onFileDropped(std.mem.spanZ(sapp_get_dropped_file_path(@intCast(c_int, i))));
            }
        }
    }

    // handle cmd+Q on macos
    if (std.Target.current.os.tag == .macos) {
        if (e[0].type == .SAPP_EVENTTYPE_KEY_DOWN) {
            if (e[0].key_code == .SAPP_KEYCODE_LEFT_SUPER) {
                state.cmd_down = true;
            } else if (state.cmd_down and e[0].key_code == .SAPP_KEYCODE_Q) {
                sapp_request_quit();
            }
        } else if (e[0].type == .SAPP_EVENTTYPE_KEY_UP and e[0].key_code == .SAPP_KEYCODE_LEFT_SUPER) {
            state.cmd_down = false;
        }
    }

    if (has_imgui and simgui_handle_event(e)) return;

    switch (e[0].type) {
        .SAPP_EVENTTYPE_RESIZED, .SAPP_EVENTTYPE_ICONIFIED, .SAPP_EVENTTYPE_RESTORED, .SAPP_EVENTTYPE_SUSPENDED, .SAPP_EVENTTYPE_RESUMED => window.handleEvent(@ptrCast(*const sapp_event, &e[0])),
        else => input.handleEvent(@ptrCast(*const sapp_event, &e[0])),
    }
}

export fn cleanup() void {
    if (state.config.shutdown) |shutdown| shutdown();
    sg_shutdown();
}

pub fn quit() void {
    sapp_request_quit();
}
