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
        .addSystem(.startup, StartupSystem)
        .run();
}

const StartupSystem = struct {
    pub fn run(commands: Commands, other_system: Local(u64)) void {
        std.debug.print("-- StartupSystem\n", .{});
        if (other_system.get().* == 0) {
            other_system.get().* = commands.registerSystem(PrintSystem);
        } else {
            commands.runSystem(other_system.get().*);
        }
    }
};

const PrintSystem = struct {
    pub fn run() void {
        std.debug.print("-- PrintSystem\n", .{});
    }
};
