const std = @import("std");
const aya = @import("aya");

const Resources = aya.Resources;
const App = aya.App;
const World = aya.World;
const Iterator = aya.Iterator;
const NextState = aya.NextState;
const ResMut = aya.ResMut;

pub const Resource = struct { num: u64 };

const SuperEvent = struct {};

const SuperState = enum {
    start,
    middle,
    end,
};

const ChangeStateSystem = struct {
    vel: ?*const Velocity,

    pub fn run(state: ResMut(NextState(SuperState)), iter: *Iterator(ChangeStateSystem)) void {
        std.debug.print("-- ChangeStateSystem called with state: {}. Changing to .middle\n", .{state.get().?.state});
        while (iter.next()) |_| {}
        state.get().?.set(iter.commands(), .middle);
    }
};

pub fn main() !void {
    App.init()
        .addState(SuperState, .start)
        .addEvent(SuperEvent)
        .addPlugins(PhysicsPlugin{ .data = 66 })
        .insertResource(Resource{ .num = 666 })
        .addObserver(.on_set, VelocityObserver.run)
        .addSystems(aya.Startup, EmptyCallback)
        .addSystems(aya.First, .{ WorldAndVelocitySystem, ChangeStateSystem })
        .addSystems(aya.PreUpdate, MiddleStateSystem).inState(SuperState.middle)
        .addSystems(aya.PreUpdate, StartStateSystem).inState(SuperState.start)
        .addSystems(aya.PreUpdate, WorldSystem).before(MiddleStateSystem)
        .addSystems(aya.Update, SystemCallbackType)
        .run();

    // disables an entire phase
    // flecs.ecs_enable(app.world.ecs, .first, false);
}

pub const Position = struct { x: f32 = 0, y: f32 = 0 };
pub const Velocity = struct { x: f32 = 0, y: f32 = 0 };

const EmptyCallback = struct {
    pub fn run(iter: *Iterator(EmptyCallback)) void {
        while (iter.next()) |_| {}

        std.debug.print("\n-- EmptyCallback. delta_time: {d}\n", .{iter.iter.delta_time});
        iter.commands().newEntity().set(Velocity{ .x = 6 });

        const entity = iter.commands().newEntity();
        entity.set(Velocity{ .x = 7 });
        entity.set(Position{ .x = 8 });
    }
};

const MiddleStateSystem = struct {
    pub fn run(res: aya.Res(Velocity), res_mut: aya.ResMut(Resource)) void {
        std.debug.print("-- MiddleStateSystem called res: {?}, res_mut: {?}\n", .{ res.resource, res_mut.resource });
    }
};

const StartStateSystem = struct {
    pub fn run() void {
        std.debug.print("-- StartStateSystem\n", .{});
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
        std.debug.print("-- WorldAndVelocitySystem. world: {*}\n", .{world});
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
        _ = app.addSystems(aya.Last, PhysicsSystem);
        std.debug.print("--- PhysicsPlugins.build called. data: {}\n", .{self.data});
    }
};

const PhysicsSystem = struct {
    pub fn run(iter: *Iterator(PhysicsSystem)) void {
        std.debug.print("-- ++ PhysicsSystem\n", .{});
        while (iter.next()) |_| {}
    }
};
