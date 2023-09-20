const std = @import("std");
const aya = @import("../aya.zig");
const ecs = @import("ecs");
const flecs = ecs.c;

const Allocator = std.mem.Allocator;
const Resources = aya.Resources;

pub const AppWorld = struct {
    const Self = @This();

    ecs_world: ecs.EcsWorld,
    resources: Resources,

    pub fn init(allocator: Allocator) Self {
        return .{
            .ecs_world = ecs.EcsWorld.init(),
            .resources = Resources.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.ecs_world.deinit();
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
        return self.resources.get(T);
    }
};
