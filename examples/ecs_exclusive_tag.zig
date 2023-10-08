const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Commands = aya.Commands;

const Mother = struct {
    pub const exclusive = true;
};
const Janet = struct {};
const Helen = struct {};

pub fn main() !void {
    App.init()
        .addSystems(aya.Startup, StartupSystem)
        .addSystems(aya.Update, UpdateSystem)
        .run();
}

const StartupSystem = struct {
    pub fn run(commands: aya.Commands) void {
        std.debug.print("\n-- StartupSystem called\n", .{});

        _ = commands.spawnWith("TagHolder", .{ .{ Mother, Helen }, .{ Mother, Janet } });
    }
};

const UpdateSystem = struct {
    pub fn run(commands: aya.Commands) void {
        std.debug.print("-- UpdateSystem called\n", .{});

        const entity = commands.ecs.lookup("TagHolder").?;
        std.debug.print("----- has Mother: {any}\n", .{entity.hasPair(Mother, aya.c.EcsWildcard)});
        std.debug.print("target of Mother pair: {} ({s})\n", .{ entity.getTargetOfPair(Mother, 0), commands.ecs.getEntity(entity.getTargetOfPair(Mother, 0)).getName() });
    }
};
