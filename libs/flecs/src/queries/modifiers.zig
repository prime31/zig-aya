const std = @import("std");
const ecs = @import("../ecs.zig");
const flecs = ecs.c;

// inouts
pub fn None(comptime T: type) type {
    return struct {
        pub const inout: ecs.InOutKind = .none;
        term_type: T,
    };
}

pub fn Writeonly(comptime T: type) type {
    return struct {
        pub const inout: ecs.InOutKind = .out;
        term_type: T,
    };
}

pub fn WriteonlyI(comptime T: type, field_: []const u8) type {
    return struct {
        pub const inout: ecs.InOutKind = .out;
        pub const field = field_;
        term_type: T,
    };
}

// opers
pub fn Or(comptime T1: type, comptime T2: type) type {
    return struct {
        term_type1: T1,
        term_type2: T2,
    };
}

pub fn Not(comptime T: type) type {
    return struct {
        pub const oper: ecs.OperKind = .not;
        term_type: T,
    };
}

// next three are opers that work only on kinds. not implemented yet
fn AndFrom(comptime T1: type, comptime T2: type) type {
    return struct {
        pub const oper: ecs.OperKind = .and_from;
        term_type1: T1,
        term_type2: T2,
    };
}

fn OrFrom(comptime T1: type, comptime T2: type) type {
    return struct {
        pub const oper: ecs.OperKind = .or_from;
        term_type1: T1,
        term_type2: T2,
    };
}

fn NotFrom(comptime T1: type, comptime T2: type) type {
    return struct {
        pub const oper: ecs.OperKind = .not_from;
        term_type1: T1,
        term_type2: T2,
    };
}

/// Non matching term. T should not be present in the query unless it should also match for some reason.
/// Same thing as `Mask(EcsNothing)`.
pub fn DontMatch(comptime T: type) type {
    return struct {
        pub const mask: u8 = ecs.c.EcsNothing;
        term_type: T,
    };
}

pub fn Mask(comptime T: type, mask_: u8) type {
    return struct {
        pub const mask: u8 = mask_;
        term_type: T,
    };
}

pub fn MaskI(comptime T: type, mask_: u8, field_: []const u8) type {
    return struct {
        pub const field = field_;
        pub const mask: u8 = mask_;
        term_type: T,
    };
}

pub fn Pair(comptime RelationT: type, comptime ObjectT: type) type {
    return struct {
        relation_type: RelationT,
        obj_type: ObjectT,
    };
}

pub fn PairI(comptime RelationT: type, comptime ObjectT: type, field_: []const u8) type {
    return struct {
        pub const field = field_;
        relation_type: RelationT,
        obj_type: ObjectT,
    };
}
