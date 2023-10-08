const std = @import("std");
const aya = @import("../aya.zig");
const ecs = @import("mod.zig");
const c = ecs.c;

const assert = std.debug.assert;

pub const TermInfo = @import("term_info.zig").TermInfo;

/// asserts with a message
pub fn assertMsg(ok: bool, comptime msg: []const u8, args: anytype) void {
    if (@import("builtin").mode == .Debug) {
        if (!ok) {
            std.debug.print("Assertion: " ++ msg ++ "\n", args);
            unreachable;
        }
    }
}

/// given a pointer or optional pointer returns the base struct type.
pub fn FinalChild(comptime T: type) type {
    switch (@typeInfo(T)) {
        .Pointer => |info| switch (info.size) {
            .One => switch (@typeInfo(info.child)) {
                .Struct => return info.child,
                .Optional => |opt_info| return opt_info.child,
                else => {},
            },
            else => {},
        },
        .Optional => |info| return FinalChild(info.child),
        .Struct => return T,
        else => {},
    }
    @compileError("Expected pointer or optional pointer, found '" ++ @typeName(T) ++ "'");
}

/// given a pointer or optional pointer returns a pointer-to-slice. constness and optionality are retained.
pub fn PointerToSlice(comptime T: type) type {
    var is_const = false;
    var is_optional = false;
    var PointerT = T;

    switch (@typeInfo(T)) {
        .Optional => |opt_info| switch (@typeInfo(opt_info.child)) {
            .Pointer => |ptr_info| {
                is_const = ptr_info.is_const;
                is_optional = true;
                PointerT = opt_info.child;
            },
            else => unreachable,
        },
        .Pointer => |ptr_info| is_const = ptr_info.is_const,
        else => unreachable,
    }

    const info = @typeInfo(PointerT).Pointer;
    const InnerType = @Type(.{
        .Pointer = .{
            .size = .Slice,
            .is_const = is_const,
            .is_volatile = info.is_volatile,
            .alignment = info.alignment,
            .address_space = info.address_space,
            .child = info.child,
            .is_allowzero = info.is_allowzero,
            .sentinel = null,
        },
    });

    if (is_optional) return @Type(.{
        .Optional = .{
            .child = InnerType,
        },
    });

    return InnerType;
}

/// normalizes a single T or tuple of T's into a tuple of T's allowing functions to take in an anytype param
/// that is one ore more T's
pub fn tupleOrSingleArgToSlice(comptime T: type, args: anytype) []const T {
    if (@typeInfo(@TypeOf(args)) == .Struct and @typeInfo(@TypeOf(args)).Struct.is_tuple) {
        var tmp: [args.len]T = undefined;
        for (args, 0..) |S, i| tmp[i] = S;
        return tmp[0..args.len];
    }

    const tmp: [1]T = [_]T{args};
    return tmp[0..1];
}

/// gets the number of arguments in the function
pub fn argCount(comptime function: anytype) usize {
    return switch (@typeInfo(@TypeOf(function))) {
        .Fn => |func_info| func_info.params.len,
        else => assert("invalid function"),
    };
}

/// given a query struct, returns a type with the exact same fields except the fields are made pointer-to-many.
/// constness and optionality are retained.
pub fn TableIteratorData(comptime Components: type) type {
    const src_fields = std.meta.fields(Components);
    const StructField = std.builtin.Type.StructField;
    var fields: [src_fields.len]StructField = undefined;

    for (src_fields, 0..) |field, i| {
        const T = FinalChild(field.type);
        fields[i] = .{
            .name = field.name,
            .type = PointerToSlice(field.type),
            .default_value = null,
            .is_comptime = false,
            .alignment = @alignOf(*T),
        };
    }

    return @Type(.{ .Struct = .{
        .layout = .Auto,
        .fields = &fields,
        .decls = &[_]std.builtin.Type.Declaration{},
        .is_tuple = false,
    } });
}

