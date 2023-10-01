const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Commands = aya.Commands;

fn runFn(app: *App) void {
    app.world.ecs.setTargetFps(10);

    var i: u8 = 0;
    while (i < 20) : (i += 1) {
        std.debug.print("----- ----- progress\n", .{});
        app.world.ecs.progress(0);
    }
}

pub fn main() !void {
    App.init()
        .setRunner(runFn)
        .addSystems(aya.Update, RunFast)
        .addSystems(aya.Update, RunSlow)
        .run();
}

const RunFast = struct {
    pub const interval = 0.2;

    pub fn run() void {
        std.debug.print("-- RunFast called\n", .{});
    }
};

const RunSlow = struct {
    pub const interval = 0.4;

    pub fn run() void {
        std.debug.print("-- RunSlow called\n", .{});
    }
};
