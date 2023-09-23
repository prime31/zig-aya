const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");
const flecs = ecs.c;
const phases = aya.phases;

const Resources = aya.Resources;
const App = aya.App;
const World = aya.World;
const Iterator = ecs.Iterator;

pub const Resource = struct { num: u64 };

pub fn main() !void {
    App.init()
        .insertResource(Resource{ .num = 666 })
        .addObserver(.on_add, VelocityObserver.run)
        .addSystem(phases.first, WorldAndVelocitySystem.run)
        .addSystem(phases.first, EmptyCallback.run).before(WorldAndVelocitySystem.run)
        .addSystem(phases.last, EmptySystem.run)
        .addSystem(phases.last, WorldSystem.run)
        .addSystem(phases.last, SystemCallbackType.run)
        .run();

    // disables an entire phase
    // flecs.ecs_enable(app.world.ecs, phases.first, false);
}

pub const Velocity = struct { x: f32 = 0, y: f32 = 0 };

const EmptyCallback = struct {
    fn run(iter: *Iterator(EmptyCallback)) void {
        std.debug.print("\n-- EmptyCallback. delta_time: {d}\n", .{iter.iter.delta_time});
        _ = iter.world().newEntity().set(Velocity{ .x = 6 });
        _ = iter.world().newEntity().set(Velocity{});
        while (iter.next()) |_| {}
    }
};

const EmptySystem = struct {
    fn run(res: aya.Res(Velocity), res_mut: aya.ResMut(Resource)) void {
        std.debug.print("-- EmptySystem called res: {?}, res_mut: {?}\n", .{ res.resource, res_mut.resource });
    }
};

const WorldSystem = struct {
    fn run(world: *World) void {
        std.debug.print("-- WorldSystem called with world: {*}\n", .{world});
    }
};

const WorldAndVelocitySystem = struct {
    vel: *Velocity,

    fn run(world: *World, iter: *Iterator(WorldAndVelocitySystem)) void {
        std.debug.print("-- WorldAndVelocitySystem. world: {*}, ecs_world: {}\n", .{ world, iter.world() });
        while (iter.next()) |_| {}
    }
};

const SystemCallbackType = struct {
    vel: *Velocity,

    fn run(iter: *Iterator(SystemCallbackType)) void {
        std.debug.print("-- SystemCallbackType called. total results: {d}\n", .{iter.*.iter.count});
        while (iter.next()) |_| {}
    }
};

const VelocityObserver = struct {
    vel: *const Velocity,

    fn run(iter: *Iterator(VelocityObserver)) void {
        std.debug.print("-- ++ VelocityObserver.ecs_world: {}\n", .{iter.world()});
        while (iter.next()) |_| {}
    }
};
