const std = @import("std");
const ecs = @import("ecs.zig");
const flecs = ecs.c;

/// void {} is an allowed T for Terms that iterate only the entities. Void is requiried when using initWithPair
pub fn Term(comptime T: anytype) type {
    std.debug.assert(@TypeOf(T) == type or @TypeOf(T) == void);

    return struct {
        const Self = @This();

        ecs: ecs.Ecs,
        term: flecs.ecs_term_t,

        const Iterator = struct {
            iter: flecs.ecs_iter_t,
            index: usize = 0,

            pub fn init(iter: flecs.ecs_iter_t) Iterator {
                return .{ .iter = iter };
            }

            pub fn next(self: *Iterator) ?*T {
                if (self.index >= self.iter.count) {
                    self.index = 0;
                    if (!flecs.ecs_term_next(&self.iter)) return null;
                }

                self.index += 1;
                const array = ecs.field(&self.iter, T, 1);
                return &array[self.index - 1];
            }

            pub fn entity(self: *Iterator) ecs.Entity {
                return ecs.Entity.init(self.iter.world.?, self.iter.entities[self.index - 1]);
            }
        };

        const EntityIterator = struct {
            iter: flecs.ecs_iter_t,
            index: usize = 0,

            pub fn init(iter: flecs.ecs_iter_t) EntityIterator {
                return .{ .iter = iter };
            }

            pub fn next(self: *EntityIterator) ?flecs.Entity {
                if (self.index >= self.iter.count) {
                    self.index = 0;
                    if (!flecs.ecs_term_next(&self.iter)) return null;
                }

                self.index += 1;
                return flecs.Entity.init(self.iter.world.?, self.iter.entities[self.index - 1]);
            }
        };

        pub fn init(world: ecs.Ecs) Self {
            var term = std.mem.zeroInit(flecs.ecs_term_t, .{ .id = world.componentId(T) });
            return .{ .ecs = world, .term = term };
        }

        pub fn initWithPair(world: flecs.World, pair: u64) Self {
            std.debug.assert(@TypeOf(T) == void);
            var term = std.mem.zeroInit(flecs.ecs_term_t, .{ .id = pair });
            return .{ .world = world, .term = term };
        }

        pub fn deinit(self: *Self) void {
            flecs.ecs_term_fini(&self.term);
        }

        // only export each if we have an actual T that is a struct, pairs with void only iterate entities
        pub usingnamespace if (@TypeOf(T) == type) struct {
            pub fn iterator(self: *Self) Iterator {
                return Iterator.init(flecs.ecs_term_iter(self.ecs.ecs, &self.term));
            }

            pub fn each(self: *Self, function: *const fn (ecs.Entity, *T) void) void {
                var iter = self.iterator();
                while (iter.next()) |comp| {
                    function(iter.entity(), comp);
                }
            }
        } else struct {
            pub fn iterator(self: *Self) EntityIterator {
                return EntityIterator.init(flecs.ecs_term_iter(self.ecs.world, &self.term));
            }
        };

        pub fn entityIterator(self: *Self) EntityIterator {
            return EntityIterator.init(flecs.ecs_term_iter(self.ecs.world, &self.term));
        }
    };
}
