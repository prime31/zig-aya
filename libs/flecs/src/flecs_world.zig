// NOTE: after regenerating flecs.zig the struct_ecs_world_t declaration needs to be
// replace with `pub const struct_ecs_world_t = @import("flecs_world.zig").struct_ecs_world_t;`
const std = @import("std");
const c = @import("flecs.zig");

pub const struct_ecs_world_t = opaque {
    const Self = *@This();

    pub fn deinit(self: Self) void {
        _ = c.ecs_fini(self);
    }
};
