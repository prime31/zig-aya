const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");

const Resources = aya.Resources;
const App = aya.App;

pub fn main() !void {
    const world = ecs.c.ecs_init().?;
    defer _ = ecs.c.ecs_fini(world);

    // On the first run of the schedule (and only on the first run), it will run:
    // * [`PreStartup`]
    // * [`Startup`]
    // * [`PostStartup`]
    //
    // Then it will run:
    // * [`First`]
    // * [`PreUpdate`]
    // * [`StateTransition`]
    // * [`RunFixedUpdateLoop`]
    //     * This will run [`FixedUpdate`] zero to many times, based on how much time has elapsed.
    // * [`Update`]
    // * [`PostUpdate`]
    // * [`Last`]

    const PreStartup = makePhase(world, null);
    const Startup = makePhase(world, PreStartup);
    const PostStartup = makePhase(world, Startup);

    const phase_0 = makePhase(world, null);
    const phase_1 = makePhase(world, phase_0);
    const phase_2 = makePhase(world, phase_1);
    const phase_3 = makePhase(world, phase_2);
    const phase_4 = makePhase(world, phase_3);
    const phase_5 = makePhase(world, phase_4);

    const First = makePhase(world, null);
    const PreUpdate = makePhase(world, phase_0);
    const StateTransition = makePhase(world, phase_1);
    const RunFixedUpdateLoop = makePhase(world, phase_2);
    _ = RunFixedUpdateLoop;
    const Update = makePhase(world, phase_3);
    const PostUpdate = makePhase(world, phase_4);
    _ = PostUpdate;
    const Last = makePhase(world, phase_5);

    var system_desc: ecs.c.ecs_system_desc_t = std.mem.zeroInit(ecs.c.ecs_system_desc_t, .{
        .callback = run,
        .run = run,
        .query = std.mem.zeroInit(ecs.c.ecs_query_desc_t, .{
            .filter = std.mem.zeroInit(ecs.c.ecs_filter_desc_t, .{ .expr = null }),
        }),
    });

    ecs.SYSTEM(world, "StateTransition_0", StateTransition, &system_desc);
    ecs.SYSTEM(world, "StateTransition_1", StateTransition, &system_desc);
    ecs.SYSTEM(world, "First_0", First, &system_desc);
    ecs.SYSTEM(world, "Update_0", Update, &system_desc);
    ecs.SYSTEM(world, "Update_1", Update, &system_desc);
    ecs.SYSTEM(world, "PreUpdate_0", PreUpdate, &system_desc);
    ecs.SYSTEM(world, "PreUpdate_1", PreUpdate, &system_desc);
    ecs.SYSTEM(world, "Last_0", Last, &system_desc);

    ecs.SYSTEM(world, "PostStartup", PostStartup, &system_desc);
    ecs.SYSTEM(world, "PreStartup", PreStartup, &system_desc);
    ecs.SYSTEM(world, "Startup", Startup, &system_desc);

    ecs.c.ecs_set_target_fps(world, 30);

    // run the startup pipeline
    const startup_pipeline = getStartupPipeline(world, PreStartup, Startup, PostStartup);
    ecs.c.ecs_set_pipeline(world, startup_pipeline);
    _ = ecs.c.ecs_progress(world, 0);
    removeStartupSystems(world, PreStartup, Startup, PostStartup);

    var pip_desc = std.mem.zeroes(ecs.c.ecs_pipeline_desc_t);
    pip_desc.entity = ecs.c.ecs_entity_init(world, &std.mem.zeroInit(ecs.c.ecs_entity_desc_t, .{ .name = "CustomPipeline" }));
    pip_desc.query.order_by = pipelineEntityCompare;
    pip_desc.query.filter.terms[0].id = ecs.c.EcsSystem;
    pip_desc.query.filter.terms[1] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsPhase,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsCascade,
            .trav = ecs.c.EcsDependsOn,
        }),
    });
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.ecs_make_pair(ecs.c.EcsDependsOn, ecs.c.EcsOnStart),
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{ .trav = ecs.c.EcsDependsOn }),
        .oper = ecs.c.EcsNot,
    });
    pip_desc.query.filter.terms[3] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsDisabled,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsUp,
            .trav = ecs.c.EcsDependsOn,
        }),
        .oper = ecs.c.EcsNot,
    });
    pip_desc.query.filter.terms[4] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsDisabled,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsUp,
            .trav = ecs.c.EcsChildOf,
        }),
        .oper = ecs.c.EcsNot,
    });

    const pipeline = ecs.c.ecs_pipeline_init(world, &pip_desc);
    ecs.c.ecs_set_pipeline(world, pipeline);

    for (0..2) |_| {
        std.debug.print("---------\n", .{});
        _ = ecs.c.ecs_progress(world, 0);
    }
}

