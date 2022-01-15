const std = @import("std");
const aya = @import("../../aya.zig");

pub fn MultiHashMap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        map: std.AutoHashMap(K, std.ArrayList(V)),
        allocator: std.mem.Allocator,

        pub fn init(allocator: ?std.mem.Allocator) Self {
            const alloc = allocator orelse aya.mem.allocator;

            return .{
                .map = std.AutoHashMap(K, std.ArrayList(V)).init(alloc),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: *Self) void {
            var iter = self.map.iterator();
            while (iter.next()) |item| {
                item.value.deinit();
            }
            self.map.deinit();
        }

        pub fn append(self: *Self, key: K, value: V) void {
            var res = self.map.getOrPut(key) catch unreachable;
            if (!res.found_existing) {
                res.entry.value = std.ArrayList(V).init(self.allocator);
            }
            _ = res.entry.value.append(value) catch unreachable;
        }

        pub fn get(self: Self, key: K) ?std.ArrayList(V) {
            return self.map.get(key);
        }
    };
}

test "" {
    var map = MultiHashMap(u64, i32).init(std.testing.allocator);
    defer map.deinit();

    map.append(6, -6);

    var bucket6 = map.get(6).?;
    std.testing.expectEqual(bucket6.items.len, 1);
    std.testing.expectEqual(bucket6.items[0], -6);
}
