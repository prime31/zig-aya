const std = @import("std");
pub const c = @import("flecs.zig");
const meta = @import("meta.zig");
const ecs = @This();

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

// -------------  --  -------------
// -------------      -------------
// ------------- TEMP -------------
// -------------      -------------
// -------------  --  -------------

const FlecsOrderByAction = fn (c.ecs_entity_t, ?*const anyopaque, c.ecs_entity_t, ?*const anyopaque) callconv(.C) c_int;

fn dummyFn(_: [*c]ecs.c.ecs_iter_t) callconv(.C) void {}

pub fn _addSystem(world: *c.ecs_world_t, phase: u64, runFn: anytype) void {
    std.debug.assert(@typeInfo(@TypeOf(runFn)) == .Fn);

    var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
    entity_desc.id = c.ecs_new_id(world);
    entity_desc.add[0] = world.componentId(SystemSort);
    entity_desc.add[1] = phase;
    entity_desc.add[2] = if (phase != 0) c.ecs_make_pair(c.EcsDependsOn, phase) else 0; // required for disabling systems by phase

    // allowed params: *Iterator(T), Res(T), ResMut(T), *World
    const fn_info = @typeInfo(@TypeOf(runFn)).Fn;
    var system_desc: c.ecs_system_desc_t = inline for (fn_info.params) |param| {
        if (@typeInfo(param.type.?) == .Pointer) {
            const T = std.meta.Child(param.type.?);
            if (@hasDecl(T, "components_type")) {
                entity_desc.name = if (@hasDecl(T.components_type, "name")) T.components_type.name else @typeName(@TypeOf(runFn));

                var system_desc = std.mem.zeroes(c.ecs_system_desc_t);
                system_desc.callback = dummyFn;
                system_desc.entity = c.ecs_entity_init(world, &entity_desc);
                // desc.multi_threaded = true;
                system_desc.run = wrapSystemFn(T.components_type, T.components_type.run);
                system_desc.query.filter = meta.generateFilterDesc(world, T.components_type);

                if (@hasDecl(T.components_type, "order_by")) {
                    meta.validateOrderByFn(T.components_type.order_by);
                    const ti = @typeInfo(@TypeOf(T.components_type.order_by));
                    const OrderByType = meta.FinalChild(ti.Fn.params[1].type.?);
                    meta.validateOrderByType(T.components_type, OrderByType);

                    system_desc.query.order_by = wrapOrderByFn(OrderByType, T.components_type.order_by);
                    system_desc.query.order_by_component = world.componentId(OrderByType);
                }

                if (@hasDecl(T.components_type, "instanced") and T.components_type.instanced) system_desc.filter.instanced = true;
                break system_desc;
            }
        }
    } else blk: {
        var system_desc = std.mem.zeroes(c.ecs_system_desc_t);
        system_desc.callback = dummyFn;
        system_desc.entity = c.ecs_entity_init(world, &entity_desc);
        system_desc.run = newWrapSystemFn(runFn);
        system_desc.entity = c.ecs_entity_init(world, &entity_desc);

        break :blk system_desc;
    };

    _ = c.ecs_system_init(world, &system_desc);

    _ = c.ecs_set_id(world, system_desc.entity, world.componentId(SystemSort), @sizeOf(SystemSort), &SystemSort{
        .phase = phase,
        .order_in_phase = 666, //order_in_phase,
    });
}

fn newWrapSystemFn(comptime cb: anytype) fn ([*c]c.ecs_iter_t) callconv(.C) void {
    const Closure = struct {
        const callback = cb;

        pub fn closure(it: [*c]c.ecs_iter_t) callconv(.C) void {
            c.ecs_iter_fini(it);

            const Args = std.meta.ArgsTuple(@TypeOf(cb));
            var args: Args = undefined;

            inline for (@typeInfo(Args).Struct.fields) |f| {
                @field(args, f.name) = it.*.world.?.getSingletonMut(meta.FinalChild(f.type)).?;
            }

            @call(.always_inline, callback, args);
            // callback();
        }
    };
    return Closure.closure;
}

fn wrapSystemFn(comptime T: type, comptime cb: fn (*ecs.Iterator(T)) void) fn ([*c]c.ecs_iter_t) callconv(.C) void {
    const Closure = struct {
        pub var callback: *const fn (*ecs.Iterator(T)) void = cb;

        pub fn closure(it: [*c]c.ecs_iter_t) callconv(.C) void {
            var iterator = ecs.Iterator(T).init(it, c.ecs_iter_next);
            callback(&iterator);
        }
    };
    return Closure.closure;
}

fn wrapOrderByFn(comptime T: type, comptime cb: fn (u64, *const T, u64, *const T) c_int) FlecsOrderByAction {
    const Closure = struct {
        pub fn closure(e1: u64, c1: ?*const anyopaque, e2: u64, c2: ?*const anyopaque) callconv(.C) c_int {
            return @call(.always_inline, cb, .{ e1, @as(*const T, @ptrCast(@alignCast(c1))), e2, @as(*const T, @ptrCast(@alignCast(c2))) });
        }
    };
    return Closure.closure;
}
