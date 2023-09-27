const std = @import("std");
const c = @import("../ecs/mod.zig").c;

pub var pre_startup: u64 = 0;
pub var startup: u64 = 0;
pub var post_startup: u64 = 0;

pub var first: u64 = 0;
pub var pre_update: u64 = 0;
pub var state_transition: u64 = 0;
pub var update: u64 = 0;
pub var post_update: u64 = 0;
pub var last: u64 = 0;

pub const Phase = enum {
    pre_startup,
    startup,
    post_startup,

    first,
    pre_update,
    state_transition,
    update,
    post_update,
    last,

    pub fn getEntity(self: Phase) u64 {
        return switch (self) {
            .pre_startup => pre_startup,
            .startup => startup,
            .post_startup => post_startup,
            .first => first,
            .pre_update => pre_update,
            .state_transition => state_transition,
            .update => update,
            .post_update => post_update,
            .last => last,
        };
    }
};

pub fn registerPhases(world: *c.ecs_world_t) void {
    pre_startup = c.ecs_new_w_id(world, c.EcsPhase);
    startup = c.ecs_new_w_id(world, c.EcsPhase);
    post_startup = c.ecs_new_w_id(world, c.EcsPhase);

    first = c.ecs_new_w_id(world, c.EcsPhase);
    pre_update = c.ecs_new_w_id(world, c.EcsPhase);
    state_transition = c.ecs_new_w_id(world, c.EcsPhase);
    update = c.ecs_new_w_id(world, c.EcsPhase);
    post_update = c.ecs_new_w_id(world, c.EcsPhase);
    last = c.ecs_new_w_id(world, c.EcsPhase);
}
