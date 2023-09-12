const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");

const Resources = aya.Resources;
const App = aya.App;

pub fn main() !void {
    const world = ecs.c.ecs_init().?;
    defer _ = ecs.c.ecs_fini(world);

    const Update = ecs.c.ecs_new_w_id(world, ecs.c.EcsPhase);
    const Physics = ecs.c.ecs_new_w_id(world, ecs.c.EcsPhase);
    const Collisions = ecs.c.ecs_new_w_id(world, ecs.c.EcsPhase);

    ecs.c.ecs_add_id(world, Physics, ecs.c.ecs_make_pair(ecs.c.EcsDependsOn, Update));
    ecs.c.ecs_add_id(world, Collisions, ecs.c.ecs_make_pair(ecs.c.EcsDependsOn, Physics));

    var system_desc: ecs.c.ecs_system_desc_t = std.mem.zeroInit(ecs.c.ecs_system_desc_t, .{
        .callback = run,
        .run = run,
        .query = std.mem.zeroInit(ecs.c.ecs_query_desc_t, .{
            .filter = std.mem.zeroInit(ecs.c.ecs_filter_desc_t, .{ .expr = null }),
        }),
    });
    ecs.SYSTEM(world, "collision_0", Collisions, &system_desc);
    ecs.SYSTEM(world, "update_1", Update, &system_desc);
    ecs.SYSTEM(world, "physics_2", Physics, &system_desc);
    ecs.SYSTEM(world, "physics_3", Physics, &system_desc);
    ecs.SYSTEM(world, "update_4", Update, &system_desc);

    ecs.SYSTEM(world, "startup_system1", ecs.c.EcsOnStart, &system_desc);
    ecs.SYSTEM(world, "startup_system2", ecs.c.EcsOnStart, &system_desc);
    ecs.SYSTEM(world, "startup_system3", ecs.c.EcsOnStart, &system_desc);

    ecs.c.ecs_set_target_fps(world, 30);
    _ = ecs.c.ecs_progress(world, 0);
    std.debug.print("---------\n", .{});
    _ = ecs.c.ecs_progress(world, 0);
}

fn run(it: [*c]ecs.c.ecs_iter_t) callconv(.C) void {
    std.debug.print("------------ runing: {s}\n", .{ecs.c.ecs_get_name(it.*.world, it.*.system)});
    if (!ecs.c.ecs_iter_next(it)) return; // could be ecs_filter_next or ecs_query_next
}
