const std = @import("std");
const ecs = @import("../ecs.zig");
const flecs = ecs.c;
const meta = @import("../meta.zig");

pub fn Iterator(comptime Components: type) type {
    std.debug.assert(@typeInfo(Components) == .Struct);

    // converts the Components struct fields into slices
    const Columns = meta.TableIteratorData(Components);

    // used internally to store the current tables columns and the array length
    const TableColumns = struct {
        columns: Columns = undefined,
        count: i32,
    };

    return struct {
        const Self = @This();
        pub const components_type = Components;

        iter: *flecs.ecs_iter_t,
        inner_iter: ?TableColumns = null,
        index: usize = 0,
        event_iter_called: bool = false,
        nextFn: *const fn ([*c]flecs.ecs_iter_t) callconv(.C) bool,

        pub fn init(iter: *flecs.ecs_iter_t, nextFn: *const fn ([*c]flecs.ecs_iter_t) callconv(.C) bool) Self {
            meta.validateIterator(Components, iter);
            return .{
                .iter = iter,
                .nextFn = nextFn,
            };
        }

        pub fn entity(self: *Self) ecs.Entity {
            return ecs.Entity.init(self.iter.world.?, self.iter.entities[self.index - 1]);
        }

        // TODO: RETHINK THIS API. direct world access feels odd. maybe return Commands wrapper
        pub fn world(self: *Self) *flecs.ecs_world_t {
            return self.iter.world.?;
        }

        pub fn tableType(self: *Self) ecs.Type {
            return ecs.Type.init(self.iter.world.?, self.iter.type);
        }

        pub fn skip(self: *Self) void {
            meta.assertMsg(self.nextFn == flecs.ecs_query_next, "skip only valid on Queries!", .{});
            flecs.ecs_query_skip(&self.iter);
        }

        /// gets the next Entity from the query results if one is available
        pub inline fn next(self: *Self) ?Components {
            // outer check for when we need to see if there is another table to iterate
            if (self.inner_iter == null) {
                self.inner_iter = self.nextTable() orelse return null;
                self.index = 0;
            }

            var comps: Components = undefined;
            inline for (@typeInfo(Components).Struct.fields) |field| {
                var column = @field(self.inner_iter.?.columns, field.name);

                // for optionals, we have to unwrap the column since it is also optional
                if (@typeInfo(field.type) == .Optional) {
                    if (column) |col| {
                        @field(comps, field.name) = &col[self.index];
                    } else {
                        @field(comps, field.name) = null;
                    }
                } else {
                    @field(comps, field.name) = &column[self.index];
                }
            }

            self.index += 1;

            // check for iteration of the current tables completion. if its done null the inner_iter so we fetch the next one when called again
            if (self.index == self.inner_iter.?.count) self.inner_iter = null;

            return comps;
        }

        /// gets the next table from the query results if one is available. Fills the iterator with the columns from the table.
        /// Do not call nextTable and next! Use next in almost all cases and nextTable only when you know what you are doing!
        /// nextTable can potentially speed up query iteration for cases where no columns are optional and all slices are iterated
        /// in the same for loop (for (comps.vel, comps.pos) |vel, pos| {})
        pub inline fn nextTable(self: *Self) ?TableColumns {
            // if we are an observer this is running in a callback as opposed to a run like systems. Because of that
            // we do NOT want to call nextFn! We are given a single table and we should return it and do nothing more.
            if (self.iter.event > 0) {
                if (self.event_iter_called) return null;
                self.event_iter_called = true;
            } else {
                if (!self.nextFn(self.iter)) return null;
            }

            var iter: TableColumns = .{ .count = self.iter.count };
            var index: usize = 0;
            inline for (@typeInfo(Components).Struct.fields, 0..) |field, i| {
                // skip EcsInOutNone since they arent returned when we iterate
                while (self.iter.terms[index].inout == flecs.EcsInOutNone) : (index += 1) {}

                const is_optional = @typeInfo(field.type) == .Optional;
                const col_type = meta.FinalChild(field.type);
                if (meta.isConst(field.type)) std.debug.assert(flecs.ecs_field_is_readonly(self.iter, i + 1));

                if (is_optional) @field(iter.columns, field.name) = null;
                const field_index = self.iter.terms[index].field_index;
                const raw_term_id = flecs.ecs_field_id(self.iter, @intCast(field_index + 1));
                const term_id = if (flecs.ecs_id_is_pair(raw_term_id)) ecs.pairFirst(raw_term_id) else raw_term_id;
                var skip_term = if (is_optional) self.iter.world.?.componentId(col_type) != term_id else false;

                // note that an OR is actually a single term!
                // std.debug.print("---- col_type: {any}, optional: {any}, i: {d}, col_index: {d}, skip_term: {d}\n", .{ col_type, is_optional, i, column_index, skip_term });
                // std.debug.print("---- compId: {any}, term_id: {any}\n", .{ meta.componentHandle(col_type).*, flecs.ecs_term_id(self.iter, @intCast(usize, column_index + 1)) });
                if (!skip_term) {
                    if (ecs.fieldOpt(self.iter, col_type, field_index + 1)) |col| {
                        @field(iter.columns, field.name) = col;
                    }
                }
                index += 1;
            }

            return iter;
        }
    };
}
