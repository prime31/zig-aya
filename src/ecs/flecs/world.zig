// NOTE: after regenerating c.zig this needs to be added and comment out the `struct_ecs_world_t` declaration.
// replace with `pub const ecs_world_t = @import("world.zig").ecs_world_t;`
const std = @import("std");
const c = @import("flecs.zig");
const meta = @import("../meta.zig");
const ecs = @import("../mod.zig");

const FlecsOrderByAction = fn (c.ecs_entity_t, ?*const anyopaque, c.ecs_entity_t, ?*const anyopaque) callconv(.C) c_int;

const Entity = ecs.Entity;
const Filter = ecs.Filter;
const Query = ecs.Query;
const Iterator = ecs.Iterator;

pub const ecs_world_t = opaque {
    const Self = @This();

    pub fn deinit(self: *Self) void {
        _ = c.ecs_fini(self);
    }

    pub fn setTargetFps(self: *Self, fps: f32) void {
        c.ecs_set_target_fps(self, fps);
    }

    /// available at: https://flecs.dev/explorer
    /// debug check if its running: http://localhost:27750/entity/flecs/core/World
    pub fn enableWebExplorer(self: *Self) void {
        c.FlecsMonitorImport(self);
        _ = c.ecs_set_id(self, c.FLECS_IDEcsRestID_, c.FLECS_IDEcsRestID_, @sizeOf(c.EcsRest), &std.mem.zeroes(c.EcsRest));
    }

    /// -1 log level turns off logging
    pub fn setLogLevel(_: Self, level: c_int, enable_colors: bool) void {
        _ = c.ecs_log_set_level(level);
        _ = c.ecs_log_enable_colors(enable_colors);
    }

    pub fn progress(self: *Self, delta_time: f32) void {
        _ = c.ecs_progress(self, delta_time);
    }

    pub fn getTypeStr(self: *Self, typ: c.ecs_type_t) [*c]u8 {
        return c.ecs_type_str(self, typ);
    }

    pub fn newId(self: *Self) u64 {
        return c.ecs_new_id(self);
    }

    /// accepts an entity id (u64) or a Type and returns it wrapped in an Entity
    pub fn getEntity(self: *Self, entity_or_type: anytype) Entity {
        std.debug.assert(@TypeOf(entity_or_type) == u64 or @typeInfo(@TypeOf(entity_or_type)) == .Type);

        if (@typeInfo(@TypeOf(entity_or_type)) == .Type)
            return Entity.init(self, self.componentId(entity_or_type));
        return Entity.init(self, entity_or_type);
    }

    pub fn newEntity(self: *Self) Entity {
        return Entity.init(self, c.ecs_new_id(self));
    }

    pub fn newEntityNamed(self: *Self, name: [*c]const u8) Entity {
        var desc = std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = name });
        return Entity.init(self, c.ecs_entity_init(self, &desc));
    }

    pub fn lookup(self: *Self, path: [:0]const u8) ?Entity {
        const entity = c.ecs_lookup(self, path);
        if (entity != 0) return Entity.init(self, entity);
        return null;
    }

    pub fn lookupFullPath(self: *Self, path: [:0]const u8) ?Entity {
        const entity = c.ecs_lookup_path_w_sep(self, 0, path, ".", null, true);
        if (entity != 0) return Entity.init(self, entity);
        return null;
    }

    pub fn newPrefab(self: *Self, name: [*c]const u8) c.Entity {
        var desc = std.mem.zeroInit(c.ecs_entity_desc_t, .{
            .name = name,
            .add = [_]c.ecs_id_t{0} ** 32,
        });
        desc.add[0] = c.EcsPrefab;
        return Entity.init(self, c.ecs_entity_init(self, &desc));
    }

    /// Allowed params: Entity, u64 (entity_id), type
    pub fn pair(self: *Self, relation: anytype, object: anytype) u64 {
        const Relation = @TypeOf(relation);
        const Object = @TypeOf(object);

        const rel_info = @typeInfo(Relation);
        const obj_info = @typeInfo(Object);

        std.debug.assert(rel_info == .Struct or rel_info == .Type or Relation == u64 or Relation == Entity or Relation == c_int);
        std.debug.assert(obj_info == .Struct or obj_info == .Type or Object == u64 or Object == Entity);

        const rel_id = switch (Relation) {
            c_int => @as(u64, @intCast(relation)),
            type => self.componentId(relation),
            u64 => relation,
            Entity => relation.id,
            else => unreachable,
        };

        const obj_id = switch (Object) {
            type => self.componentId(object),
            u64 => object,
            Entity => object.id,
            else => unreachable,
        };

        return c.ECS_PAIR | (rel_id << @as(u32, 32)) + @as(u32, @truncate(obj_id));
    }

    pub fn addPair(self: *Self, entity: u64, relation: anytype, object: anytype) void {
        c.ecs_add_id(self, entity, self.pair(self, relation, object));
    }

    pub fn hasPair(self: *Self, entity: u64, relation: anytype, object: anytype) bool {
        return c.ecs_has_id(self, entity, self.pair(relation, object));
    }

    /// bulk registers a tuple of Types
    pub fn registerComponents(self: *Self, types: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(types)) == .Struct);
        inline for (types) |t| _ = self.componentId(t);
    }

    /// if T is a registered type returns the entity id else asserts
    pub fn typeId(_: *Self, comptime T: type) u64 {
        return perTypeGlobalStructPtr(T).*;
    }

    /// TODO: rename. T isnt always a component, it can be a tag
    /// gets the EntityId for T creating it if it doesn't already exist
    pub fn componentId(self: *Self, comptime T: type) u64 {
        const type_id_ptr = perTypeGlobalStructPtr(T);
        if (type_id_ptr.* != 0)
            return type_id_ptr.*;

        if (@sizeOf(T) == 0) {
            var desc = std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = @typeName(T) });
            type_id_ptr.* = c.ecs_entity_init(self, &desc);
        } else {
            type_id_ptr.* = c.ecs_component_init(self, &std.mem.zeroInit(c.ecs_component_desc_t, .{
                .entity = c.ecs_entity_init(self, &std.mem.zeroInit(c.ecs_entity_desc_t, .{
                    .use_low_id = true,
                    .name = @typeName(T),
                    .symbol = @typeName(T),
                })),
                .type = .{
                    .alignment = @alignOf(T),
                    .size = @sizeOf(T),
                },
            }));
        }

        // allow disabling reflection data with a root bool
        if (!@hasDecl(@import("root"), "disable_reflection") or !@as(bool, @field(@import("root"), "disable_reflection")))
            meta.registerReflectionData(self, T, type_id_ptr.*);

        return type_id_ptr.*;
    }

    /// creates a new type entity, or finds an existing one. A type entity is an entity with the EcsType component. The name will be generated
    /// by adding the Ids of each component so that order doesnt matter.
    pub fn newType(self: *Self, comptime Types: anytype) u64 {
        var i: u64 = 0;
        inline for (Types) |T| {
            i += self.componentId(T);
        }

        const name = std.fmt.allocPrintZ(std.heap.c_allocator, "Type{d}", .{i}) catch unreachable;
        return self.newTypeWithName(name, Types);
    }

    /// creates a new type entity, or finds an existing one. A type entity is an entity with the EcsType component.
    pub fn newTypeWithName(self: *Self, name: [*c]const u8, comptime Types: anytype) u64 {
        var desc = std.mem.zeroes(c.ecs_type_desc_t);
        desc.entity = std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = name });

        inline for (Types, 0..) |T, i| {
            desc.ids[i] = self.componentId(T);
        }

        return c.ecs_type_init(self, &desc);
    }

    pub fn newTypeExpr(self: *Self, name: [*c]const u8, expr: [*c]const u8) u64 {
        var desc = std.mem.zeroInit(c.ecs_type_desc_t, .{ .ids_expr = expr });
        desc.entity = std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = name });

        return c.ecs_type_init(self, &desc);
    }

    /// removes the entity from the Ecs
    pub fn delete(self: *Self, entity: u64) void {
        c.ecs_delete(self, entity);
    }

    /// deletes all entities with the component
    pub fn deleteWith(self: *Self, comptime T: type) void {
        c.ecs_delete_with(self, self.componentId(T));
    }

    /// remove all instances of the specified component
    pub fn removeAll(self: *Self, comptime T: type) void {
        c.ecs_remove_all(self, self.componentId(T));
    }

    pub fn setSingleton(self: *Self, ptr_or_struct: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer or @typeInfo(@TypeOf(ptr_or_struct)) == .Struct);

        const T = meta.FinalChild(@TypeOf(ptr_or_struct));
        var component = if (@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer) ptr_or_struct else &ptr_or_struct;
        _ = c.ecs_set_id(self, self.componentId(T), self.componentId(T), @sizeOf(T), component);
    }

    pub fn getSingleton(self: *Self, comptime T: type) ?*const T {
        std.debug.assert(@typeInfo(T) == .Struct);

        var val = c.ecs_get_id(self, self.componentId(T), self.componentId(T));
        if (val == null) return null;
        return @as(*const T, @ptrCast(@alignCast(val)));
    }

    pub fn getSingletonMut(self: *Self, comptime T: type) ?*T {
        std.debug.assert(@typeInfo(T) == .Struct);

        const val = c.ecs_get_mut_id(self, self.componentId(T), self.componentId(T)) orelse return null;
        return @as(*T, @ptrCast(@alignCast(val)));
    }

    pub fn removeSingleton(self: *Self, comptime T: type) void {
        std.debug.assert(@typeInfo(T) == .Struct);
        c.ecs_remove_id(self, self.componentId(T), self.componentId(T));
    }

    /// creates a Filter using the passed in struct
    pub fn filter(self: *Self, comptime Components: type) Filter(Components) {
        std.debug.assert(@typeInfo(Components) == .Struct);
        var desc = meta.generateFilterDesc(self, Components);
        return Filter(Components).init(self, &desc);
    }

    /// creates a Query using the passed in struct
    pub fn query(self: *Self, comptime Components: type) Query(Components) {
        std.debug.assert(@typeInfo(Components) == .Struct);
        return Query(Components).init(self);
    }

    /// adds an observer system to the Ecs using the passed in struct (see systems)
    pub fn observer(self: *Self, comptime Components: type, event: u64) void {
        std.debug.assert(@typeInfo(Components) == .Struct);
        std.debug.assert(@hasDecl(Components, "run"));
        std.debug.assert(@hasDecl(Components, "name"));

        var entity_desc = std.mem.zeroes(c.ecs_entity_desc_t);
        entity_desc.id = c.ecs_new_id(self);
        entity_desc.name = Components.name;
        entity_desc.add[0] = event;

        var desc = std.mem.zeroes(c.ecs_observer_desc_t);
        desc.entity = c.ecs_entity_init(self, &entity_desc);
        desc.events[0] = event;

        desc.run = wrapSystemFn(Components, Components.run);
        desc.filter = meta.generateFilterDesc(self, Components);

        if (@hasDecl(Components, "instanced") and Components.instanced) desc.filter.instanced = true;

        _ = c.ecs_observer_init(self, &desc);
    }
};

/// registered component handle cache. Stores the EntityId for the type.
fn PerTypeGlobalStruct(comptime _: type) type {
    return struct {
        var id: u64 = 0;
    };
}

inline fn perTypeGlobalStructPtr(comptime T: type) *u64 {
    return comptime &PerTypeGlobalStruct(T).id;
}

fn wrapSystemFn(comptime T: type, comptime cb: fn (*Iterator(T)) void) fn ([*c]c.ecs_iter_t) callconv(.C) void {
    const Closure = struct {
        pub var callback: *const fn (*Iterator(T)) void = cb;

        pub fn closure(it: [*c]c.ecs_iter_t) callconv(.C) void {
            var iterator = Iterator(T).init(it, c.ecs_iter_next);
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
