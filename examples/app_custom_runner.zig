const std = @import("std");
const aya = @import("aya");

const Resources = aya.Resources;
const App = aya.App;
const World = aya.World;
const Iterator = aya.Iterator;

fn runFn(app: *App) void {
    std.debug.print("----- running system schedule\n", .{});
    app.world.ecs.progress(0);
    std.debug.print("----- running system schedule again\n", .{});
    app.world.ecs.progress(0);
}

pub fn main() !void {
    App.init()
        .setRunner(runFn)
        .addSystem(.startup, StartupSystem)
        .addSystem(.pre_update, EmptySystem)
        .addSystem(.update, OtherSystem)
        .run();
}

const StartupSystem = struct {
    pub fn run() void {
        std.debug.print("\n-- StartupSystem called \n", .{});
    }
};

const EmptySystem = struct {
    pub fn run() void {
        std.debug.print("-- EmptySystem called \n", .{});
    }
};

const OtherSystem = struct {
    pub fn run() void {
        std.debug.print("-- OtherSystem called\n", .{});
    }
};