/// returns a tuple consisting of the field values of value
pub fn fieldsTuple(value: anytype) FieldsTupleType(@TypeOf(value)) {
    assert(@typeInfo(@TypeOf(value)) == .Struct);

    const T = @TypeOf(value);
    const ti = @typeInfo(T).Struct;
    const FieldsTuple = FieldsTupleType(T);

    var tuple: FieldsTuple = undefined;
    comptime var i = 0;
    inline while (i < ti.fields.len) : (i += 1) {
        tuple[i] = @field(value, ti.fields[i].name);
    }

    return tuple;
}

/// returns the Type of the tuple version of T
pub fn FieldsTupleType(comptime T: type) type {
    const ti = @typeInfo(T).Struct;
    return @Type(.{
        .Struct = .{
            .layout = ti.layout,
            .fields = ti.fields,
            .decls = &[0]std.builtin.TypeInfo.Declaration{},
            .is_tuple = true,
        },
    });
}

pub fn validateIterator(comptime Components: type, iter: *const c.ecs_iter_t) void {
    if (@import("builtin").mode == .Debug) {
        var index: usize = 0;
        const component_info = @typeInfo(Components).Struct;

        inline for (component_info.fields) |field| {
            // skip EcsInOutNone since they arent returned when we iterate
            while (iter.terms[index].inout == c.EcsInOutNone) : (index += 1) {}
            const is_optional = @typeInfo(field.type) == .Optional;
            const col_type = FinalChild(field.type);
            const type_entity = iter.world.?.componentId(col_type);

            // ensure order matches for terms vs struct fields. note that pairs need to have their first term extracted.
            if (c.ecs_id_is_pair(iter.terms[index].id)) {
                assertMsg(ecs.pairFirst(iter.terms[index].id) == type_entity, "Order of struct does not match order of iter.terms! {d} != {d}\n", .{ iter.terms[index].id, type_entity });
            } else {
                assertMsg(iter.terms[index].id == type_entity, "Order of struct does not match order of iter.terms! {d} != {d}. term index: {d} (type: {s})\n", .{ iter.terms[index].id, type_entity, index, @typeName(col_type) });
            }

            // validate readonly (non-ptr types in the struct) matches up with the inout
            const is_const = isConst(field.type);
            if (is_const) assert(iter.terms[index].inout == c.EcsIn);
            if (iter.terms[index].inout == c.EcsIn) assert(is_const);

            // validate that optionals (?* types in the struct) match up with valid opers. EcsOr will only be on the first term in an Or query.
            if (is_optional) assert(iter.terms[index].oper == c.EcsOr or iter.terms[index].oper == c.EcsOptional or iter.terms[index - 1].oper == c.EcsOr);
            if (iter.terms[index].oper == c.EcsOr or iter.terms[index].oper == c.EcsOptional) assert(is_optional);

            index += 1;
        }
    }
}

/// ensures an orderBy function for a query/system is legit
pub fn validateOrderByFn(comptime func: anytype) void {
    if (@import("builtin").mode == .Debug) {
        const ti = @typeInfo(@TypeOf(func));
        assert(ti == .Fn);
        assert(ti.Fn.params.len == 4);

        // params are: EntityId, *const T, EntityId, *const T
        assert(ti.Fn.params[0].type.? == u64);
        assert(ti.Fn.params[2].type.? == u64);
        assert(ti.Fn.params[1].type.? == ti.Fn.params[3].type.?);
        assert(isConst(ti.Fn.params[1].type.?));
        assert(@typeInfo(ti.Fn.params[1].type.?) == .Pointer);
    }
}

/// ensures the order by type is in the Components struct and that that it isnt an optional term
pub fn validateOrderByType(comptime Components: type, comptime T: type) void {
    if (@import("builtin").mode == .Debug) {
        var valid = false;

        const component_info = @typeInfo(Components).Struct;
        inline for (component_info.fields) |field| {
            if (FinalChild(field.type) == T) {
                valid = true;
            }
        }

        // allow types in Filter with no fields
        if (@hasDecl(Components, "modifiers")) {
            inline for (Components.modifiers) |inout_tuple| {
                const ti = TermInfo.init(inout_tuple);
                if (ti.inout == c.EcsInOutNone) {
                    if (ti.term_type == T)
                        valid = true;
                }
            }
        }

        assertMsg(valid, "type {any} was not found in the struct!", .{T});
    }
}

