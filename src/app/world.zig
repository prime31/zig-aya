const std = @import("std");
const aya = @import("../aya.zig");
const ecs = @import("ecs");
const flecs = ecs.c;

const Allocator = std.mem.Allocator;
const Resources = aya.Resources;

pub const World = struct {
    const Self = @This();

    ecs: *flecs.ecs_world_t,
    resources: Resources,

    pub fn init(allocator: Allocator) Self {
        return .{
            .ecs = flecs.ecs_init().?,
            .resources = Resources.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        _ = flecs.ecs_fini(self.ecs);
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

    pub fn getResource(self: *Self, comptime T: type) ?*T {
        self.resources.get(T);
    }
};
