const std = @import("std");
const flecs = @import("ecs.zig").c;
const meta = @import("meta.zig");

pub const Entity = struct {
    ecs: *flecs.ecs_world_t,
    id: u64,

    pub fn init(ecs: *flecs.ecs_world_t, id: u64) Entity {
        return .{
            .ecs = ecs,
            .id = id,
        };
    }

    pub fn format(value: Entity, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;
        try std.fmt.format(writer, "Entity{{ {d} }}", .{value.id});
    }

    pub fn getFullpath(self: Entity) [*c]u8 {
        return flecs.ecs_get_path_w_sep(self.ecs, 0, self.id, ".", null);
    }

    pub fn setName(self: Entity, name: [*c]const u8) void {
        _ = flecs.ecs_set_name(self.ecs, self.id, name);
    }

    pub fn getName(self: Entity) [*c]const u8 {
        return flecs.ecs_get_name(self.ecs, self.id);
    }

    /// add an entity to an entity. This operation adds a single entity to the type of an entity. Type roles may be used in
    /// combination with the added entity.
    pub fn add(self: Entity, id_or_type: anytype) void {
        std.debug.assert(@TypeOf(id_or_type) == u64 or @typeInfo(@TypeOf(id_or_type)) == .Type);
        const id = if (@TypeOf(id_or_type) == u64) id_or_type else self.ecs.componentId(id_or_type);
        flecs.ecs_add_id(self.ecs, self.id, id);
    }

    /// shortcut for addPair(ChildOf, parent). Allowed parent types: Entity, EntityId, type
    pub fn childOf(self: Entity, parent: anytype) void {
        self.addPair(flecs.EcsChildOf, parent);
    }

    /// shortcut for addPair(IsA, base). Allowed base types: Entity, EntityId, type
    pub fn isA(self: Entity, base: anytype) void {
        self.addPair(flecs.EcsIsA, base);
    }

    /// adds a relation to the object on the entity. Allowed params: Entity, EntityId, type
    pub fn addPair(self: Entity, relation: anytype, object: anytype) void {
        flecs.ecs_add_id(self.ecs, self.id, self.getEcs().pair(relation, object));
    }

    /// returns true if the entity has the relation to the object
    pub fn hasPair(self: Entity, relation: anytype, object: anytype) bool {
        return flecs.ecs_has_id(self.ecs, self.id, self.getEcs().pair(relation, object));
    }

    /// removes a relation to the object from the entity.
    pub fn removePair(self: Entity, relation: anytype, object: anytype) void {
        return flecs.ecs_remove_id(self.ecs, self.id, self.getEcs().pair(relation, object));
    }

    pub fn setPair(self: Entity, Relation: anytype, object: type, data: Relation) void {
        const pair = self.getEcs().pair(Relation, object);
        var component = &data;
        _ = flecs.ecs_set_id(self.ecs, self.id, pair, @sizeOf(Relation), component);
    }

    /// sets a component on entity. Can be either a pointer to a struct or a struct
    pub fn set(self: Entity, ptr_or_struct: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer or @typeInfo(@TypeOf(ptr_or_struct)) == .Struct);

        const T = meta.FinalChild(@TypeOf(ptr_or_struct));
        var component = if (@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer) ptr_or_struct else &ptr_or_struct;
        _ = flecs.ecs_set_id(self.ecs, self.id, self.ecs.componentId(T), @sizeOf(T), component);
    }

    /// sets a private instance of a component on entity. Useful for inheritance.
    pub fn setOverride(self: Entity, ptr_or_struct: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer or @typeInfo(@TypeOf(ptr_or_struct)) == .Struct);

        const T = meta.FinalChild(@TypeOf(ptr_or_struct));
        var component = if (@typeInfo(@TypeOf(ptr_or_struct)) == .Pointer) ptr_or_struct else &ptr_or_struct;
        const id = self.ecs.componentId(T);
        flecs.ecs_add_id(self.ecs, self.id, flecs.ECS_OVERRIDE | id);
        _ = flecs.ecs_set_id(self.ecs, self.id, id, @sizeOf(T), component);
    }

    /// sets a component as modified, and will trigger observers after being modified from a system
    pub fn setModified(self: Entity, id_or_type: anytype) void {
        std.debug.assert(@TypeOf(id_or_type) == u64 or @typeInfo(@TypeOf(id_or_type)) == .Type);
        const id = if (@TypeOf(id_or_type) == u64) id_or_type else self.ecs.componentId(id_or_type);
        flecs.ecs_modified_id(self.ecs, self.id, id);
    }

    /// gets a pointer to a type if the component is present on the entity
    pub fn get(self: Entity, comptime T: type) ?*const T {
        const ptr = flecs.ecs_get_id(self.ecs, self.id, self.ecs.componentId(T));
        if (ptr) |p| {
            return @as(*const T, @ptrCast(@alignCast(p)));
        }
        return null;
    }

    pub fn getMut(self: Entity, comptime T: type) ?*T {
        var ptr = flecs.ecs_get_mut_id(self.ecs, self.id, self.ecs.componentId(T));
        if (ptr) |p| {
            return @as(*T, @ptrCast(@alignCast(p)));
        }
        return null;
    }

    /// removes a component from an Entity
    pub fn remove(self: Entity, id_or_type: anytype) void {
        std.debug.assert(@TypeOf(id_or_type) == u64 or @typeInfo(@TypeOf(id_or_type)) == .Type);
        const id = if (@TypeOf(id_or_type) == u64) id_or_type else self.ecs.componentId(id_or_type);
        flecs.ecs_remove_id(self.ecs, self.id, id);
    }

    /// removes all components from an Entity
    pub fn clear(self: Entity) void {
        flecs.ecs_clear(self.ecs, self.id);
    }

    /// removes the entity from the world. Do not use this Entity after calling this!
    pub fn delete(self: Entity) void {
        flecs.ecs_delete(self.ecs, self.id);
    }

    /// returns true if the entity is alive
    pub fn isAlive(self: Entity) bool {
        return flecs.ecs_is_alive(self.ecs, self.id);
    }

    /// returns true if the entity has a matching component type
    pub fn has(self: Entity, id_or_type: anytype) bool {
        std.debug.assert(@TypeOf(id_or_type) == u64 or @typeInfo(@TypeOf(id_or_type)) == .Type);
        const id = if (@TypeOf(id_or_type) == u64) id_or_type else self.ecs.componentId(id_or_type);
        return flecs.ecs_has_id(self.ecs, self.id, id);
    }

    /// returns the type of the component, which contains all components
    pub fn getType(self: Entity) flecs.Type {
        return flecs.Type.init(self.ecs, flecs.ecs_get_type(self.ecs, self.id));
    }

    /// prints a json representation of an Entity. Note that world.enable_type_reflection should be true to
    /// get component values as well.
    pub fn printJsonRepresentation(self: Entity) void {
        var str = flecs.ecs_entity_to_json(self.ecs, self.id, null);
        std.debug.print("{s}\n", .{str});
        flecs.ecs_os_api.free_.?(str);
    }
};