/// checks a Pointer or Optional for constness. Any other types passed in will error.
pub fn isConst(comptime T: type) bool {
    switch (@typeInfo(T)) {
        .Pointer => |ptr| return ptr.is_const,
        .Optional => |opt| {
            switch (@typeInfo(opt.child)) {
                .Pointer => |ptr| return ptr.is_const,
                else => {},
            }
        },
        else => {},
    }

    @compileError("Invalid type passed to isConst: " ++ @typeName(T));
}

/// https://github.com/SanderMertens/flecs/tree/master/examples/c/reflection
pub fn registerReflectionData(world: *c.ecs_world_t, comptime T: type, entity: u64) void {
    var desc = std.mem.zeroes(c.ecs_struct_desc_t);
    desc.entity = entity;

    switch (@typeInfo(T)) {
        .Struct => |si| {
            // tags have no size so ignore them
            if (@sizeOf(T) == 0) return;

            inline for (si.fields, 0..) |field, i| {
                var member = std.mem.zeroes(c.ecs_member_t);
                member.name = aya.tmp_allocator.dupeZ(u8, field.name) catch unreachable;

                // TODO: support nested structs
                member.type = switch (field.type) {
                    // Struct => componentId(field.field_type),
                    bool => c.FLECS_IDecs_bool_tID_,
                    f32 => c.FLECS_IDecs_f32_tID_,
                    f64 => c.FLECS_IDecs_f64_tID_,
                    u8 => c.FLECS_IDecs_u8_tID_,
                    u16 => c.FLECS_IDecs_u16_tID_,
                    u32 => c.FLECS_IDecs_u32_tID_,
                    u64 => blk: {
                        // bit of a hack, but if the field name has "entity" in it we consider it an Entity reference
                        if (std.mem.indexOf(u8, field.name, "entity") != null)
                            break :blk c.FLECS_IDecs_entity_tID_;
                        break :blk c.FLECS_IDecs_u64_tID_;
                    },
                    i8 => c.FLECS_IDecs_i8_tID_,
                    i16 => c.FLECS_IDecs_i16_tID_,
                    i32 => c.FLECS_IDecs_i16_tID_,
                    i64 => c.FLECS_IDecs_i64_tID_,
                    usize => c.FLECS_IDecs_uptr_tID_,
                    []const u8 => c.FLECS_IDecs_string_tID_,
                    [*]const u8 => c.FLECS_IDecs_string_tID_,
                    else => switch (@typeInfo(field.type)) {
                        .Pointer => c.FLECS_IDecs_uptr_tID_,
                        .Struct => world.componentId(field.type),
                        .Enum => blk: {
                            // flecs expects enums to be C style ints so if we are packed smaller abandon ship
                            if (@sizeOf(T) != 4) return;

                            var enum_desc = std.mem.zeroes(c.ecs_enum_desc_t);
                            enum_desc.entity = world.componentId(T);

                            inline for (@typeInfo(field.type).Enum.fields, 0..) |f, index| {
                                enum_desc.constants[index] = std.mem.zeroInit(c.ecs_enum_constant_t, .{
                                    .name = aya.tmp_allocator.dupeZ(u8, f.name) catch unreachable,
                                    .value = @as(i32, @intCast(f.value)),
                                });
                            }

                            break :blk c.ecs_enum_init(world, &enum_desc);
                        },

                        else => {
                            std.debug.print("unhandled field type: {any}\nti: {any}\nroot type: {}\n", .{ field.type, @typeInfo(field.type), T });
                            unreachable;
                        },
                    },
                };
                desc.members[i] = member;
            }
            _ = c.ecs_struct_init(world, &desc);
        },
        else => unreachable,
    }
}

