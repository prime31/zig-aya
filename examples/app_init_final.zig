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
        .addSystem(phases.first, WorldAndVelocitySystem.run)
        .addSystem(phases.first, EmptyCallback.run).before(WorldAndVelocitySystem.run)
        .addSystem(phases.first, EmptySystem.run).after(EmptyCallback.run)

    // .addSystem(phases.startup, WorldSystem.printWorld)
    // .addSystem(phases.last, SystemCallbackType.printer)
    // .addSystem("StateTransition_0", phases.state_transition, run)
    // .addSystem("StateTransition_1", phases.state_transition, run)
    // .addSystem("PostUpdate_0", phases.post_update, run)
    // .addSystem("StateTransition_2", phases.state_transition, run)
    // .addSystem("First_0", phases.first, run)
    // .addSystem("Update_0", phases.update, run)
    // .addSystem("Update_1", phases.update, run)
    // .addSystem("PreUpdate_0", phases.pre_update, run)
    // .addSystem("PreUpdate_1", phases.pre_update, run)
    // .addSystem("Last_0", phases.last, run)
    // .addSystem("RunFixedUpdateLoop_0", phases.run_fixed_update_loop, run)
    // .addSystem("PostUpdate_1", phases.post_update, run)
    // .addSystem("Last_2", phases.last, run)
    // .addSystemAfter("Last_1", phases.last, run, "Last_0")
    // .addSystemBefore("Last_-1", phases.last, run, "Last_0")
    // .addSystem("PostStartup", phases.post_startup, run)
    // .addSystem("PreStartup_0", phases.pre_startup, run)
    // .addSystem("Startup", phases.startup, run)
    // .addSystem("PreStartup_3", phases.pre_startup, run)
    // .addSystemAfter("PreStartup_1", phases.pre_startup, run, "PreStartup_0")
    // .addSystemAfter("PreStartup_2", phases.pre_startup, run, "PreStartup_1")
    // .addSystemAfter("PreStartup_2b", phases.pre_startup, run, "PreStartup_1")
    // .addSystemBefore("PreStartup_2a", phases.pre_startup, run, "PreStartup_2b")
        .run();

    // disables an entire phase
    // flecs.ecs_enable(app.world.ecs, StateTransition, false);

    // run the startup pipeline then core pipeline
    // runStartupPipeline(app.world.ecs_world, phases.pre_startup, phases.startup, phases.post_startup);
    // setCorePipeline(app.world.ecs_world);
    // _ = flecs.ecs_progress(app.world.ecs, 0);
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
        std.debug.print("-- EmptySystem called res: {}, res_mut: {}\n", .{ res, res_mut });
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
        std.debug.print("-- SystemCallbackType called: {d}\n", .{iter});
        while (iter.next()) |_| {}
    }
};
