const std = @import("std");
const stb = @import("stb");

pub const sdl = @import("sdl");
pub const wgpu = @import("wgpu");

pub usingnamespace @import("graphics_context.zig");
pub const gpu = @import("gpu.zig");

// exports for easy access
pub var gctx: *GraphicsContext = undefined;
pub const mem = @import("mem/mem.zig");
pub const window = @import("window.zig");

const WindowConfig = @import("window.zig").WindowConfig;
const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const Config = struct {
    init: ?fn () anyerror!void = null,
    update: ?fn () anyerror!void = null,
    render: ?fn () anyerror!void = null,
    shutdown: ?fn () anyerror!void = null,

    window: WindowConfig = .{},
};

fn init(comptime config: Config) !void {
    mem.init();
    window.init(config.window);
    gctx = try GraphicsContext.init(mem.allocator);
}

fn deinit() void {
    window.deinit();
    gctx.deinit(mem.allocator);
    mem.deinit(); // must be last so everyone else can deinit!
}

pub fn run(comptime config: Config) !void {
    try init(config);

    if (config.init) |initFn| try initFn();

    while (!pollEvents()) {
        if (config.update) |update| try update();
        if (config.render) |render| try render();
    }
    if (config.shutdown) |shutdown| try shutdown();

    deinit();
}

fn pollEvents() bool {
    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            sdl.SDL_EVENT_QUIT => return true,
            else => {},
        }
    }

    return false;
}
