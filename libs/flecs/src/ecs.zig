const std = @import("std");
pub const c = @import("flecs.zig");
const meta = @import("meta.zig");

pub const SystemSort = struct {
    phase: u64,
    order_in_phase: c_int = 0,
};

pub fn COMPONENT(world: *c.ecs_world_t, comptime T: type) u64 {
    if (@sizeOf(T) == 0)
        @compileError("Size of the type must be greater than zero");

    const type_id_ptr = meta.perTypeGlobalStructPtr(T);
    if (type_id_ptr.* != 0)
        return type_id_ptr.*;

    // component_ids_hm.put(type_id_ptr, 0) catch @panic("OOM");

    type_id_ptr.* = c.ecs_component_init(world, &std.mem.zeroInit(c.ecs_component_desc_t, .{
        .entity = c.ecs_entity_init(world, &std.mem.zeroInit(c.ecs_entity_desc_t, .{
            .use_low_id = true,
            .name = meta.typeName(T),
            .symbol = meta.typeName(T),
        })),
        .type = .{
            .alignment = @alignOf(T),
            .size = @sizeOf(T),
        },
    }));
    return type_id_ptr.*;
}

pub fn TAG(world: *c.ecs_world_t, comptime T: type) void {
    if (@sizeOf(T) != 0)
        @compileError("Size of the type must be zero");

    const type_id_ptr = meta.perTypeGlobalStructPtr(T);
    if (type_id_ptr.* != 0)
        return;

    // component_ids_hm.put(type_id_ptr, 0) catch @panic("OOM");

    type_id_ptr.* = c.ecs_entity_init(world, &std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = @typeName(T) }));
}

pub fn SYSTEM(world: *c.ecs_world_t, name: [*:0]const u8, phase: c.ecs_entity_t, system_desc: *c.ecs_system_desc_t) void {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = name;
    entity_desc.add[0] = COMPONENT(world, SystemSort);
    entity_desc.add[1] = phase;
    // entity_desc.add[2] = if (phase != 0) c.ecs_make_pair(c.EcsDependsOn, phase) else 0; // only needed for startup systems

    system_desc.entity = c.ecs_entity_init(world, &entity_desc);
    _ = c.ecs_system_init(world, system_desc);

    _ = c.ecs_set_id(world, system_desc.entity, COMPONENT(world, SystemSort), @sizeOf(SystemSort), &SystemSort{
        .phase = phase,
    });
}

pub fn OBSERVER(world: *c.ecs_world_t, name: [*:0]const u8, observer_desc: *c.ecs_observer_desc_t) void {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = name;

    observer_desc.entity = c.ecs_entity_init(world, &entity_desc);
    _ = c.ecs_observer_init(world, observer_desc);
}

/// gets the EntityId for T creating it if it doesn't already exist
pub fn componentId(world: *c.ecs_world_t, comptime T: type) c.EntityId {
    return meta.componentId(world.world, T);
}

/// gets a pointer to a type if the component is present on the entity
pub fn get(world: *c.ecs_world_t, entity: u64, comptime T: type) ?*const T {
    const ptr = c.ecs_get_id(world, entity.id, meta.componentId(world, T));
    if (ptr) |p| {
        return @as(*const T, @ptrCast(@alignCast(p)));
    }
    return null;
}

pub fn getMut(world: *c.ecs_world_t, entity: u64, comptime T: type) ?*T {
    var is_added = false;
    var ptr = c.ecs_get_mut_id(world, entity.id, meta.componentId(world, T), &is_added);
    if (ptr) |p| {
        return @as(*T, @ptrCast(@alignCast(p)));
    }
    return null;
}

/// used when the Flecs API provides untyped data to convert to type. Query/system order_by callbacks are one example.
pub fn componentCast(comptime T: type, val: ?*const anyopaque) *const T {
    return @as(*const T, @ptrCast(@alignCast(val)));
}
