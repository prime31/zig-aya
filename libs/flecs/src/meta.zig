const std = @import("std");
const flecs = @import("flecs.zig");
const meta = @import("meta.zig");

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

/// registered component handle cache. Stores the EntityId for the type.
fn PerTypeGlobalStruct(comptime _: type) type {
    return struct {
        var id: u64 = 0;
    };
}

pub inline fn perTypeGlobalStructPtr(comptime T: type) *u64 {
    return comptime &PerTypeGlobalStruct(T).id;
}

/// gets the EntityId for T creating it if it doesn't already exist
pub fn componentId(world: *flecs.c.ecs_world_t, comptime T: type) flecs.EntityId {
    var handle = perTypeGlobalStructPtr(T);
    if (handle.* < std.math.maxInt(flecs.EntityId)) {
        return handle.*;
    }

    if (@sizeOf(T) == 0) {
        var desc = std.mem.zeroInit(flecs.c.ecs_entity_desc_t, .{ .name = @typeName(T) });
        handle.* = flecs.c.ecs_entity_init(world, &desc);
    } else {
        var desc = std.mem.zeroInit(flecs.c.ecs_component_desc_t, .{
            .entity = std.mem.zeroInit(flecs.c.ecs_entity_desc_t, .{ .name = @typeName(T) }),
            .size = @sizeOf(T),
            .alignment = @alignOf(T),
        });
        handle.* = flecs.c.ecs_component_init(world, &desc);
    }

    // allow disabling reflection data with a root bool
    if (!@hasDecl(@import("root"), "disable_reflection") or !@as(bool, @field(@import("root"), "disable_reflection")))
        registerReflectionData(world, T, handle.*);

    return handle.*;
}

/// https://github.com/SanderMertens/flecs/tree/master/examples/c/reflection
fn registerReflectionData(world: *flecs.c.ecs_world_t, comptime T: type, entity: flecs.EntityId) void {
    var entityDesc = std.mem.zeroInit(flecs.c.ecs_entity_desc_t, .{ .entity = entity });
    var desc = std.mem.zeroInit(flecs.c.ecs_struct_desc_t, .{ .entity = entityDesc });

    switch (@typeInfo(T)) {
        .Struct => |si| {
            // tags have no size so ignore them
            if (@sizeOf(T) == 0) return;

            inline for (si.fields, 0..) |field, i| {
                var member = std.mem.zeroes(flecs.c.ecs_member_t);
                member.name = field.name.ptr;

                // TODO: support nested structs
                member.type = switch (field.field_type) {
                    // Struct => componentId(field.field_type),
                    bool => flecs.c.FLECS__Eecs_bool_t,
                    f32 => flecs.c.FLECS__Eecs_f32_t,
                    f64 => flecs.c.FLECS__Eecs_f64_t,
                    u8 => flecs.c.FLECS__Eecs_u8_t,
                    u16 => flecs.c.FLECS__Eecs_u16_t,
                    u32 => flecs.c.FLECS__Eecs_u32_t,
                    flecs.EntityId => blk: {
                        // bit of a hack, but if the field name has "entity" in it we consider it an Entity reference
                        if (std.mem.indexOf(u8, field.name, "entity") != null)
                            break :blk flecs.c.FLECS__Eecs_entity_t;
                        break :blk flecs.c.FLECS__Eecs_u64_t;
                    },
                    i8 => flecs.c.FLECS__Eecs_i8_t,
                    i16 => flecs.c.FLECS__Eecs_i16_t,
                    i32 => flecs.c.FLECS__Eecs_i32_t,
                    i64 => flecs.c.FLECS__Eecs_i64_t,
                    usize => flecs.c.FLECS__Eecs_uptr_t,
                    []const u8 => flecs.c.FLECS__Eecs_string_t,
                    [*]const u8 => flecs.c.FLECS__Eecs_string_t,
                    else => switch (@typeInfo(field.field_type)) {
                        .Pointer => flecs.c.FLECS__Eecs_uptr_t,

                        .Struct => componentId(world, field.field_type),

                        .Enum => blk: {
                            var enum_desc = std.mem.zeroes(flecs.c.ecs_enum_desc_t);
                            enum_desc.entity.entity = meta.componentHandle(T).*;

                            inline for (@typeInfo(field.field_type).Enum.fields, 0..) |f, index| {
                                enum_desc.constants[index] = std.mem.zeroInit(flecs.c.ecs_enum_constant_t, .{
                                    .name = f.name.ptr,
                                    .value = @as(i32, @intCast(f.value)),
                                });
                            }

                            break :blk flecs.c.ecs_enum_init(world, &enum_desc);
                        },

                        else => {
                            std.debug.print("unhandled field type: {any}, ti: {any}\n", .{ field.field_type, @typeInfo(field.field_type) });
                            unreachable;
                        },
                    },
                };
                desc.members[i] = member;
            }
            _ = flecs.c.ecs_struct_init(world, &desc);
        },
        else => unreachable,
    }
}
