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

    const PreStartup = makePhase(app.world.ecs);
    const Startup = makePhase(app.world.ecs);
    const PostStartup = makePhase(app.world.ecs);

    const First = makePhase(app.world.ecs);
    const PreUpdate = makePhase(app.world.ecs);
    const StateTransition = makePhase(app.world.ecs);
    const RunFixedUpdateLoop = makePhase(app.world.ecs);
    const Update = makePhase(app.world.ecs);
    const PostUpdate = makePhase(app.world.ecs);
    const Last = makePhase(app.world.ecs);

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
        .addSystemAfter("Last_2", Last, run, "Last_0")
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

    // run the startup pipeline then core pipeline
    runStartupPipeline(app.world.ecs, PreStartup, Startup, PostStartup);
    setCorePipeline(app.world.ecs);

    std.debug.print("---------\n", .{});
    _ = ecs.c.ecs_progress(app.world.ecs, 0);
}

fn run(it: [*c]ecs.c.ecs_iter_t) callconv(.C) void {
    std.debug.print("------------ system: {s}\n", .{ecs.c.ecs_get_name(it.*.world, it.*.system)});
    if (!ecs.c.ecs_iter_next(it)) return;
}

fn makePhase(world: *ecs.c.ecs_world_t) u64 {
    return ecs.c.ecs_new_w_id(world, ecs.c.EcsPhase);
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

fn runStartupPipeline(world: *ecs.c.ecs_world_t, pre_startup: u64, startup: u64, post_startup: u64) void {
    var pip_desc = std.mem.zeroes(ecs.c.ecs_pipeline_desc_t);
    pip_desc.entity = ecs.c.ecs_entity_init(world, &std.mem.zeroInit(ecs.c.ecs_entity_desc_t, .{ .name = "StartupPipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = ecs.COMPONENT(world, ecs.SystemSort);

    pip_desc.query.filter.terms[0].id = ecs.c.EcsSystem;
    pip_desc.query.filter.terms[1] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = pre_startup,
        .oper = ecs.c.EcsOr,
    });
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = startup,
        .oper = ecs.c.EcsOr,
    });
    pip_desc.query.filter.terms[3].id = post_startup;
    pip_desc.query.filter.terms[4] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.COMPONENT(world, ecs.SystemSort),
        .inout = ecs.c.EcsIn,
    });

    const startup_pipeline = ecs.c.ecs_pipeline_init(world, &pip_desc);
    ecs.c.ecs_set_pipeline(world, startup_pipeline);
    _ = ecs.c.ecs_progress(world, 0);

    flecs.ecs_delete_with(world, pre_startup);
    flecs.ecs_delete_with(world, startup);
    flecs.ecs_delete_with(world, post_startup);
}

fn setCorePipeline(world: *ecs.c.ecs_world_t) void {
    var pip_desc = std.mem.zeroes(ecs.c.ecs_pipeline_desc_t);
    pip_desc.entity = ecs.c.ecs_entity_init(world, &std.mem.zeroInit(ecs.c.ecs_entity_desc_t, .{ .name = "CustomPipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = ecs.COMPONENT(world, ecs.SystemSort);
    pip_desc.query.filter.terms[0].id = ecs.c.EcsSystem;
    pip_desc.query.filter.terms[1] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsDisabled,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsUp,
            .trav = ecs.c.EcsDependsOn,
        }),
        .oper = ecs.c.EcsNot,
    });
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsDisabled,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsUp,
            .trav = ecs.c.EcsChildOf,
        }),
        .oper = ecs.c.EcsNot,
    });
    pip_desc.query.filter.terms[3] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.COMPONENT(world, ecs.SystemSort),
        .inout = ecs.c.EcsIn,
    });

    const pipeline = ecs.c.ecs_pipeline_init(world, &pip_desc);
    ecs.c.ecs_set_pipeline(world, pipeline);
}
