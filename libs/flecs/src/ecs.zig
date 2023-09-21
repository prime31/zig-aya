const std = @import("std");
pub const c = @import("flecs.zig");
const meta = @import("meta.zig");

pub usingnamespace @import("queries/mod.zig");

pub const Entity = @import("entity.zig").Entity;
pub const Type = @import("type.zig").Type;

pub const SystemSort = struct {
    phase: u64,
    order_in_phase: i32 = 0,
};

pub fn SYSTEM(world: *c.ecs_world_t, name: [*:0]const u8, phase: c.ecs_entity_t, order_in_phase: i32, system_desc: *c.ecs_system_desc_t) void {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = name;
    entity_desc.add[0] = world.componentId(SystemSort);
    entity_desc.add[1] = phase;
    entity_desc.add[2] = if (phase != 0) c.ecs_make_pair(c.EcsDependsOn, phase) else 0; // required for disabling systems by phase

    system_desc.entity = c.ecs_entity_init(world, &entity_desc);
    _ = c.ecs_system_init(world, system_desc);

    _ = c.ecs_set_id(world, system_desc.entity, world.componentId(SystemSort), @sizeOf(SystemSort), &SystemSort{
        .phase = phase,
        .order_in_phase = order_in_phase,
    });
}

pub fn OBSERVER(world: *c.ecs_world_t, name: [*:0]const u8, observer_desc: *c.ecs_observer_desc_t) void {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = name;

    observer_desc.entity = c.ecs_entity_init(world, &entity_desc);
    _ = c.ecs_observer_init(world, observer_desc);
}

/// returns the field at index
pub fn field(iter: [*c]const c.ecs_iter_t, comptime T: type, index: i32) []T {
    var col = c.ecs_field_w_size(iter, @sizeOf(T), index);
    const ptr = @as([*]T, @ptrCast(@alignCast(col)));
    return ptr[0..@intCast(iter.*.count)];
}

/// returns null in the case of column not being present or an invalid index
pub fn fieldOpt(iter: [*c]const c.ecs_iter_t, comptime T: type, index: i32) ?[]T {
    if (index <= 0) return null;
    var col = c.ecs_field_w_size(iter, @sizeOf(T), index);
    if (col == null) return null;
    const ptr = @as([*]T, @ptrCast(@alignCast(col)));
    return ptr[0..@intCast(iter.*.count)];
}

/// gets a pointer to a type if the component is present on the entity
pub fn get(world: *c.ecs_world_t, entity: u64, comptime T: type) ?*const T {
    const ptr = c.ecs_get_id(world, entity, world.componentId(T));
    if (ptr) |p| {
        return @as(*const T, @ptrCast(@alignCast(p)));
    }
    return null;
}

pub fn getMut(world: *c.ecs_world_t, entity: u64, comptime T: type) ?*T {
    var is_added = false;
    var ptr = c.ecs_get_mut_id(world, entity.id, world.componentId(T), &is_added);
    if (ptr) |p| {
        return @as(*T, @ptrCast(@alignCast(p)));
    }
    return null;
}

/// used when the Flecs API provides untyped data to convert to type. Query/system order_by callbacks are one example.
pub fn cast(comptime T: type, val: ?*const anyopaque) *const T {
    return @as(*const T, @ptrCast(@alignCast(val)));
}

pub fn castMut(comptime T: type, val: ?*anyopaque) *T {
    return @as(*T, @ptrCast(@alignCast(val)));
}

pub fn pairFirst(id: u64) u32 {
    return @as(u32, @truncate((id & c.ECS_COMPONENT_MASK) >> 32));
}

pub fn pairSecond(id: u64) u32 {
    return @as(u32, @truncate(id));
}

pub const OperKind = enum(c_int) {
    and_ = c.EcsAnd,
    or_ = c.EcsOr,
    not = c.EcsNot,
    optional = c.EcsOptional,
    and_from = c.EcsAndFrom,
    or_from = c.EcsOrFrom,
    not_from = c.EcsNotFrom,
};

pub const InOutKind = enum(c_int) {
    default = c.EcsInOutDefault, // in_out for regular terms, in for shared terms
    none = c.EcsInOutNone, // neither read nor written. Cannot have a query term.
    in_out = c.EcsInOut, // read/write
    in = c.EcsIn, // read only. Query term is const.
    out = c.EcsOut, // write only
};
