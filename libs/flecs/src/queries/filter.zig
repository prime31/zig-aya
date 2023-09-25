const std = @import("std");
const ecs = @import("../ecs.zig");
const flecs = ecs.c;
const meta = @import("../meta.zig");

pub const Filter = struct {
    const Self = @This();

    world: *flecs.ecs_world_t,
    filter: *flecs.ecs_filter_t,

    pub fn init(world: *flecs.ecs_world_t, desc: *flecs.ecs_filter_desc_t) Self {
        return .{
            .world = world,
            .filter = flecs.ecs_filter_init(world.ecs, desc),
        };
    }

    pub fn deinit(self: *Self) void {
        flecs.ecs_filter_fini(self.filter);
    }

    pub fn asString(self: *Self) [*c]u8 {
        return flecs.ecs_filter_str(self.world.ecs, self.filter);
    }

    // storage for the iterator so it can be passed by reference. Do not in-flight two Filters at once!
    var temp_iter_storage: flecs.ecs_iter_t = undefined;

    /// gets an iterator that iterates all matched entities from all tables in one iteration. Do not create more than one at a time!
    pub fn iterator(self: *Self, comptime Components: type) ecs.Iterator(Components) {
        temp_iter_storage = flecs.ecs_filter_iter(self.world.ecs, self.filter);
        return ecs.Iterator(Components).init(&temp_iter_storage, flecs.ecs_filter_next);
    }

    /// allows either a function that takes 1 parameter (a struct with fields that match the components in the query) or multiple paramters
    /// (each param should match the components in the query in order)
    pub fn each(self: *Self, comptime function: anytype) void {
        // dont allow BoundFn
        std.debug.assert(@typeInfo(@TypeOf(function)) == .Fn);
        comptime var arg_count = meta.argCount(function);

        if (arg_count == 1) {
            const Components = @typeInfo(@TypeOf(function)).Fn.params[0].type.?;

            var iter = self.iterator(Components);
            while (iter.next()) |comps| {
                @call(.always_inline, function, .{comps});
            }
        } else {
            const Components = std.meta.ArgsTuple(@TypeOf(function));

            var iter = self.iterator(Components);
            while (iter.next()) |comps| {
                @call(.always_inline, function, meta.fieldsTuple(comps));
            }
        }
    }
};
