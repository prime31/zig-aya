const std = @import("std");
const aya = @import("../aya.zig");
const c = @import("../ecs/mod.zig").c;
const app = @import("mod.zig");

const systems = @import("systems.zig");

const Entity = aya.Entity;

pub const Commands = struct {
    ecs: *c.ecs_world_t,

    pub fn init(ecs: *c.ecs_world_t) Commands {
        return .{ .ecs = ecs };
    }

    pub fn newId(self: Commands) u64 {
        return c.ecs_new_id(self.ecs);
    }

    pub fn newEntity(self: Commands) Entity {
        return Entity.init(self.ecs, c.ecs_new_id(self.ecs));
    }

    pub fn newEntityNamed(self: Commands, name: [*c]const u8) Entity {
        var desc = std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = name });
        return Entity.init(self.ecs, c.ecs_entity_init(self.ecs, &desc));
    }

    /// removes the entity from the Ecs
    pub fn delete(self: Commands, entity: u64) void {
        c.ecs_delete(self.ecs, entity);
    }

    /// deletes all entities with the component
    pub fn deleteWith(self: Commands, comptime T: type) void {
        c.ecs_delete_with(self.ecs, self.ecs.componentId(T));
    }

    /// remove all instances of the specified component
    pub fn removeAll(self: Commands, comptime T: type) void {
        c.ecs_remove_all(self.ecs, self.ecs.componentId(T));
    }

    // Systems
    /// registers a system that is not put in any phase and will only run when runSystem is called.
    pub fn registerSystem(self: Commands, comptime T: type) u64 {
        const id = self.ecs.newId();

        const deferred = aya.tmp_allocator.create(DeferredCreateSystem) catch unreachable;
        deferred.* = DeferredCreateSystem.init(T, id);
        c.ecs_run_post_frame(self.ecs, createSystemPostFrame, deferred);

        return id;
    }

    /// runs a system AFTER the current schedule completes
    pub fn runSystem(self: Commands, system: u64) void {
        const deferred = aya.tmp_allocator.create(DeferredRunSystem) catch unreachable;
        deferred.* = DeferredRunSystem.init(system);
        c.ecs_run_post_frame(self.ecs, runSystemPostFrame, deferred);
    }
};

fn createSystemPostFrame(world: ?*c.ecs_world_t, ctx: ?*anyopaque) callconv(.C) void {
    const deferred = @as(*DeferredCreateSystem, @ptrFromInt(@intFromPtr(ctx.?)));
    deferred.createSystemFn(deferred, world.?);
}

fn runSystemPostFrame(world: ?*c.ecs_world_t, ctx: ?*anyopaque) callconv(.C) void {
    const deferred = @as(*DeferredRunSystem, @ptrFromInt(@intFromPtr(ctx.?)));
    deferred.runSystemFn(deferred, world.?);
}

const DeferredCreateSystem = struct {
    id: u64,
    createSystemFn: *const fn (*DeferredCreateSystem, *c.ecs_world_t) void,

    pub fn init(comptime T: type, id: u64) DeferredCreateSystem {
        return .{
            .id = id,
            .createSystemFn = struct {
                fn createSystemFn(self: *DeferredCreateSystem, ecs: *c.ecs_world_t) void {
                    _ = systems.addSystemToEntity(ecs, self.id, 0, T);
                }
            }.createSystemFn,
        };
    }
};

const DeferredRunSystem = struct {
    id: u64,
    runSystemFn: *const fn (*DeferredRunSystem, *c.ecs_world_t) void,

    pub fn init(id: u64) DeferredRunSystem {
        return .{
            .id = id,
            .runSystemFn = struct {
                fn runSystemFn(self: *DeferredRunSystem, ecs: *c.ecs_world_t) void {
                    _ = c.ecs_run(ecs, self.id, 0, null);
                }
            }.runSystemFn,
        };
    }
};
