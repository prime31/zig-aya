const std = @import("std");
const assets = @import("mod.zig");

const Allocator = std.mem.Allocator;

pub const AssetIndex = struct {
    index: u32 = 0,
    generation: u32 = 1,
};

pub fn AssetId(comptime T: type) type {
    return struct {
        pub const phantom = T;

        index: AssetIndex,
    };
}

pub const AssetHandleProvider = struct {
    const Self = @This();

    handles: []AssetIndex,
    append_cursor: u32 = 0,
    last_destroyed: ?u32 = null,
    allocator: std.mem.Allocator,

    const invalid_id = std.math.maxInt(u32);

    pub const Iterator = struct {
        hm: Self,
        index: usize = 0,

        pub fn init(hm: Self) @This() {
            return .{ .hm = hm };
        }

        pub fn next(self: *@This()) ?AssetIndex {
            if (self.index == self.hm.append_cursor) return null;

            for (self.hm.handles[self.index..self.hm.append_cursor]) |h| {
                self.index += 1;
                if (self.hm.alive(h)) {
                    return h;
                }
            }
            return null;
        }
    };

    pub fn init(allocator: std.mem.Allocator) Self {
        return initWithCapacity(allocator, 32);
    }

    pub fn initWithCapacity(allocator: std.mem.Allocator, capacity: usize) Self {
        return Self{
            .handles = allocator.alloc(AssetIndex, capacity) catch unreachable,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Self) void {
        self.allocator.free(self.handles);
    }

    pub fn create(self: *Self) AssetIndex {
        if (self.last_destroyed == null) {
            // ensure capacity and grow if needed
            if (self.handles.len - 1 == self.append_cursor) {
                self.handles = self.allocator.realloc(self.handles, self.handles.len * 2) catch unreachable;
            }

            const id = self.append_cursor;
            const handle = AssetIndex{ .index = self.append_cursor };
            self.handles[id] = handle;

            self.append_cursor += 1;
            return handle;
        }

        const version = self.handles[self.last_destroyed.?].generation;
        const destroyed_id = self.handles[self.last_destroyed.?].index;

        const handle = AssetIndex{ .index = self.last_destroyed.?, .generation = version };
        self.handles[self.last_destroyed.?] = handle;

        self.last_destroyed = if (destroyed_id == invalid_id) null else destroyed_id;

        return handle;
    }

    pub fn remove(self: *Self, handle: AssetIndex) !void {
        if (handle.index > self.append_cursor or self.handles[handle.index].index != handle.index or self.handles[handle.index].generation != handle.generation)
            return error.RemovedInvalidHandle;

        const next_id = self.last_destroyed orelse invalid_id;
        if (next_id == handle.index) return error.ExhaustedEntityRemoval;

        self.handles[handle.index] = AssetIndex{ .index = next_id, .generation = handle.generation +% 1 };
        self.last_destroyed = handle.index;
    }

    pub fn alive(self: Self, handle: AssetIndex) bool {
        return handle.index < self.append_cursor and self.handles[handle.index].index == handle.index and self.handles[handle.index].generation == handle.generation;
    }

    pub fn iterator(self: Self) Iterator {
        return Iterator.init(self);
    }
};

test "handles" {
    var hm = AssetHandleProvider.init(std.testing.allocator);
    defer hm.deinit();

    const e0 = hm.create();
    const e1 = hm.create();
    const e2 = hm.create();

    std.debug.assert(hm.alive(e0));
    std.debug.assert(hm.alive(e1));
    std.debug.assert(hm.alive(e2));

    hm.remove(e1) catch unreachable;
    std.debug.assert(!hm.alive(e1));

    try std.testing.expectError(error.RemovedInvalidHandle, hm.remove(e1));

    var e_tmp = hm.create();
    std.debug.assert(hm.alive(e_tmp));

    hm.remove(e_tmp) catch unreachable;
    std.debug.assert(!hm.alive(e_tmp));

    hm.remove(e0) catch unreachable;
    std.debug.assert(!hm.alive(e0));

    hm.remove(e2) catch unreachable;
    std.debug.assert(!hm.alive(e2));

    e_tmp = hm.create();
    std.debug.assert(hm.alive(e_tmp));

    e_tmp = hm.create();
    std.debug.assert(hm.alive(e_tmp));

    e_tmp = hm.create();
    std.debug.assert(hm.alive(e_tmp));
    // std.debug.print("e_tmp: {}\n", .{e_tmp});
}
