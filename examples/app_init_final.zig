const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");
const phases = aya.phases;

const Resources = aya.Resources;
const App = aya.App;
const World = aya.World;
const Iterator = ecs.Iterator;

pub const Resource = struct { num: u64 };

const SuperState = enum {
    start,
    middle,
    end,
};

const ChangeStateSystem = struct {
    vel: ?*const Velocity,

    pub fn run(world: *World, state: aya.ResMut(aya.NextState(SuperState)), iter: *Iterator(ChangeStateSystem)) void {
        _ = world;
        std.debug.print("-- ChangeStateSystem called with count: {d}, state: {}\n", .{ iter.iter.count, state.get().?.state });
        while (iter.next()) |_| {}
        state.get().?.set(iter.world(), .middle);
    }
};

pub fn main() !void {
    App.init()
        .addState(SuperState, .start)
        .insertPlugin(PhysicsPlugin{ .data = 66 })
        .insertResource(Resource{ .num = 666 })
        .addObserver(.on_set, VelocityObserver.run)
        .addSystem(phases.startup, EmptyCallback)
        .addSystem(phases.first, WorldAndVelocitySystem)
        .addSystem(phases.first, ChangeStateSystem)
        .addSystem(phases.pre_update, EmptySystem).inState(SuperState, .middle)
        .addSystem(phases.pre_update, OtherSystem).inState(SuperState, .start)
        .addSystem(phases.pre_update, WorldSystem).before(EmptySystem)
        .addSystem(phases.update, SystemCallbackType)
        .run();

    // disables an entire phase
    // flecs.ecs_enable(app.world.ecs, phases.first, false);
}

pub const Position = struct { x: f32 = 0, y: f32 = 0 };
pub const Velocity = struct { x: f32 = 0, y: f32 = 0 };

const EmptyCallback = struct {
    pub fn run(iter: *Iterator(EmptyCallback)) void {
        while (iter.next()) |_| {}

        std.debug.print("\n-- EmptyCallback. delta_time: {d}\n", .{iter.iter.delta_time});
        iter.world().newEntity().set(Velocity{ .x = 6 });

        const entity = iter.world().newEntity();
        entity.set(Velocity{ .x = 7 });
        entity.set(Position{ .x = 8 });
    }
};

const EmptySystem = struct {
    pub fn run(res: aya.Res(Velocity), res_mut: aya.ResMut(Resource)) void {
        std.debug.print("-- EmptySystem called res: {?}, res_mut: {?}\n", .{ res.resource, res_mut.resource });
    }
};

const OtherSystem = struct {
    pub fn run() void {
        std.debug.print("-- OtherSystem\n", .{});
    }
};

const WorldSystem = struct {
    pub fn run(world: *World) void {
        std.debug.print("-- WorldSystem called with world: {*}\n", .{world});
    }
};

const WorldAndVelocitySystem = struct {
    vel: *Velocity,

    pub fn run(world: *World, iter: *Iterator(WorldAndVelocitySystem)) void {
        std.debug.print("-- WorldAndVelocitySystem. world: {*}, ecs_world: {}\n", .{ world, iter.world() });
        while (iter.next()) |_| {}
    }
};

const SystemCallbackType = struct {
    vel: *Velocity,
    pos: ?*const Position,

    pub fn run(iter: *Iterator(SystemCallbackType)) void {
        std.debug.print("-- SystemCallbackType called. total results: {d}\n", .{iter.*.iter.count});

        // iteration can also be via table
        while (iter.nextTable()) |table| {
            for (table.columns.vel, 0..) |v, i| {
                const pos = if (table.columns.pos) |p| p[i] else null;
                std.debug.print("-- ++ v: {}, pos: {?}\n", .{ v, pos });
            }
        }
    }
};

const VelocityObserver = struct {
    vel: *const Velocity,
    pos: *const Position,

    pub fn run(iter: *Iterator(VelocityObserver)) void {
        // std.debug.print("-- ++ VelocityObserver\n", .{});
        while (iter.next()) |comps| {
            std.debug.print("-- v: {}, p: {}\n", .{ comps.vel, comps.pos });
        }
    }
};

const PhysicsPlugin = struct {
    data: u8 = 250,

    pub fn build(self: PhysicsPlugin, app: *App) void {
        _ = app.addSystem(phases.last, PhysicsSystem);
        std.debug.print("--- PhysicsPlugins.build called. data: {}\n", .{self.data});
    }
};

const PhysicsSystem = struct {
    pub fn run(iter: *Iterator(PhysicsSystem)) void {
        std.debug.print("-- ++ PhysicsSystem\n", .{});
        while (iter.next()) |_| {}
    }
};
