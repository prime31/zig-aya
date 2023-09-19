const std = @import("std");
const ecs = @import("ecs.zig");
const flecs = ecs.c;

pub const Type = struct {
    world: *flecs.ecs_world_t,
    type: flecs.ecs_type_t,

    pub fn init(world: *flecs.ecs_world_t, t: flecs.ecs_type_t) Type {
        return .{ .world = world, .type = t.? };
    }

    /// returns the number of component ids in the type
    pub fn count(self: Type) usize {
        return @as(usize, @intCast(flecs.ecs_vector_count(self.type.?)));
    }

    /// returns the formatted list of components in the type
    pub fn asString(self: Type) []const u8 {
        const str = flecs.ecs_type_str(self.world, self.type);
        const len = std.mem.len(str);
        return str[0..len];
    }

    /// returns an array of component ids
    pub fn toArray(self: Type) []const u64 {
        _ = self;
        @panic("implment me");
        // return @as([*c]const u64, @as(@alignCast(u64), @ptrCast(flecs._ecs_vector_first(self.type, @sizeOf(u64), @alignOf(u64)))))[1 .. self.count() + 1];
    }
};
