const std = @import("std");
const aya = @import("../aya.zig");
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
pub const LocalResources = struct {
    locals: std.AutoHashMap(u64, Resources),

    pub fn init() LocalResources {
        return .{ .locals = std.AutoHashMap(u64, Resources).init(aya.allocator) };
    }

    pub fn deinit(self: *LocalResources) void {
        var iter = self.locals.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.locals.deinit();
    }

    pub fn insert(self: *LocalResources, comptime T: type, system: u64, local: T) void {
        var resources: *Resources = self.locals.getPtr(system) orelse blk: {
            self.locals.put(system, Resources.init()) catch unreachable;
            break :blk self.locals.getPtr(system).?;
        };

        resources.insert(local);
    }

    pub fn getLocalMut(self: *LocalResources, comptime T: type, system: u64) *T {
        var resources = self.locals.getPtr(system) orelse blk: {
            self.locals.put(system, Resources.init()) catch unreachable;
            break :blk self.locals.getPtr(system).?;
        };

        if (!resources.contains(T)) return resources.initResource(T);
        return resources.get(T).?;
    }
};
