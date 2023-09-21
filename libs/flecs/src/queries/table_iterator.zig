const std = @import("std");
const ecs = @import("../ecs.zig");
const flecs = ecs.c;
const meta = @import("../meta.zig");

pub fn TableIterator(comptime Components: type) type {
    std.debug.assert(@typeInfo(Components) == .Struct);

    const Columns = meta.TableIteratorData(Components);

    return struct {
        pub const InnerIterator = struct {
            data: Columns = undefined,
            count: i32,
        };

        iter: *flecs.ecs_iter_t,
        nextFn: *const fn ([*c]flecs.ecs_iter_t) callconv(.C) bool,

        pub fn init(iter: *flecs.ecs_iter_t, nextFn: *const fn ([*c]flecs.ecs_iter_t) callconv(.C) bool) @This() {
            meta.validateIterator(Components, iter);
            return .{
                .iter = iter,
                .nextFn = nextFn,
            };
        }

        pub fn tableType(self: *@This()) flecs.Type {
            return flecs.Type.init(self.iter.world.?, self.iter.type);
        }

        pub fn skip(self: *@This()) void {
            meta.assertMsg(self.nextFn == flecs.ecs_query_next, "skip only valid on Queries!", .{});
            flecs.ecs_query_skip(self.iter);
        }

        pub fn next(self: *@This()) ?InnerIterator {
            if (!self.nextFn(self.iter)) return null;

            var iter: InnerIterator = .{ .count = self.iter.count };
            var index: usize = 0;
            inline for (@typeInfo(Components).Struct.fields, 0..) |field, i| {
                // skip EcsInOutNone since they arent returned when we iterate
                while (self.iter.terms[index].inout == flecs.EcsInOutNone) : (index += 1) {}

                const is_optional = @typeInfo(field.type) == .Optional;
                const col_type = meta.FinalChild(field.type);
                if (meta.isConst(field.type)) std.debug.assert(flecs.ecs_field_is_readonly(self.iter, i + 1));

                if (is_optional) @field(iter.data, field.name) = null;
                const field_index = self.iter.terms[index].field_index;
                var skip_term = if (is_optional) meta.id(col_type) != flecs.ecs_field_id(self.iter, @intCast(field_index + 1)) else false;

                // note that an OR is actually a single term!
                // std.debug.print("---- col_type: {any}, optional: {any}, i: {d}, col_index: {d}\n", .{ col_type, is_optional, i, column_index });
                if (!skip_term) {
                    if (ecs.fieldOpt(self.iter, col_type, field_index + 1)) |col| {
                        @field(iter.data, field.name) = col;
                    }
                }
                index += 1;
            }

            return iter;
        }
    };
}
