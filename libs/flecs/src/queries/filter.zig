const std = @import("std");
const ecs = @import("../ecs.zig");
const c = ecs.c;
const meta = @import("../meta.zig");

pub fn Filter(comptime T: type) type {
    return struct {
        const Self = @This();

        world: *c.ecs_world_t,
        filter: *c.ecs_filter_t,
        temp_iter_storage: c.ecs_iter_t = undefined,

        pub fn deinit(self: *Self) void {
            c.ecs_filter_fini(self.filter);
        }

        pub usingnamespace if (T == void) struct {
            pub fn init(world: *c.ecs_world_t, desc: *c.ecs_filter_desc_t) Self {
                return .{
                    .world = world,
                    .filter = c.ecs_filter_init(world, desc),
                };
            }

            /// gets an iterator that iterates all matched entities from all tables in one iteration
            pub fn iterator(self: *Self, comptime Components: type) ecs.Iterator(Components) {
                self.temp_iter_storage = c.ecs_filter_iter(self.world, self.filter);
                return ecs.Iterator(Components).init(&self.temp_iter_storage, c.ecs_filter_next);
            }

            /// allows either a function that takes 1 parameter of type T or multiple parameters
            /// (each param should match the components in T in order)
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
        } else struct {
            pub fn init(world: *c.ecs_world_t) Self {
                return .{
                    .world = world,
                    .filter = c.ecs_filter_init(world, &meta.generateFilterDesc(world, T)),
                };
            }

            /// gets an iterator that iterates all matched entities from all tables in one iteration
            pub fn iterator(self: *Self) ecs.Iterator(T) {
                self.temp_iter_storage = c.ecs_filter_iter(self.world, self.filter);
                return ecs.Iterator(T).init(&self.temp_iter_storage, c.ecs_filter_next);
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
                    var iter = self.iterator(T);
                    while (iter.next()) |comps| {
                        @call(.always_inline, function, meta.fieldsTuple(comps));
                    }
                }
            }
        };
    };
}
