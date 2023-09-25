const std = @import("std");
const aya = @import("../aya.zig");
const ecs = @import("ecs");
const c = ecs.c;

const Allocator = std.mem.Allocator;
const Resources = aya.Resources;

pub const World = struct {
    const Self = @This();

    ecs: *c.ecs_world_t,
    resources: Resources,

    pub fn init(allocator: Allocator) Self {
        return .{
            .ecs = c.ecs_init().?,
            .resources = Resources.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        _ = c.ecs_fini(self.ecs);
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

    pub fn getResource(self: *Self, comptime T: type) ?*const T {
        return self.resources.get(T);
    }

    pub fn getResourceMut(self: *Self, comptime T: type) ?*T {
        return self.resources.get(T);
    }

    // Systems
    /// registers a system that is not put in any phase and will only run when runSystem is called.
    pub fn registerSystem(self: *Self) u64 {
        _ = self;
        return 0;
    }

    pub fn runSystem(self: *Self, system: u64) u64 {
        _ = system;
        _ = self;
        return 0;
    }
};
