const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");

const App = aya.App;
const World = aya.World;
const Commands = aya.Commands;
const Local = aya.Local;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addSystem(.update, StartupSystem)
        .run();
}

const StartupSystem = struct {
    pub fn run(commands: Commands, other_system: Local(u64)) void {
        var local = other_system.get();
        if (local.* == 0) {
            local.* = commands.registerSystem(PrintSystem);
        } else {
            commands.runSystem(local.*);
        }
    }
};

const PrintSystem = struct {
    pub fn run() void {
        std.debug.print("-- PrintSystem\n", .{});
    }
};
