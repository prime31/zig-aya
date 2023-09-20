// this file name is dumb and was only made because ecs.zig was used. change this!
const std = @import("std");
const ecs = @import("ecs.zig");
const meta = @import("meta.zig");
const flecs = ecs.c;

const Entity = @import("entity.zig").Entity;
const FlecsOrderByAction = fn (flecs.ecs_entity_t, ?*const anyopaque, flecs.ecs_entity_t, ?*const anyopaque) callconv(.C) c_int;

fn dummyFn(_: [*c]flecs.ecs_iter_t) callconv(.C) void {}

pub const EcsWorld = struct {
    world: *flecs.ecs_world_t,

    pub fn init() EcsWorld {
        return .{ .world = flecs.ecs_init().? };
    }

    pub fn deinit(self: *EcsWorld) void {
        _ = flecs.ecs_fini(self.world);
    }

    pub fn setTargetFps(self: EcsWorld, fps: f32) void {
        flecs.ecs_set_target_fps(self.world, fps);
    }

    /// available at: https://www.flecs.dev/explorer/?remote=true
    /// test if running: http://localhost:27750/entity/flecs
    pub fn enableWebExplorer(self: EcsWorld) void {
        _ = flecs.ecs_set_id(self.world, flecs.FLECS__EEcsRest, flecs.FLECS__EEcsRest, @sizeOf(flecs.EcsRest), &std.mem.zeroes(flecs.EcsRest));
    }

    /// -1 log level turns off logging
    pub fn setLogLevel(_: EcsWorld, level: c_int, enable_colors: bool) void {
        _ = flecs.ecs_log_set_level(level);
        _ = flecs.ecs_log_enable_colors(enable_colors);
    }

    pub fn progress(self: EcsWorld, delta_time: f32) void {
        _ = flecs.ecs_progress(self.world, delta_time);
    }

    pub fn getTypeStr(self: EcsWorld, typ: flecs.ecs_type_t) [*c]u8 {
        return flecs.ecs_type_str(self.world, typ);
    }

    pub fn newEntity(self: EcsWorld) Entity {
        return Entity.init(self.world, flecs.ecs_new_id(self.world));
    }

    pub fn newEntityWithName(self: EcsWorld, name: [*c]const u8) Entity {
        var desc = std.mem.zeroInit(flecs.ecs_entity_desc_t, .{ .name = name });
        return Entity.init(self.world, flecs.ecs_entity_init(self.world, &desc));
    }

    pub fn newPrefab(self: EcsWorld, name: [*c]const u8) flecs.Entity {
        var desc = std.mem.zeroInit(flecs.ecs_entity_desc_t, .{
            .name = name,
            .add = [_]flecs.ecs_id_t{0} ** 32,
        });
        desc.add[0] = flecs.EcsPrefab;
        return Entity.init(self.world, flecs.ecs_entity_init(self.world, &desc));
    }

    /// Allowed params: Entity, EntityId, type
    pub fn pair(self: EcsWorld, relation: anytype, object: anytype) u64 {
        const Relation = @TypeOf(relation);
        const Object = @TypeOf(object);

        const rel_info = @typeInfo(Relation);
        const obj_info = @typeInfo(Object);

        std.debug.assert(rel_info == .Struct or rel_info == .Type or Relation == flecs.EntityId or Relation == flecs.Entity or Relation == c_int);
        std.debug.assert(obj_info == .Struct or obj_info == .Type or Object == flecs.EntityId or Object == flecs.Entity);

        const rel_id = switch (Relation) {
            c_int => @as(flecs.EntityId, @intCast(relation)),
            type => self.componentId(relation),
            flecs.EntityId => relation,
            flecs.Entity => relation.id,
            else => unreachable,
        };

        const obj_id = switch (Object) {
            type => self.componentId(object),
            flecs.EntityId => object,
            flecs.Entity => object.id,
            else => unreachable,
        };

        return flecs.ECS_PAIR | (rel_id << @as(u32, 32)) + @as(u32, @truncate(obj_id));
    }

    /// bulk registers a tuple of Types
    pub fn registerComponents(self: EcsWorld, types: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(types)) == .Struct);
        inline for (types) |t| _ = self.componentId(t);
    }

    /// gets the EntityId for T creating it if it doesn't already exist
    pub fn componentId(self: EcsWorld, comptime T: type) u64 {
        return meta.componentId(self.world, T);
    }

    /// creates a new type entity, or finds an existing one. A type entity is an entity with the EcsType component. The name will be generated
    /// by adding the Ids of each component so that order doesnt matter.
    pub fn newType(self: EcsWorld, comptime Types: anytype) flecs.EntityId {
        var i: flecs.EntityId = 0;
        inline for (Types) |T| {
            i += self.componentId(T);
        }

        const name = std.fmt.allocPrintZ(std.heap.c_allocator, "Type{d}", .{i}) catch unreachable;
        return self.newTypeWithName(name, Types);
    }

    /// creates a new type entity, or finds an existing one. A type entity is an entity with the EcsType component.
    pub fn newTypeWithName(self: EcsWorld, name: [*c]const u8, comptime Types: anytype) flecs.EntityId {
        var desc = std.mem.zeroes(flecs.ecs_type_desc_t);
        desc.entity = std.mem.zeroInit(flecs.ecs_entity_desc_t, .{ .name = name });

        inline for (Types, 0..) |T, i| {
            desc.ids[i] = self.componentId(T);
        }

        return flecs.ecs_type_init(self.world, &desc);
    }

    pub fn newTypeExpr(self: EcsWorld, name: [*c]const u8, expr: [*c]const u8) flecs.EntityId {
        var desc = std.mem.zeroInit(flecs.ecs_type_desc_t, .{ .ids_expr = expr });
        desc.entity = std.mem.zeroInit(flecs.ecs_entity_desc_t, .{ .name = name });

        return flecs.ecs_type_init(self.world, &desc);
    }

    // pub fn newSystem(self: Ecs, name: [*c]const u8, phase: flecs.Phase, signature: [*c]const u8, action: flecs.ecs_iter_action_t) void {
    //     var desc = std.mem.zeroes(flecs.ecs_system_desc_t);
    //     desc.entity.name = name;
    //     desc.entity.add[0] = @intFromEnum(phase);
    //     desc.query.filter.expr = signature;
    //     // desc.multi_threaded = true;
    //     desc.callback = action;
    //     _ = flecs.ecs_system_init(self.ecs, &desc);
    // }

    // pub fn newRunSystem(self: Ecs, name: [*c]const u8, phase: flecs.Phase, signature: [*c]const u8, action: flecs.ecs_iter_action_t) void {
    //     var desc = std.mem.zeroes(flecs.ecs_system_desc_t);
    //     desc.entity.name = name;
    //     desc.entity.add[0] = @intFromEnum(phase);
    //     desc.query.filter.expr = signature;
    //     // desc.multi_threaded = true;
    //     desc.callback = dummyFn;
    //     desc.run = action;
    //     _ = flecs.ecs_system_init(self.ecs, &desc);
    // }

    // pub fn newWrappedRunSystem(self: Ecs, name: [*c]const u8, phase: flecs.Phase, comptime Components: type, comptime action: fn (*flecs.Iterator(Components)) void) void {
    //     var desc = std.mem.zeroes(flecs.ecs_system_desc_t);
    //     desc.entity.name = name;
    //     desc.entity.add[0] = @intFromEnum(phase);
    //     desc.query.filter = meta.generateFilterDesc(self, Components);
    //     // desc.multi_threaded = true;
    //     desc.callback = dummyFn;
    //     desc.run = wrapSystemFn(Components, action);
    //     _ = flecs.ecs_system_init(self.ecs, &desc);
    // }

    /// creates a Filter using the passed in struct
    pub fn filter(self: EcsWorld, comptime Components: type) ecs.Filter {
        std.debug.assert(@typeInfo(Components) == .Struct);
        var desc = meta.generateFilterDesc(self, Components);
        return ecs.Filter.init(self, &desc);
    }

    // /// probably temporary until we find a better way to handle it, but a way to
    // /// iterate the passed components of children of the parent entity
    // pub fn filterParent(self: Ecs, comptime Components: type, parent: flecs.Entity) flecs.Filter {
    //     std.debug.assert(@typeInfo(Components) == .Struct);
    //     var desc = meta.generateFilterDesc(self, Components);
    //     const component_info = @typeInfo(Components).Struct;
    //     desc.terms[component_info.fields.len].id = self.pair(flecs.EcsChildOf, parent);
    //     return flecs.Filter.init(self, &desc);
    // }

    /// creates a Query using the passed in struct
    pub fn query(self: EcsWorld, comptime Components: type) ecs.Query {
        std.debug.assert(@typeInfo(Components) == .Struct);
        var desc = std.mem.zeroes(flecs.ecs_query_desc_t);
        desc.filter = meta.generateFilterDesc(self, Components);

        if (@hasDecl(Components, "order_by")) {
            meta.validateOrderByFn(Components.order_by);
            const ti = @typeInfo(@TypeOf(Components.order_by));
            const OrderByType = meta.FinalChild(ti.Fn.params[1].type.?);
            meta.validateOrderByType(Components, OrderByType);

            desc.order_by = wrapOrderByFn(OrderByType, Components.order_by);
            desc.order_by_component = self.componentId(OrderByType);
        }

        if (@hasDecl(Components, "instanced") and Components.instanced) desc.filter.instanced = true;

        return ecs.Query.init(self, &desc);
    }

    /// adds a system to the Ecs using the passed in struct
    pub fn system(self: EcsWorld, comptime Components: type, phase: u64) void {
        std.debug.assert(@typeInfo(Components) == .Struct);
        std.debug.assert(@hasDecl(Components, "run"));
        std.debug.assert(@hasDecl(Components, "name"));

        var entity_desc = std.mem.zeroes(flecs.ecs_entity_desc_t);
        entity_desc.id = flecs.ecs_new_id(self.world);
        entity_desc.name = Components.name;
        entity_desc.add[0] = phase;
        entity_desc.add[1] = if (phase != 0) flecs.ecs_make_pair(flecs.EcsDependsOn, phase) else 0;

        var desc = std.mem.zeroes(flecs.ecs_system_desc_t);
        desc.callback = dummyFn;
        desc.entity = flecs.ecs_entity_init(self.world, &entity_desc);
        // desc.multi_threaded = true;
        desc.run = wrapSystemFn(Components, Components.run);
        desc.query.filter = meta.generateFilterDesc(self, Components);

        if (@hasDecl(Components, "order_by")) {
            meta.validateOrderByFn(Components.order_by);
            const ti = @typeInfo(@TypeOf(Components.order_by));
            const OrderByType = meta.FinalChild(ti.Fn.params[1].type.?);
            meta.validateOrderByType(Components, OrderByType);

            desc.query.order_by = wrapOrderByFn(OrderByType, Components.order_by);
            desc.query.order_by_component = self.componentId(OrderByType);
        }

        if (@hasDecl(Components, "instanced") and Components.instanced) desc.filter.instanced = true;

        _ = flecs.ecs_system_init(self.world, &desc);
    }

    /// adds an observer system to the Ecs using the passed in struct (see systems)
    pub fn observer(self: EcsWorld, comptime Components: type, event: u64) void {
        std.debug.assert(@typeInfo(Components) == .Struct);
        std.debug.assert(@hasDecl(Components, "run"));
        std.debug.assert(@hasDecl(Components, "name"));

        var entity_desc = std.mem.zeroes(flecs.ecs_entity_desc_t);
        entity_desc.id = flecs.ecs_new_id(self.world);
        entity_desc.name = Components.name;
        entity_desc.add[0] = event;

        var desc = std.mem.zeroes(flecs.ecs_observer_desc_t);
        desc.callback = dummyFn;
        desc.entity = flecs.ecs_entity_init(self.world, &entity_desc);
        desc.events[0] = event;

        desc.run = wrapSystemFn(Components, Components.run);
        desc.filter = meta.generateFilterDesc(self, Components);

        if (@hasDecl(Components, "instanced") and Components.instanced) desc.filter.instanced = true;

        _ = flecs.ecs_observer_init(self.world, &desc);
    }

    pub fn setName(self: EcsWorld, entity: flecs.EntityId, name: [*c]const u8) void {
        _ = flecs.ecs_set_name(self.world, entity, name);
    }

    pub fn getName(self: EcsWorld, entity: flecs.EntityId) [*c]const u8 {
        return flecs.ecs_get_name(self.world, entity);
    }

    /// sets a component on entity. Can be either a pointer to a struct or a struct
    pub fn set(self: *EcsWorld, entity: flecs.EntityId, ptr_or_struct: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer or @typeInfo(@TypeOf(ptr_or_struct)) == .Struct);

        const T = meta.FinalChild(@TypeOf(ptr_or_struct));
        var component = if (@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer) ptr_or_struct else &ptr_or_struct;
        _ = flecs.ecs_set_id(self.world, entity, self.componentId(T), @sizeOf(T), component);
    }

    /// removes a component from an Entity
    pub fn remove(self: *EcsWorld, entity: flecs.EntityId, comptime T: type) void {
        flecs.ecs_remove_id(self.world, entity, self.componentId(T));
    }

    /// removes all components from an Entity
    pub fn clear(self: *EcsWorld, entity: flecs.EntityId) void {
        flecs.ecs_clear(self.world, entity);
    }

    /// removes the entity from the Ecs
    pub fn delete(self: *EcsWorld, entity: flecs.EntityId) void {
        flecs.ecs_delete(self.world, entity);
    }

    /// deletes all entities with the component
    pub fn deleteWith(self: *EcsWorld, comptime T: type) void {
        flecs.ecs_delete_with(self.world, self.componentId(T));
    }

    /// remove all instances of the specified component
    pub fn removeAll(self: *EcsWorld, comptime T: type) void {
        flecs.ecs_remove_all(self.world, self.componentId(T));
    }

    pub fn setSingleton(self: EcsWorld, ptr_or_struct: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer or @typeInfo(@TypeOf(ptr_or_struct)) == .Struct);

        const T = meta.FinalChild(@TypeOf(ptr_or_struct));
        var component = if (@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer) ptr_or_struct else &ptr_or_struct;
        _ = flecs.ecs_set_id(self.world, self.componentId(T), self.componentId(T), @sizeOf(T), component);
    }

    // TODO: use ecs_get_mut_id optionally based on a bool perhaps or maybe if the passed in type is a pointer?
    pub fn getSingleton(self: EcsWorld, comptime T: type) ?*const T {
        std.debug.assert(@typeInfo(T) == .Struct);
        var val = flecs.ecs_get_id(self.world, self.componentId(T), self.componentId(T));
        if (val == null) return null;
        return @as(*const T, @ptrCast(@alignCast(val)));
    }

    pub fn getSingletonMut(self: EcsWorld, comptime T: type) ?*T {
        std.debug.assert(@typeInfo(T) == .Struct);
        var is_added: bool = undefined;
        var val = flecs.ecs_get_mut_id(self.world, self.componentId(T), self.componentId(T), &is_added);
        if (val == null) return null;
        return @as(*T, @ptrCast(@alignCast(val)));
    }

    pub fn removeSingleton(self: EcsWorld, comptime T: type) void {
        std.debug.assert(@typeInfo(T) == .Struct);
        flecs.ecs_remove_id(self.world, self.componentId(T), self.componentId(T));
    }
};

fn wrapSystemFn(comptime T: type, comptime cb: fn (*ecs.Iterator(T)) void) fn ([*c]flecs.ecs_iter_t) callconv(.C) void {
    const Closure = struct {
        pub var callback: *const fn (*ecs.Iterator(T)) void = cb;

        pub fn closure(it: [*c]flecs.ecs_iter_t) callconv(.C) void {
            var iterator = ecs.Iterator(T).init(it, flecs.ecs_iter_next);
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
