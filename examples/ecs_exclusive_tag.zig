const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Commands = aya.Commands;

const Mother = struct {
    pub const exclusive = true;
};
const Janet = struct {};
const Helen = struct {};

const VecBundle = struct {
    pub const is_bundle = true;

    vec2: Vec2 = .{},
    vec3: Vec3 = .{},
};
const Vec2 = struct { x: f32 = 2 };
const Vec3 = struct { x: f32 = 5 };

pub fn main() !void {
    App.init()
        .addSystems(aya.Startup, StartupSystem)
        .addSystems(aya.Update, UpdateSystem)
        .run();
}

const StartupSystem = struct {
    pub fn run(commands: aya.Commands) void {
        std.debug.print("\n-- StartupSystem called\n", .{});

        // Mother is exclusive so only the last added pair will be on the entity
        _ = commands.spawnWith("TagHolder", .{ .{ Mother, Helen }, .{ Mother, Janet }, VecBundle, Vec2{}, VecBundle{} });
        _ = commands.spawnWithBundle("TagHolder2", VecBundle);
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
