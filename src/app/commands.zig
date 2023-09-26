const std = @import("std");
const c = @import("ecs").c;
const app = @import("mod.zig");

const systems = @import("systems.zig");

const Entity = app.Entity;

pub const Commands = struct {
    ecs: *c.ecs_world_t,

    pub fn init(ecs: *c.ecs_world_t) Commands {
        return .{ .ecs = ecs };
    }

    pub fn newId(self: Commands) u64 {
        return c.ecs_new_id(self.ecs);
    }

    pub fn newEntity(self: Commands) Entity {
        return Entity.init(self, c.ecs_new_id(self));
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
        return systems.addSystem(self.ecs, 0, T);
    }

    pub fn runSystem(self: Commands, system: u64) void {
        _ = self;
        // self.deferred_systems.append(system) catch unreachable;
        std.debug.print("--- runSystem: {}\n", .{system});
        // _ = c.ecs_run(self.ecs, system, 0, null);
    }
};
