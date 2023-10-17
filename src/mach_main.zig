// Check that the user's app matches the required interface.
comptime {
    if (!@import("builtin").is_test) AppInterface(@import("app"));
}

// Forward "app" declarations into our namespace, such that @import("root").foo works as expected.
pub usingnamespace @import("app");
const Bootstrap = @import("app").Bootstrap;

const std = @import("std");
const core = @import("mach-core");

// copy of mach entrypoint with one change:
// App changed to Bootstrap

pub usingnamespace if (!@hasDecl(Bootstrap, "GPUInterface")) struct {
    pub const GPUInterface = core.wgpu.dawn.Interface;
} else struct {};

pub usingnamespace if (!@hasDecl(Bootstrap, "DGPUInterface")) extern struct {
    pub const DGPUInterface = core.dusk.Impl;
} else struct {};

pub fn main() !void {
    // Run from the directory where the executable is located so relative assets can be found.
    var buffer: [1024]u8 = undefined;
    const path = std.fs.selfExeDirPath(buffer[0..]) catch ".";
    std.os.chdir(path) catch {};

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    core.allocator = gpa.allocator();

    // Initialize GPU implementation
    if (comptime core.options.use_wgpu) try core.wgpu.Impl.init(core.allocator, .{});
    if (comptime core.options.use_dgpu) try core.dusk.Impl.init(core.allocator, .{});

    var app: Bootstrap = undefined;
    try app.init();
    defer app.deinit();
    while (!try core.update(&app)) {}
}

fn ErrorSet(comptime F: type) type {
    return @typeInfo(@typeInfo(F).Fn.return_type.?).ErrorUnion.error_set;
}

fn AppInterface(comptime app_entry: anytype) void {
    if (!@hasDecl(app_entry, "Bootstrap")) {
        @compileError("expected e.g. `pub const Bootstrap = aya.Bootstrap;' (App definition missing in your main Zig file)");
    }

    if (@hasDecl(app_entry, "run")) {
        const RunFn = @TypeOf(@field(app_entry, "run"));
        if (RunFn != fn (*@import("aya").App) void)
            @compileError("expected 'pub fn run(*aya.App) void' found '" ++ @typeName(RunFn) ++ "'");
    } else {
        @compileError("Root must export 'pub fn run() void'");
    }

    const AppBootstrap = app_entry.Bootstrap;
    if (@typeInfo(Bootstrap) != .Struct) {
        @compileError("Bootstrap must be a struct type. Found:" ++ @typeName(Bootstrap));
    }

    if (@hasDecl(Bootstrap, "init")) {
        const InitFn = @TypeOf(@field(AppBootstrap, "init"));
        if (InitFn != fn (app: *AppBootstrap) ErrorSet(InitFn)!void)
            @compileError("expected 'pub fn init(app: *Bootstrap) !void' found '" ++ @typeName(InitFn) ++ "'");
    } else {
        @compileError("Bootstrap must export 'pub fn init(app: *Bootstrap) !void'");
    }

    if (@hasDecl(AppBootstrap, "update")) {
        const UpdateFn = @TypeOf(@field(AppBootstrap, "update"));
        if (UpdateFn != fn (app: *AppBootstrap) ErrorSet(UpdateFn)!bool)
            @compileError("expected 'pub fn update(app: *Bootstrap) !bool' found '" ++ @typeName(UpdateFn) ++ "'");
    } else {
        @compileError("App must export 'pub fn update(app: *Bootstrap) !bool'");
    }

    if (@hasDecl(AppBootstrap, "updateMainThread")) {
        const UpdateMainThreadFn = @TypeOf(@field(AppBootstrap, "updateMainThread"));
        if (UpdateMainThreadFn != fn (app: *AppBootstrap) ErrorSet(UpdateMainThreadFn)!bool)
            @compileError("expected 'pub fn updateMainThread(app: *Bootstrap) !bool' found '" ++ @typeName(UpdateMainThreadFn) ++ "'");
    }

    if (@hasDecl(AppBootstrap, "deinit")) {
        const DeinitFn = @TypeOf(@field(AppBootstrap, "deinit"));
        if (DeinitFn != fn (app: *AppBootstrap) void)
            @compileError("expected 'pub fn deinit(app: *App) void' found '" ++ @typeName(DeinitFn) ++ "'");
    } else {
        @compileError("App must export 'pub fn deinit(app: *App) void'");
    }
}
