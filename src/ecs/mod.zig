const std = @import("std");
pub const c = @import("flecs/flecs.zig");
const queries = @import("queries/mod.zig");

pub const meta = @import("meta.zig");

pub const Entity = @import("entity.zig").Entity;
pub const Iterator = queries.Iterator;

// query types
pub const Filter = queries.Filter;
pub const Query = queries.Query;
pub const Term = queries.Term;

// system query modifiers
pub const DontMatch = queries.DontMatch;
pub const Mask = queries.Mask;
pub const MaskI = queries.MaskI;
pub const None = queries.None;
pub const Not = queries.Not;
pub const Or = queries.Or;
pub const Pair = queries.Pair;
pub const PairI = queries.PairI;
pub const Writeonly = queries.Writeonly;
pub const WriteonlyI = queries.WriteonlyI;

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

// TODO: add to modifiers and TermInfo
pub const Traverse = enum(c_int) {
    /// Match self
    self = c.EcsSelf,
    /// Match by traversing upwards
    up = c.EcsUp,
    /// Match by traversing downwards (derived, cannot be set)
    down = c.EcsDown,
    /// Short for up(ChildOf)
    parent = c.EcsParent,
    /// Same as Up, but iterate in breadth-first order
    cascade = c.EcsCascade,
    all = c.EcsTraverseAll,
};

pub const Event = enum(c.ecs_id_t) {
    // Event. Triggers when an id (component, tag, pair) is added to an entity
    on_add = c.FLECS_HI_COMPONENT_ID + 33,
    // Event. Triggers when an id (component, tag, pair) is removed from an entity
    on_remove = c.FLECS_HI_COMPONENT_ID + 34,
    // Event. Triggers when a component is set for an entity
    on_set = c.FLECS_HI_COMPONENT_ID + 35,
    // Event. Triggers when a component is unset for an entity
    un_set = c.FLECS_HI_COMPONENT_ID + 36,
    on_delete = c.FLECS_HI_COMPONENT_ID + 37,
    on_table_create = c.FLECS_HI_COMPONENT_ID + 38,
    // Event. Exactly-once trigger for when an entity matches/unmatches a filter
    on_table_delete = c.FLECS_HI_COMPONENT_ID + 39,
    on_table_empty = c.FLECS_HI_COMPONENT_ID + 40,
    on_table_fill = c.FLECS_HI_COMPONENT_ID + 41,
    on_table_delete_target = c.FLECS_HI_COMPONENT_ID + 46,
};

/// returns the field at index
pub fn field(iter: [*c]const c.ecs_iter_t, comptime T: type, index: i32) []T {
    var col = c.ecs_field_w_size(iter, @sizeOf(T), index);
    const ptr = @as([*]T, @ptrCast(@alignCast(col)));
    return ptr[0..@intCast(iter.*.count)];
}

/// returns null in the case of column not being present or an invalid index
pub fn fieldOpt(iter: [*c]const c.ecs_iter_t, comptime T: type, index: i32) ?[]T {
    if (index <= 0) return null;
    var col = c.ecs_field_w_size(iter, @sizeOf(T), index) orelse return null;
    const ptr = @as([*]T, @ptrCast(@alignCast(col)));
    return ptr[0..@intCast(iter.*.count)];
}

pub fn pairFirst(id: u64) u32 {
    return @as(u32, @truncate((id & c.ECS_COMPONENT_MASK) >> 32));
}

pub fn pairSecond(id: u64) u32 {
    return @as(u32, @truncate(id));
}
