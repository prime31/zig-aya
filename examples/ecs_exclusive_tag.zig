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

        // iterate all targets of the pair. Since the Mother tag is exclusive there should only be one even though we added two
        while (entity.nextTargetOfPair(Mother)) |target| {
            std.debug.print("------- target of Mother pair: {} ({s})\n", .{ target, commands.ecs.getEntity(target).getName() });
        }
    }
};
