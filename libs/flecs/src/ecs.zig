const std = @import("std");
pub const c = @import("flecs.zig");

// flecs internally reserves names like u16, u32, f32, etc. so we re-map them to uppercase to avoid collisions
pub fn typeName(comptime T: type) @TypeOf(@typeName(T)) {
    return switch (T) {
        u8 => return "U8",
        u16 => return "U16",
        u32 => return "U32",
        u64 => return "U64",
        i8 => return "I8",
        i16 => return "I16",
        i32 => return "I32",
        i64 => return "I64",
        f32 => return "F32",
        f64 => return "F64",
        else => return @typeName(T),
    };
}

fn PerTypeGlobalVar(comptime _: type) type {
    return struct {
        var id: u64 = 0;
    };
}

inline fn perTypeGlobalVarPtr(comptime T: type) *u64 {
    return comptime &PerTypeGlobalVar(T).id;
}

pub fn COMPONENT(world: *c.ecs_world_t, comptime T: type) void {
    if (@sizeOf(T) == 0)
        @compileError("Size of the type must be greater than zero");

    const type_id_ptr = perTypeGlobalVarPtr(T);
    if (type_id_ptr.* != 0)
        return;

    // component_ids_hm.put(type_id_ptr, 0) catch @panic("OOM");

    type_id_ptr.* = c.ecs_component_init(world, &std.mem.zeroInit(c.ecs_component_desc_t, .{
        .entity = c.ecs_entity_init(world, &std.mem.zeroInit(c.ecs_entity_desc_t, .{
            .use_low_id = true,
            .name = typeName(T),
            .symbol = typeName(T),
        })),
        .type = .{
            .alignment = @alignOf(T),
            .size = @sizeOf(T),
        },
    }));
}

pub fn TAG(world: *c.ecs_world_t, comptime T: type) void {
    if (@sizeOf(T) != 0)
        @compileError("Size of the type must be zero");

    const type_id_ptr = perTypeGlobalVarPtr(T);
    if (type_id_ptr.* != 0)
        return;

    // component_ids_hm.put(type_id_ptr, 0) catch @panic("OOM");

    type_id_ptr.* = c.ecs_entity_init(world, &std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = @typeName(T) }));
}

pub fn SYSTEM(world: *c.ecs_world_t, name: [*:0]const u8, phase: c.ecs_entity_t, system_desc: *c.ecs_system_desc_t) void {
    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = name;
    entity_desc.add[0] = if (phase != 0) c.ecs_make_pair(c.EcsDependsOn, phase) else 0;
    entity_desc.add[1] = phase;

    system_desc.entity = c.ecs_entity_init(world, &entity_desc);
    _ = c.ecs_system_init(world, system_desc);
}

pub fn OBSERVER(world: *c.ecs_world_t, name: [*:0]const u8, observer_desc: *c.ecs_observer_desc_t) void {
    var entity_desc = c.ecs_entity_desc_t{};
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.name = name;

    observer_desc.entity = c.ecs_entity_init(world, &entity_desc);
    _ = c.ecs_observer_init(world, observer_desc);
}
