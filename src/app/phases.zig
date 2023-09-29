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

    state_transition,
    first,
    pre_update,
    update,
    post_update,
    last,

    pub fn getEntity(self: Phase) u64 {
        return switch (self) {
            .pre_startup => pre_startup,
            .startup => startup,
            .post_startup => post_startup,

            .state_transition => state_transition,
            .first => first,
            .pre_update => pre_update,
            .update => update,
            .post_update => post_update,
            .last => last,
        };
    }
};

pub fn registerPhases(world: *c.ecs_world_t) void {
    inline for (std.meta.fields(Phase)) |p| {
        var desc = std.mem.zeroInit(c.ecs_entity_desc_t, .{
            .name = @typeName(Phase) ++ "." ++ p.name,
            .add = [_]u64{c.EcsPhase} ++ [_]u64{0} ** 31,
        });
        @field(@This(), p.name) = c.ecs_entity_init(world, &desc);
    }
}
