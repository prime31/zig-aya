const std = @import("std");
const ecs = @import("../ecs.zig");
const c = ecs.c;
const meta = @import("../meta.zig");

pub fn Query(comptime T: type) type {
    return struct {
        const Self = @This();

        world: *c.ecs_world_t,
        query: *c.ecs_query_t,
        temp_iter_storage: c.ecs_iter_t = undefined,

        pub fn deinit(self: *Self) void {
            c.ecs_query_fini(self.query);
        }

        pub fn asString(self: *@This()) [*c]u8 {
            const filter = c.ecs_query_get_filter(self.query);
            return c.ecs_filter_str(self.world.ecs, filter);
        }

        pub fn changed(self: *@This(), iter: ?*c.ecs_iter_t) bool {
            if (iter) |it| return c.ecs_query_changed(self.query, it);
            return c.ecs_query_changed(self.query, null);
        }

        pub usingnamespace if (T == void) struct {
            pub fn init(world: *c.ecs_world_t, desc: *c.ecs_query_desc_t) Self {
                return .{ .world = world, .query = c.ecs_query_init(world, desc).? };
            }

            /// gets an iterator that iterates all matched entities from all tables in one iteration. Do not create more than one at a time!
            pub fn iterator(self: *Self, comptime Components: type) ecs.Iterator(Components) {
                self.temp_iter_storage = c.ecs_query_iter(self.world, self.query);
                return ecs.Iterator(Components).init(&self.temp_iter_storage, c.ecs_query_next);
            }

            /// allows either a function that takes 1 parameter of type T or multiple parameters
            /// (each param should match the components in T in order)
            pub fn each(self: *Self, comptime function: anytype) void {
                // dont allow BoundFn
                std.debug.assert(@typeInfo(@TypeOf(function)) == .Fn);
                comptime var arg_count = meta.argCount(function);

                if (arg_count == 1) {
                    const Components = @typeInfo(@TypeOf(function)).Fn.args[0].arg_type.?;

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
        } else struct {
            pub fn init(world: *c.ecs_world_t) Self {
                return .{ .world = world, .query = c.ecs_query_init(world, &meta.generateFilterDesc(world, T)).? };
            }

            /// gets an iterator that iterates all matched entities from all tables in one iteration. Do not create more than one at a time!
            pub fn iterator(self: *Self) ecs.Iterator(T) {
                self.temp_iter_storage = c.ecs_query_iter(self.world, self.query);
                return ecs.Iterator(T).init(&self.temp_iter_storage, c.ecs_query_next);
            }

            /// allows either a function that takes 1 parameter of type T or multiple parameters
            /// (each param should match the components in T in order)
            pub fn each(self: *Self, comptime function: anytype) void {
                std.debug.assert(@typeInfo(@TypeOf(function)) == .Fn);

                comptime var arg_count = meta.argCount(function);
                if (arg_count == 1) {
                    std.debug.assert(@typeInfo(@TypeOf(function)).Fn.params[0].type.? == T);

                    var iter = self.iterator(T);
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
    };
}