/// given a struct of Components with optional embedded metadata (order_by, instanced, modifiers, eptr) it generates an ecs_query_desc_t
pub fn generateQueryDesc(world: *c.ecs_world_t, comptime Components: type) c.ecs_query_desc_t {
    var query_desc = std.mem.zeroes(c.ecs_query_desc_t);
    query_desc.filter = generateFilterDesc(world, Components);

    if (@hasDecl(Components, "order_by")) {
        validateOrderByFn(Components.order_by);
        const ti = @typeInfo(@TypeOf(Components.order_by));
        const OrderByType = FinalChild(ti.Fn.params[1].type.?);
        validateOrderByType(Components, OrderByType);

        query_desc.order_by = wrapOrderByFn(OrderByType, Components.order_by);
        query_desc.order_by_component = world.componentId(OrderByType);
    }

    if (@hasDecl(Components, "instanced") and Components.instanced) query_desc.filter.instanced = true;

    return query_desc;
}

/// given a struct of Components with optional embedded "metadata", "name", "order_by" data it generates an ecs_filter_desc_t
pub fn generateFilterDesc(world: *c.ecs_world_t, comptime Components: type) c.ecs_filter_desc_t {
    assert(@typeInfo(Components) == .Struct);
    var desc = std.mem.zeroes(c.ecs_filter_desc_t);

    // first, extract what we can from the Components fields
    const component_info = @typeInfo(Components).Struct;
    inline for (component_info.fields, 0..) |field, i| {
        desc.terms[i].id = world.componentId(FinalChild(field.type));

        if (@typeInfo(field.type) == .Optional)
            desc.terms[i].oper = c.EcsOptional;

        if (isConst(field.type))
            desc.terms[i].inout = c.EcsIn;
    }

    // optionally, apply any additional modifiers if present. Keep track of the term_index in case we have to add Or + Filters or Ands
    var next_term_index = component_info.fields.len;
    if (@hasDecl(Components, "modifiers")) {
        inline for (Components.modifiers) |inout_tuple| {
            const ti = TermInfo.init(inout_tuple);
            // std.debug.print("{any}: {any}\n", .{ inout_tuple, ti });

            if (getTermIndex(ti.term_type, world, ti.field, &desc, component_info.fields)) |term_index| {
                // Not terms should not be present in the Components struct
                assert(ti.oper != c.EcsNot);

                // if we have a None on an existing type ensure we also have an Or. That is the only legit case for having a None and also
                // having the term present in the query. For that case, we will leave both optionals and add the two Or terms.
                if (ti.inout == c.EcsInOutNone) {
                    assert(ti.oper == c.EcsOr);
                    if (ti.or_term_type) |or_term_type| {
                        // ensure the term is optional. If the second Or term is present ensure it is optional as well.
                        assert(desc.terms[term_index].oper == c.EcsOptional);
                        if (getTermIndex(or_term_type, world, null, &desc, component_info.fields)) |or_term_index| {
                            assert(desc.terms[or_term_index].oper == c.EcsOptional);
                        }

                        desc.terms[next_term_index].id = world.componentId(ti.term_type);
                        desc.terms[next_term_index].inout = ti.inout;
                        desc.terms[next_term_index].oper = ti.oper;
                        next_term_index += 1;

                        desc.terms[next_term_index].id = world.componentId(or_term_type);
                        desc.terms[next_term_index].inout = ti.inout;
                        next_term_index += 1;
                    } else unreachable;
                } else {
                    if (ti.inout == c.EcsOut) {
                        assert(desc.terms[term_index].inout == c.EcsInOutDefault);
                        desc.terms[term_index].inout = ti.inout;
                    }

                    // the only valid oper left is Or since Not terms cant be in Components struct
                    if (ti.oper == c.EcsOr) {
                        assert(desc.terms[term_index].oper == c.EcsOptional);

                        if (getTermIndex(ti.or_term_type.?, world, null, &desc, component_info.fields)) |or_term_index| {
                            assert(desc.terms[or_term_index].oper == c.EcsOptional);
                            desc.terms[or_term_index].oper = ti.oper;
                        } else unreachable;
                        desc.terms[term_index].oper = ti.oper;
                    }
                }

                if (ti.mask != 0) {
                    assert(desc.terms[term_index].subj.set.mask == 0);
                    desc.terms[term_index].subj.set.mask = ti.mask;
                }

                if (ti.obj_type) |obj_type| {
                    desc.terms[term_index].id = world.pair(ti.relation_type.?, obj_type);
                }
            } else {
                // the term wasnt found so we must have either a InOutNone or Not or EcsIsEntity mask
                if (ti.inout != c.EcsInOutNone and ti.oper != c.EcsNot) std.debug.print("invalid inout found! No matching type found in the Components struct. Only Not and Filters are valid for types not in the struct. This should assert/panic but a zig bug lets us only print it.\n", .{});
                if (ti.inout == c.EcsInOutNone) {
                    desc.terms[next_term_index].id = world.componentId(ti.term_type);
                    desc.terms[next_term_index].inout = ti.inout;
                    next_term_index += 1;
                } else if (ti.oper == c.EcsNot) {
                    desc.terms[next_term_index].id = world.componentId(ti.term_type);
                    desc.terms[next_term_index].oper = ti.oper;
                    next_term_index += 1;
                } else if (ti.mask == c.EcsIsEntity) {
                    desc.terms[next_term_index].id = world.componentId(ti.term_type);
                    desc.terms[next_term_index].inout = ti.inout;
                    desc.terms[next_term_index].subj.set.mask = ti.mask; // TODO: should maybe be .src.flags = ti.mask?
                    next_term_index += 1;
                } else {
                    std.debug.print("invalid inout applied to a term not in the query. only Not and Filter are allowed for terms not present.\n", .{});
                }
            }
        }
    }

    // optionally add the expression string
    if (@hasDecl(Components, "expr")) {
        assertMsg(std.meta.Elem(@TypeOf(Components.expr)) == u8, "expr must be a const string. Found: {}", .{std.meta.Elem(@TypeOf(Components.expr))});
        desc.expr = Components.expr;
    }

    return desc;
}

