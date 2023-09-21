const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");
const flecs = ecs.c;
const phases = aya.phases;

const Resources = aya.Resources;
const App = aya.App;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.print("GPA has leaks: {}\n", .{gpa.detectLeaks()});

    var app = App.init(gpa.allocator());
    defer app.deinit();

    app.addSystems(phases.first, printDeltaTime)
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

    std.debug.print("---------\n", .{});
    _ = flecs.ecs_progress(app.world.ecs, 0);
}

const EmptyCallback = struct {
    pub const run = printDeltaTime;
};

fn printDeltaTime(iter: *ecs.Iterator(EmptyCallback)) void {
    std.log.debug("delta_time: {d}", .{iter.iter.delta_time});
    while (iter.next()) |_| {}
}

fn run(it: [*c]flecs.ecs_iter_t) callconv(.C) void {
    // std.debug.print("------------ system: {s}\n", .{flecs.ecs_get_name(it.*.world, it.*.system)});
    if (!flecs.ecs_iter_next(it)) return;
}
