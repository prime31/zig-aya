const std = @import("std");
const Allocator = std.mem.Allocator;
const Resources = @import("resources.zig").Resources;

pub const World = struct {
    const Self = @This();

    resources: Resources,

    pub fn init(allocator: Allocator) Self {
        return .{ .resources = Resources.init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.resources.deinit();
    }

    // Resources
    pub fn insertResource(self: *Self, resource: anytype) void {
        self.resources.insert(resource);
    }

    pub fn initResource(self: *Self, comptime T: type) void {
        _ = self.resources.initResource(T);
    }

    pub fn removeResource(self: *Self, comptime T: type) void {
        self.resources.remove(T);
    }
};