const FlecsOrderByAction = fn (c.ecs_entity_t, ?*const anyopaque, c.ecs_entity_t, ?*const anyopaque) callconv(.C) c_int;

fn wrapOrderByFn(comptime T: type, comptime cb: fn (u64, *const T, u64, *const T) c_int) FlecsOrderByAction {
    const Closure = struct {
        pub fn closure(e1: u64, c1: ?*const anyopaque, e2: u64, c2: ?*const anyopaque) callconv(.C) c_int {
            return @call(.always_inline, cb, .{ e1, @as(*const T, @ptrCast(@alignCast(c1))), e2, @as(*const T, @ptrCast(@alignCast(c2))) });
        }
    };
    return Closure.closure;
}

/// gets the index into the terms array of this type or null if it isnt found (likely a new filter term)
pub fn getTermIndex(comptime T: type, world: *c.ecs_world_t, field_name: ?[]const u8, filter: *c.ecs_filter_desc_t, comptime fields: []const std.builtin.Type.StructField) ?usize {
    if (fields.len == 0) return null;
    const comp_id = world.componentId(T);

    // if we have a field_name get the index of it so we can match it up to the term index and double check the type matches
    const named_field_index: ?usize = if (field_name) |fname| blk: {
        const f_idx = inline for (fields, 0..) |field, field_index| {
            if (std.mem.eql(u8, field.name, fname))
                break field_index;
        } else @panic("could not find field");
        break :blk f_idx;
    } else null;

    var i: usize = 0;
    while (i < fields.len) : (i += 1) {
        if (filter.terms[i].id == comp_id) {
            if (named_field_index == null) return i;

            // we have a field_name so make sure the term index matches the named field index
            if (named_field_index == i) return i;
        }
    }
    return null;
}