fn run(it: [*c]ecs.c.ecs_iter_t) callconv(.C) void {
    std.debug.print("------------ runing: {s}\n", .{ecs.c.ecs_get_name(it.*.world, it.*.system)});
    if (!ecs.c.ecs_iter_next(it)) return;
}

fn makePhase(world: *ecs.c.ecs_world_t, depends_on: ?u64) u64 {
    const phase = ecs.c.ecs_new_w_id(world, ecs.c.EcsPhase);
    if (depends_on) |d| ecs.c.ecs_add_id(world, phase, ecs.c.ecs_make_pair(ecs.c.EcsDependsOn, d));
    return phase;
}

fn pipelineEntityCompare(e1: u64, _: ?*const anyopaque, e2: u64, _: ?*const anyopaque) callconv(.C) c_int {
    const first: c_int = if (e1 > e2) 1 else 0;
    const second: c_int = if (e1 < e2) 1 else 0;
    return first - second;
}

fn getStartupPipeline(world: *ecs.c.ecs_world_t, pre_startup: u64, startup: u64, post_startup: u64) u64 {
    var pip_desc = std.mem.zeroes(ecs.c.ecs_pipeline_desc_t);
    pip_desc.entity = ecs.c.ecs_entity_init(world, &std.mem.zeroInit(ecs.c.ecs_entity_desc_t, .{ .name = "StartupPipeline" }));
    pip_desc.query.order_by = pipelineEntityCompare;
    pip_desc.query.filter.terms[0].id = ecs.c.EcsSystem;
    pip_desc.query.filter.terms[1] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsPhase,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsCascade,
            .trav = ecs.c.EcsDependsOn,
        }),
    });
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsDisabled,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsUp,
            .trav = ecs.c.EcsDependsOn,
        }),
        .oper = ecs.c.EcsNot,
    });
    pip_desc.query.filter.terms[3] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.EcsDisabled,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{
            .flags = ecs.c.EcsUp,
            .trav = ecs.c.EcsChildOf,
        }),
        .oper = ecs.c.EcsNot,
    });

    pip_desc.query.filter.terms[4] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.ecs_make_pair(ecs.c.EcsDependsOn, pre_startup),
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{ .trav = ecs.c.EcsDependsOn }),
        .oper = ecs.c.EcsOr,
    });
    pip_desc.query.filter.terms[5] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.ecs_make_pair(ecs.c.EcsDependsOn, startup),
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{ .trav = ecs.c.EcsDependsOn }),
        .oper = ecs.c.EcsOr,
    });
    pip_desc.query.filter.terms[6] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = ecs.c.ecs_make_pair(ecs.c.EcsDependsOn, post_startup),
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{ .trav = ecs.c.EcsDependsOn }),
    });

    return ecs.c.ecs_pipeline_init(world, &pip_desc);
}

fn removeStartupSystems(world: *ecs.c.ecs_world_t, pre_startup: u64, startup: u64, post_startup: u64) void {
    var filter_desc = std.mem.zeroes(ecs.c.ecs_filter_desc_t);
    // filter_desc.terms[0].id = pre_startup;
    filter_desc.terms[0] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = pre_startup,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{ .trav = ecs.c.EcsDependsOn }),
        .oper = ecs.c.EcsOr,
    });
    filter_desc.terms[1] = std.mem.zeroInit(ecs.c.ecs_term_t, .{
        .id = startup,
        .src = std.mem.zeroInit(ecs.c.ecs_term_id_t, .{ .trav = ecs.c.EcsDependsOn }),
        .oper = ecs.c.EcsOr,
    });
    filter_desc.terms[2].id = post_startup;

    const filter = ecs.c.ecs_filter_init(world, &filter_desc);
    var it = ecs.c.ecs_filter_iter(world, filter);
    while (ecs.c.ecs_filter_next(&it)) {
        var i: c_int = 0;
        while (i < it.count) : (i += 1) {
            ecs.c.ecs_delete(it.world, it.entities[@intCast(i)]);
        }
    }
}
