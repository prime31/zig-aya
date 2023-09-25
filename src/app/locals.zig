const std = @import("std");
const app = @import("mod.zig");

const Allocator = std.mem.Allocator;
const Resources = app.Resources;

pub fn Local(comptime T: type) type {
    return struct {
        pub const local_type = T;
        const Self = @This();

        local: *T,

        pub fn get(self: Self) *T {
            return self.local;
        }
    };
}

/// Stores a Resources per system, lazily created only if a system uses a Local
pub const LocalServer = struct {
    locals: std.AutoHashMap(u64, Resources),

    pub fn init(allocator: Allocator) LocalServer {
        return .{ .locals = std.AutoHashMap(u64, Resources).init(allocator) };
    }

    pub fn deinit(self: *LocalServer) void {
        var iter = self.locals.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.locals.deinit();
    }

    pub fn getLocalMut(self: *LocalServer, comptime T: type, system: u64) *T {
        var resources = self.locals.getPtr(system) orelse blk: {
            self.locals.put(system, Resources.init(self.locals.allocator)) catch unreachable;
            break :blk self.locals.getPtr(system).?;
        };

        if (!resources.contains(T)) return resources.initResource(T);
        return resources.get(T).?;
    }
};
