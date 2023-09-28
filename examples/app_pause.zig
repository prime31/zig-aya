const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Commands = aya.Commands;

fn runFn(app: *App) void {
    std.debug.print("\n----- ----- progress\n", .{});
    app.world.ecs.progress(0);
    std.debug.print("\n----- ----- progress\n", .{});
    app.world.ecs.progress(0);
    std.debug.print("\n----- ----- progress\n", .{});
    app.world.ecs.progress(0);
}

pub fn main() !void {
    App.init()
        .setRunner(runFn)
        .addSystem(.startup, StartupSystem)
        .addSystem(.update, RunWhenPausedSystem)
        .addSystem(.update, DontRunWhenPausedSystem)
        .run();
}

const StartupSystem = struct {
    pub fn run() void {
        std.debug.print("\n-- StartupSystem called \n", .{});
    }
};

const RunWhenPausedSystem = struct {
    pub var run_when_paused = true;

    pub fn run(commands: Commands, ticks: aya.Local(u8)) void {
        std.debug.print("-- RunWhenPausedSystem called\n", .{});

        if (ticks.get().* == 0)
            commands.pause(true);
        if (ticks.get().* == 2)
            commands.pause(false);

        ticks.get().* = ticks.get().* + 1;
    }
};

const DontRunWhenPausedSystem = struct {
    pub fn run() void {
        std.debug.print("-- DontRunWhenPausedSystem called\n", .{});
    }
};
