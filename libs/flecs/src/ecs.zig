const std = @import("std");
pub const c = @import("flecs.zig");
const meta = @import("meta.zig");

pub const SystemSort = struct {
    phase: u64,
    order_in_phase: i32 = 0,
};

// meta.componentId from old repo handles zero or sized types
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

pub fn SYSTEM(world: *c.ecs_world_t, name: [*:0]const u8, phase: c.ecs_entity_t, order_in_phase: i32, system_desc: *c.ecs_system_desc_t) void {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = name;
    entity_desc.add[0] = COMPONENT(world, SystemSort);
    entity_desc.add[1] = phase;
    entity_desc.add[2] = if (phase != 0) c.ecs_make_pair(c.EcsDependsOn, phase) else 0; // required for disabling systems by phase

    system_desc.entity = c.ecs_entity_init(world, &entity_desc);
    _ = c.ecs_system_init(world, system_desc);

    _ = c.ecs_set_id(world, system_desc.entity, COMPONENT(world, SystemSort), @sizeOf(SystemSort), &SystemSort{
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

// is this used?
pub fn componentId(world: *c.ecs_world_t, comptime T: type) u64 {
    _ = T;
    _ = world;
    @panic("is this really used");
    // return meta.componentId(world, T);
}

/// returns the field at index
pub fn field(iter: [*c]const c.ecs_iter_t, comptime T: type, index: i32) [*]T {
    var col = c.ecs_field_w_size(iter, @sizeOf(T), index);
    return @as([*]T, @ptrCast(@alignCast(col)));
}

/// gets a pointer to a type if the component is present on the entity
pub fn get(world: *c.ecs_world_t, entity: u64, comptime T: type) ?*const T {
    const ptr = c.ecs_get_id(world, entity, COMPONENT(world, T));
    if (ptr) |p| {
        return @as(*const T, @ptrCast(@alignCast(p)));
    }
    return null;
}

pub fn getMut(world: *c.ecs_world_t, entity: u64, comptime T: type) ?*T {
    var is_added = false;
    var ptr = c.ecs_get_mut_id(world, entity.id, COMPONENT(world, T), &is_added);
    if (ptr) |p| {
        return @as(*T, @ptrCast(@alignCast(p)));
    }
    return null;
}

/// used when the Flecs API provides untyped data to convert to type. Query/system order_by callbacks are one example.
pub fn componentCast(comptime T: type, val: ?*const anyopaque) *const T {
    return @as(*const T, @ptrCast(@alignCast(val)));
}

/// Allowed params: u64 (entity_id), type
pub fn pair(self: *c.ecs_world_t, relation: anytype, object: anytype) u64 {
    _ = self;
    const Relation = @TypeOf(relation);
    const Object = @TypeOf(object);

    const rel_info = @typeInfo(Relation);
    const obj_info = @typeInfo(Object);

    std.debug.assert(rel_info == .Struct or rel_info == .Type or Relation == u64 or Relation == c_int);
    std.debug.assert(obj_info == .Struct or obj_info == .Type or Object == u64);

    const rel_id = switch (Relation) {
        c_int => @as(u64, @intCast(relation)),
        type => COMPONENT(relation),
        u64 => relation,
        else => unreachable,
    };

    const obj_id = switch (Object) {
        type => COMPONENT(object),
        u64 => object,
        else => unreachable,
    };

    return c.ECS_PAIR | (rel_id << @as(u32, 32)) + @as(u32, @truncate(obj_id));
}

pub fn addPair(world: *c.ecs_world_t, entity: u64, relation: anytype, object: anytype) void {
    c.ecs_add_id(world, entity, pair(world, relation, object));
}
