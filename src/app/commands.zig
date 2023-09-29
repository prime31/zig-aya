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

    pub fn pause(self: Commands, paused: bool) void {
        if (!paused) {
            self.removeAll(systems.SystemPaused);
            return;
        }

        var filter_desc = std.mem.zeroes(c.ecs_filter_desc_t);
        filter_desc.terms[0].id = c.EcsSystem;
        filter_desc.terms[0].inout = c.EcsInOutNone;
        filter_desc.terms[0].inout = c.EcsInOutNone;
        filter_desc.terms[1].id = self.ecs.componentId(systems.SystemSort); // match only systems in the core pipeline
        filter_desc.terms[1].inout = c.EcsIn;
        filter_desc.terms[2].id = self.ecs.componentId(systems.RunWhenPaused); // skip RunWhenPaused systems
        filter_desc.terms[2].inout = c.EcsInOutNone;
        filter_desc.terms[2].oper = c.EcsNot;
        filter_desc.terms[3].id = c.EcsDisabled; // make sure we match disabled systems
        filter_desc.terms[3].inout = c.EcsInOutNone;
        filter_desc.terms[3].oper = c.EcsOptional;

        const filter = c.ecs_filter_init(self.ecs, &filter_desc);
        defer c.ecs_filter_fini(filter);

        var it = c.ecs_filter_iter(self.ecs, filter);
        while (c.ecs_filter_next(&it)) {
            var i: usize = 0;
            while (i < it.count) : (i += 1) {
                _ = c.ecs_add_id(self.ecs, it.entities[i], self.ecs.componentId(systems.SystemPaused));
            }
        }
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
        c.ecs_run_post_frame(self.ecs, DeferredCreateSystem.createSystemPostFrame, deferred);

        return id;
    }

    /// runs a system after the current schedule completes
    pub fn runSystem(self: Commands, system: u64) void {
        _ = c.ecs_run(self.ecs, system, 0, null);
    }
};

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

    fn createSystemPostFrame(world: ?*c.ecs_world_t, ctx: ?*anyopaque) callconv(.C) void {
        const deferred = @as(*DeferredCreateSystem, @ptrFromInt(@intFromPtr(ctx.?)));
        deferred.createSystemFn(deferred, world.?);
    }
};
