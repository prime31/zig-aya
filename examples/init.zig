const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");
const flecs = ecs.c;

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
    ecs.SYSTEM(world, "collision_0", Collisions, 0, &system_desc);
    ecs.SYSTEM(world, "update_1", Update, 0, &system_desc);
    ecs.SYSTEM(world, "physics_2", Physics, 0, &system_desc);
    ecs.SYSTEM(world, "physics_3", Physics, 0, &system_desc);
    ecs.SYSTEM(world, "update_4", Update, 0, &system_desc);

    ecs.SYSTEM(world, "startup_system1", ecs.c.EcsOnStart, 0, &system_desc);
    ecs.SYSTEM(world, "startup_system2", ecs.c.EcsOnStart, 0, &system_desc);
    ecs.SYSTEM(world, "startup_system3", ecs.c.EcsOnStart, 0, &system_desc);

    ecs.c.ecs_set_target_fps(world, 30);
    _ = ecs.c.ecs_progress(world, 0);
    std.debug.print("---------\n", .{});
    _ = ecs.c.ecs_progress(world, 0);

    testUnion(world);
}

fn run(it: [*c]ecs.c.ecs_iter_t) callconv(.C) void {
    std.debug.print("------------ runing: {s}\n", .{ecs.c.ecs_get_name(it.*.world, it.*.system)});
    if (!ecs.c.ecs_iter_next(it)) return; // could be ecs_filter_next or ecs_query_next
}

pub fn testUnion(world: *flecs.ecs_world_t) void {
    std.debug.print("\n{}\n", .{world});

    const movement = flecs.ecs_new_id(world);
    _ = flecs.ecs_add_id(world, movement, flecs.EcsUnion);

    const walking = flecs.ecs_new_id(world);
    const running = flecs.ecs_new_id(world);

    const e = flecs.ecs_new_id(world);
    ecs.addPair(world, e, movement, running);
    ecs.addPair(world, e, movement, walking);
    ecs.addPair(world, e, movement, running);

    var filter_desc = std.mem.zeroes(flecs.ecs_filter_desc_t);
    filter_desc.terms[0].id = ecs.pair(world, movement, flecs.EcsWildcard);

    const filter = flecs.ecs_filter_init(world, &filter_desc);
    defer flecs.ecs_filter_fini(filter);

    var it = flecs.ecs_filter_iter(world, filter);
    while (flecs.ecs_filter_next(&it)) {
        var i: usize = 0;
        while (i < it.count) : (i += 1) {
            const state = flecs.ecs_get_target(it.world, it.entities[i], movement, 0);
            std.debug.print("------ ++++++++ wtf: {} movement: {}, walk: {}, run: {}\n", .{ state, movement, walking == state, running == state });
        }
    }
}
