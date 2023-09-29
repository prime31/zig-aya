const std = @import("std");
const ecs = @import("../mod.zig");
const c = ecs.c;

pub const QueryBuilder = struct {
    world: *c.ecs_world_t,
    desc: c.ecs_system_desc_t,
    terms_count: usize = 0,

    pub fn init(world: *c.ecs_world_t) QueryBuilder {
        return .{
            .world = world,
            .desc = std.mem.zeroes(c.ecs_system_desc_t),
        };
    }

    /// adds an InOut (read/write) component to the query
    pub fn with(self: *QueryBuilder, comptime T: type) *QueryBuilder {
        self.desc.query.filter.terms[self.terms_count].id = self.world.componentId(T);
        self.terms_count += 1;
        return self;
    }

    pub fn withReadonly(self: *QueryBuilder, comptime T: type) *QueryBuilder {
        self.desc.query.filter.terms[self.terms_count].id = self.world.componentId(T);
        self.desc.query.filter.terms[self.terms_count].inout = c.EcsIn;
        self.terms_count += 1;
        return self;
    }

    pub fn withWriteonly(self: *QueryBuilder, comptime T: type) *QueryBuilder {
        self.desc.query.filter.terms[self.terms_count].id = self.world.componentId(T);
        self.desc.query.filter.terms[self.terms_count].inout = c.EcsOut;
        self.terms_count += 1;
        return self;
    }

    /// the term will be used for the query but it is neither read nor write
    pub fn withNone(self: *QueryBuilder, comptime T: type) *QueryBuilder {
        self.desc.query.filter.terms[self.terms_count].id = self.world.componentId(T);
        self.desc.query.filter.terms[self.terms_count].inout = c.EcsInOutNone;
        self.terms_count += 1;
        return self;
    }

    pub fn without(self: *QueryBuilder, comptime T: type) *QueryBuilder {
        self.desc.filter.terms[self.terms_count] = std.mem.zeroInit(c.ecs_term_t, .{
            .id = self.world.componentId(T),
            .oper = c.EcsNot,
        });
        self.terms_count += 1;
        return self;
    }

    pub fn optional(self: *QueryBuilder, comptime T: type) *QueryBuilder {
        self.desc.query.filter.terms[self.terms_count] = std.mem.zeroInit(c.ecs_term_t, .{
            .id = self.world.componentId(T),
            .oper = c.EcsOptional,
        });
        self.terms_count += 1;
        return self;
    }

    pub fn either(self: *QueryBuilder, comptime T1: type, comptime T2: type) *QueryBuilder {
        self.desc.query.filter.terms[self.terms_count] = std.mem.zeroInit(c.ecs_term_t, .{
            .id = self.world.componentId(T1),
            .oper = c.EcsOr,
        });
        self.terms_count += 1;
        self.desc.query.filter.terms[self.terms_count] = std.mem.zeroInit(c.ecs_term_t, .{
            .id = self.world.componentId(T2),
        });
        self.terms_count += 1;
        return self;
    }

    /// the query will need to match `T1 || T2` but it will not return data for either column
    pub fn eitherAsFilter(self: *QueryBuilder, comptime T1: type, comptime T2: type) *QueryBuilder {
        _ = self.either(T1, T2);
        self.desc.query.filter.terms[self.terms_count - 1].inout = c.EcsInOutNone;
        self.desc.query.filter.terms[self.terms_count - 2].inout = c.EcsInOutNone;
        return self;
    }

    /// inject a plain old string expression into the builder
    pub fn expression(self: *QueryBuilder, expr: [*c]const u8) *QueryBuilder {
        self.desc.filter.expr = expr;
        return self;
    }

    pub fn singleton(self: *QueryBuilder, comptime T: type, entity: u64) *QueryBuilder {
        self.desc.filter.terms[self.terms_count].id = self.world.componentId(T);
        self.desc.filter.terms[self.terms_count].src.id = entity;
        self.terms_count += 1;
        return self;
    }

    pub fn buildFilter(self: *QueryBuilder) ecs.Filter {
        return ecs.Filter.init(self.world, &self.desc.query.filter);
    }

    pub fn buildQuery(self: *QueryBuilder) ecs.Query {
        return c.Query.init(self.world, &self.desc.query);
    }

    /// queries/system only
    pub fn orderBy(self: *QueryBuilder, comptime T: type, orderByFn: *const fn (u64, ?*const anyopaque, u64, ?*const anyopaque) callconv(.C) c_int) *QueryBuilder {
        self.desc.query.order_by_component = self.world.componentId(T);
        self.desc.query.order_by = orderByFn;
        return self;
    }

    /// queries/system only
    pub fn orderByEntity(self: *QueryBuilder, orderByFn: *const fn (u64, ?*const anyopaque, u64, ?*const anyopaque) callconv(.C) c_int) *QueryBuilder {
        self.desc.query.order_by = orderByFn;
        return self;
    }

    /// systems only. This system callback will be called at least once for each table that matches the query
    pub fn callback(self: *QueryBuilder, cb: *const fn ([*c]c.ecs_iter_t) callconv(.C) void) *QueryBuilder {
        self.callback = cb;
        return self;
    }

    /// systems only. This system callback will only be called once. The iterator should then be iterated with ecs_iter_next.
    pub fn run(self: *QueryBuilder, cb: *const fn ([*c]c.ecs_iter_t) callconv(.C) void) *QueryBuilder {
        self.desc.run = cb;
        return self;
    }
};