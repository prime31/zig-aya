const std = @import("std");
const locals = @import("locals.zig");
const aya = @import("../aya.zig");
const ecs = @import("ecs");
const c = ecs.c;

const Allocator = std.mem.Allocator;
const Resources = aya.Resources;
const LocalServer = locals.LocalServer;

pub const World = struct {
    const Self = @This();

    ecs: *c.ecs_world_t,
    resources: Resources,
    locals: LocalServer,

    pub fn init(allocator: Allocator) Self {
        return .{
            .ecs = c.ecs_init().?,
            .resources = Resources.init(allocator),
            .locals = LocalServer.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        _ = c.ecs_fini(self.ecs);
        self.resources.deinit();
        self.locals.deinit();
    }

    // Resources
    pub fn insertResource(self: *Self, resource: anytype) void {
        self.resources.insert(resource);
    }

    pub fn initResource(self: *Self, comptime T: type) void {
        _ = self.resources.initResource(T);
    }

    pub fn containsResource(self: *Self, comptime T: type) bool {
        return self.resources.contains(T);
    }

    pub fn removeResource(self: *Self, comptime T: type) void {
        self.resources.remove(T);
    }

    pub fn getResource(self: *Self, comptime T: type) ?*const T {
        return self.resources.get(T);
    }

    pub fn getResourceMut(self: *Self, comptime T: type) ?*T {
        return self.resources.get(T);
    }
};
