const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");
const flecs = ecs.c;
const phases = aya.phases;

const Resources = aya.Resources;
const App = aya.App;
const World = aya.World;
const Iterator = ecs.Iterator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.print("GPA has leaks: {}\n", .{gpa.detectLeaks()});

    // var app = App.init(gpa.allocator());
    // defer app.deinit();

    App.init(gpa.allocator())
        .addSystem(phases.first, printDeltaTime)
        .addSystem(phases.post_update, WorldAndVelocitySystem.run)
    // .addSystem(phases.first, EmptySystem.printSystem)
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

    std.debug.print("--------- fini -------\n", .{});
    // _ = flecs.ecs_progress(app.world.ecs, 0);
}

pub const Velocity = struct { x: f32 = 0, y: f32 = 0 };

const EmptyCallback = struct {
    pub const run = printDeltaTime;
};

fn printDeltaTime(iter: *Iterator(EmptyCallback)) void {
    std.debug.print("\ndelta_time: {d}\n", .{iter.iter.delta_time});
    _ = iter.world().newEntity().set(Velocity{ .x = 6 });
    _ = iter.world().newEntity().set(Velocity{});
    while (iter.next()) |_| {}
}

const EmptySystem = struct {
    pub const run = printDeltaTime;

    fn printSystem() void {
        std.debug.print("empty system called\n", .{});
    }
};

const WorldSystem = struct {
    pub const run = printDeltaTime;

    fn printWorld(world: *World) void {
        std.debug.print("\nworld system called with world: {*}\n", .{world});
    }
};

const WorldAndVelocitySystem = struct {
    vel: *Velocity,

    // pub const run = runner;

    fn run(world: *World, iter: *Iterator(WorldAndVelocitySystem)) void {
        std.debug.print("----------------- holy fucking fuck. world: {*}, ecs_world: {}\n", .{ world, iter.world() });
        while (iter.next()) |comps| {
            std.debug.print("--- WorldAndVelocitySystem called: {}\n", .{comps.vel});
        }
    }
};

const SystemCallbackType = struct {
    vel: *Velocity,

    pub const run = printer;

    fn printer(iter: *Iterator(SystemCallbackType)) void {
        // std.debug.print("\n--- printer called: {d}\n", .{iter});
        while (iter.next()) |comps| {
            std.debug.print("--- printer called: {}\n", .{comps.vel});
        }
    }
};
