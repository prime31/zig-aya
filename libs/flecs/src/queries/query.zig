const std = @import("std");
const ecs = @import("../ecs.zig");
const flecs = ecs.c;
const meta = @import("../meta.zig");

pub const Query = struct {
    world: *flecs.ecs_world_t,
    query: *flecs.ecs_query_t,

    pub fn init(world: *flecs.ecs_world_t, desc: *flecs.ecs_query_desc_t) @This() {
        return .{ .world = world, .query = flecs.ecs_query_init(world.ecs, desc).? };
    }

    pub fn deinit(self: *@This()) void {
        flecs.ecs_query_fini(self.query);
    }

    pub fn asString(self: *@This()) [*c]u8 {
        const filter = flecs.ecs_query_get_filter(self.query);
        return flecs.ecs_filter_str(self.world.ecs, filter);
    }

    pub fn changed(self: *@This(), iter: ?*flecs.ecs_iter_t) bool {
        if (iter) |it| return flecs.ecs_query_changed(self.query, it);
        return flecs.ecs_query_changed(self.query, null);
    }

    /// gets an iterator that let you iterate the tables and then it provides an inner iterator to interate entities
    pub fn tableIterator(self: *@This(), comptime Components: type) ecs.TableIterator(Components) {
        temp_iter_storage = flecs.ecs_query_iter(self.world.ecs, self.query);
        return ecs.TableIterator(Components).init(&temp_iter_storage, flecs.ecs_query_next);
    }

    // storage for the iterator so it can be passed by reference. Do not in-flight two Queries at once!
    var temp_iter_storage: flecs.ecs_iter_t = undefined;

    /// gets an iterator that iterates all matched entities from all tables in one iteration. Do not create more than one at a time!
    pub fn iterator(self: *@This(), comptime Components: type) ecs.Iterator(Components) {
        temp_iter_storage = flecs.ecs_query_iter(self.world.ecs, self.query);
        return ecs.Iterator(Components).init(&temp_iter_storage, flecs.ecs_query_next);
    }

    /// allows either a function that takes 1 parameter (a struct with fields that match the components in the query) or multiple paramters
    /// (each param should match the components in the query in order)
    pub fn each(self: *@This(), comptime function: anytype) void {
        // dont allow BoundFn
        std.debug.assert(@typeInfo(@TypeOf(function)) == .Fn);
        comptime var arg_count = meta.argCount(function);

        if (arg_count == 1) {
            const Components = @typeInfo(@TypeOf(function)).Fn.args[0].arg_type.?;

            var iter = self.iterator(Components);
            while (iter.next()) |comps| {
                @call(.{ .modifier = .always_inline }, function, .{comps});
            }
        } else {
            const Components = std.meta.ArgsTuple(@TypeOf(function));

            var iter = self.iterator(Components);
            while (iter.next()) |comps| {
                @call(.{ .modifier = .always_inline }, function, meta.fieldsTuple(comps));
            }
        }
    }
};
