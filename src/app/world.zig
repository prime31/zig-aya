const std = @import("std");
const locals = @import("locals.zig");
const aya = @import("../aya.zig");
const c = aya.c;

const Allocator = std.mem.Allocator;
const Resources = aya.Resources;
const LocalServer = locals.LocalResources;

pub const World = struct {
    const Self = @This();

    ecs: *c.ecs_world_t,
    resources: Resources,
    locals: LocalServer,

    pub fn init(allocator: Allocator) Self {
        _ = allocator;
        return .{
            .ecs = c.ecs_init().?,
            .resources = Resources.init(),
            .locals = LocalServer.init(),
        };
    }

    pub fn deinit(self: *Self) void {
        self.resources.deinit();
        self.locals.deinit();
        _ = c.ecs_fini(self.ecs); // must be last! we could have Flecs objects present in resources or locals
    }

    pub fn progress(self: Self, delta_time: f32) void {
        _ = c.ecs_progress(self.ecs, delta_time);
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
