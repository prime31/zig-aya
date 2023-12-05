const std = @import("std");
const aya = @This();

// libs
pub const sdl = @import("sdl");
pub const wgpu = @import("wgpu");
pub const stb = @import("stb");
pub const ig = @import("imgui");

pub usingnamespace @import("graphics_context.zig");
pub const gpu = @import("gpu.zig"); // TODO: this is almost empty now

// types
const WindowConfig = @import("window.zig").WindowConfig;
const Debug = @import("render/debug.zig").Debug;
// const GraphicsConfig = @import("graphics_context.zig").GraphicsConfig;
// const Resources = @import("resources.zig").Resources;

// exports for easy access
pub const fs = @import("fs.zig");
pub const math = @import("math/mod.zig");
pub const mem = @import("mem/mem.zig");
pub const render = @import("render/mod.zig");
pub const window = @import("window.zig");

// essentially our fields, just made globals for ease of access
pub var debug: Debug = undefined;
pub var gctx: *aya.GraphicsContext = undefined;
// pub var res: Resources = undefined;

pub const Config = struct {
    init: ?fn () anyerror!void = null,
    update: ?fn () anyerror!void = null,
    render: ?fn () anyerror!void = null,
    shutdown: ?fn () anyerror!void = null,

    // gfx: GraphicsConfig = .{},
    window: WindowConfig = .{},
};

fn init(comptime config: Config) !void {
    mem.init();
    window.init(config.window);
    debug = Debug.init();
    gctx = try aya.GraphicsContext.init();
}

fn deinit() void {
    window.deinit();
    debug.deinit();
    gctx.deinit();
    mem.deinit(); // must be last so everyone else can deinit!
}

pub fn run(comptime config: Config) !void {
    try init(config);
    ig.sdl.init(window.sdl_window, gctx.device, @intFromEnum(aya.GraphicsContext.swapchain_format), @intFromEnum(wgpu.TextureFormat.undefined));

    if (config.init) |initFn| try initFn();

    while (!pollEvents()) {
        ig.sdl.newFrame();
        ig.igShowDemoWindow(null);

        if (config.update) |update| try update();
        if (config.render) |rend| try rend();
        // ig.sdl.draw(gctx); // TODO: handle setting up the command encode and swapchain before render
    }
    if (config.shutdown) |shutdown| try shutdown();

    ig.sdl.shutdown();
    deinit();
}

fn pollEvents() bool {
    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) != 0) {
        if (ig.sdl.handleEvent(&event)) continue;

        switch (event.type) {
            sdl.SDL_EVENT_QUIT => return true,
            else => {},
        }
    }

    return false;
}
