const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");
const flecs = ecs.c;

const Resources = aya.Resources;
const App = aya.App;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.print("GPA has leaks: {}\n", .{gpa.detectLeaks()});

    var app = App.init(gpa.allocator());
    defer app.deinit();

    const PreStartup = makePhase(app.world.ecs_world);
    const Startup = makePhase(app.world.ecs_world);
    const PostStartup = makePhase(app.world.ecs_world);

    const First = makePhase(app.world.ecs_world);
    const PreUpdate = makePhase(app.world.ecs_world);
    const StateTransition = makePhase(app.world.ecs_world);
    const RunFixedUpdateLoop = makePhase(app.world.ecs_world);
    const Update = makePhase(app.world.ecs_world);
    const PostUpdate = makePhase(app.world.ecs_world);
    const Last = makePhase(app.world.ecs_world);

    std.debug.print("\nFirst: {}\n", .{First});
    std.debug.print("PreUpdate: {}\n", .{PreUpdate});
    std.debug.print("StateTransition: {}\n", .{StateTransition});
    std.debug.print("RunFixedUpdateLoop: {}\n", .{RunFixedUpdateLoop});
    std.debug.print("Update: {}\n", .{Update});
    std.debug.print("PostUpdate: {}\n", .{PostUpdate});
    std.debug.print("Last: {}\n\n", .{Last});

    app.addSystem("StateTransition_0", StateTransition, run)
        .addSystem("StateTransition_1", StateTransition, run)
        .addSystem("PostUpdate_0", PostUpdate, run)
        .addSystem("StateTransition_2", StateTransition, run)
        .addSystem("First_0", First, run)
        .addSystem("Update_0", Update, run)
        .addSystem("Update_1", Update, run)
        .addSystem("PreUpdate_0", PreUpdate, run)
        .addSystem("PreUpdate_1", PreUpdate, run)
        .addSystem("Last_0", Last, run)
        .addSystem("RunFixedUpdateLoop_0", RunFixedUpdateLoop, run)
        .addSystem("PostUpdate_1", PostUpdate, run)
        .addSystem("Last_2", Last, run)
        .addSystemAfter("Last_1", Last, run, "Last_0")
        .addSystemBefore("Last_-1", Last, run, "Last_0")
        .addSystem("PostStartup", PostStartup, run)
        .addSystem("PreStartup_0", PreStartup, run)
        .addSystem("Startup", Startup, run)
        .addSystem("PreStartup_3", PreStartup, run)
        .addSystemAfter("PreStartup_1", PreStartup, run, "PreStartup_0")
        .addSystemAfter("PreStartup_2", PreStartup, run, "PreStartup_1")
        .addSystemAfter("PreStartup_2b", PreStartup, run, "PreStartup_1")
        .addSystemBefore("PreStartup_2a", PreStartup, run, "PreStartup_2b")
        .run();

    // disables an entire phase
    // flecs.ecs_enable(app.world.ecs, StateTransition, false);

    // run the startup pipeline then core pipeline
    runStartupPipeline(app.world.ecs_world, PreStartup, Startup, PostStartup);
    setCorePipeline(app.world.ecs_world);

    std.debug.print("---------\n", .{});
    app.world.ecs_world.progress(0);
}

fn run(it: [*c]flecs.ecs_iter_t) callconv(.C) void {
    std.debug.print("------------ system: {s}\n", .{flecs.ecs_get_name(it.*.world, it.*.system)});
    if (!flecs.ecs_iter_next(it)) return;
}

fn makePhase(world: ecs.EcsWorld) u64 {
    return flecs.ecs_new_w_id(world.world, flecs.EcsPhase);
}

fn pipelineSystemSortCompare(e1: u64, ptr1: ?*const anyopaque, e2: u64, ptr2: ?*const anyopaque) callconv(.C) c_int {
    const sort1 = @as(*const ecs.SystemSort, @ptrCast(@alignCast(ptr1)));
    const sort2 = @as(*const ecs.SystemSort, @ptrCast(@alignCast(ptr2)));

    const phase_1: c_int = if (sort1.phase > sort2.phase) 1 else 0;
    const phase_2: c_int = if (sort1.phase < sort2.phase) 1 else 0;

    // sort by: phase, order_in_phase then entity_id
    if (sort1.phase == sort2.phase) {
        // std.debug.print("SAME PHASE. order: {} vs {}, entity: {}, {}\n", .{ sort1.order_in_phase, sort2.order_in_phase, e1, e2 });
        const order_1: c_int = if (sort1.order_in_phase > sort2.order_in_phase) 1 else 0;
        const order_2: c_int = if (sort1.order_in_phase < sort2.order_in_phase) 1 else 0;

        const order_in_phase = order_1 - order_2;
        if (order_in_phase != 0) return order_in_phase;

        const first: c_int = if (e1 > e2) 1 else 0;
        const second: c_int = if (e1 < e2) 1 else 0;

        return first - second;
    }

    return phase_1 - phase_2;
}

fn runStartupPipeline(world: ecs.EcsWorld, pre_startup: u64, startup: u64, post_startup: u64) void {
    var pip_desc = std.mem.zeroes(flecs.ecs_pipeline_desc_t);
    pip_desc.entity = flecs.ecs_entity_init(world.world, &std.mem.zeroInit(flecs.ecs_entity_desc_t, .{ .name = "StartupPipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = ecs.COMPONENT(world.world, ecs.SystemSort);

    pip_desc.query.filter.terms[0].id = flecs.EcsSystem;
    pip_desc.query.filter.terms[1] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = pre_startup,
        .oper = flecs.EcsOr,
    });
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = startup,
        .oper = flecs.EcsOr,
    });
    pip_desc.query.filter.terms[3].id = post_startup;
    pip_desc.query.filter.terms[4] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = ecs.COMPONENT(world.world, ecs.SystemSort),
        .inout = flecs.EcsIn,
    });

    const startup_pipeline = flecs.ecs_pipeline_init(world.world, &pip_desc);
    flecs.ecs_set_pipeline(world.world, startup_pipeline);
    _ = flecs.ecs_progress(world.world, 0);

    flecs.ecs_delete_with(world.world, pre_startup);
    flecs.ecs_delete_with(world.world, startup);
    flecs.ecs_delete_with(world.world, post_startup);
}

fn setCorePipeline(world: ecs.EcsWorld) void {
    var pip_desc = std.mem.zeroes(flecs.ecs_pipeline_desc_t);
    pip_desc.entity = flecs.ecs_entity_init(world.world, &std.mem.zeroInit(flecs.ecs_entity_desc_t, .{ .name = "CustomPipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = ecs.COMPONENT(world.world, ecs.SystemSort);
    pip_desc.query.filter.terms[0].id = flecs.EcsSystem;
    pip_desc.query.filter.terms[1].id = ecs.COMPONENT(world.world, ecs.SystemSort);
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = flecs.EcsDisabled,
        .src = std.mem.zeroInit(flecs.ecs_term_id_t, .{
            .flags = flecs.EcsUp,
            .trav = flecs.EcsDependsOn,
        }),
        .oper = flecs.EcsNot,
    });
    pip_desc.query.filter.terms[3] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = flecs.EcsDisabled,
        .src = std.mem.zeroInit(flecs.ecs_term_id_t, .{
            .flags = flecs.EcsUp,
            .trav = flecs.EcsChildOf,
        }),
        .oper = flecs.EcsNot,
    });

    const pipeline = flecs.ecs_pipeline_init(world.world, &pip_desc);
    flecs.ecs_set_pipeline(world.world, pipeline);
}