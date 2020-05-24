const std = @import("std");

/// fixed size array wrapper that provides ArrayList-like semantics. Appending more items than fit in the
/// list ignores the item and logs a warning.
pub fn FixedList(comptime T: type, comptime len: usize) type {
    return struct {
        const Self = @This();

        items: [len]T = undefined,
        len: usize = 0,

        pub const Iterator = struct {
            list: Self,
            index: usize = 0,

            pub fn next(self: *Iterator) ?T {
                if (self.index == self.list.len) return null;
                var next_item = self.list.items[self.index];
                self.index += 1;
                return next_item;
            }
        };

        pub fn init() Self {
            return Self{ .items = [_]T{0} ** len };
        }

        pub fn append(self: *Self, item: T) void {
            if (self.len == self.items.len) {
                std.debug.warn("attemped to append to a full FixedList\n", .{});
                return;
            }
            self.items[self.len] = item;
            self.len += 1;
        }

        pub fn clear(self: *Self) void {
            self.len = 0;
        }

        pub fn pop(self: *Self) !T {
            var item = self.items[self.len - 1];
            self.len -= 1;
            return item;
        }

        pub fn iter(self: Self) Iterator {
            return Iterator{ .list = self };
        }
    };
}

test "fixed list" {
    var list = FixedList(u32, 4).init();
    list.append(4);
    std.testing.expectEqual(list.len, 1);

    list.append(46);
    list.append(146);
    list.append(4456);
    std.testing.expectEqual(list.len, 4);

    _ = try list.pop();
    std.testing.expectEqual(list.len, 3);

    list.clear();
    std.testing.expectEqual(list.len, 0);
}
