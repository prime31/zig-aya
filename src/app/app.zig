const std = @import("std");
const ecs = @import("ecs");
const flecs = ecs.c;
const c = flecs;
const aya = @import("../aya.zig");
const app = @import("mod.zig");
const assets = @import("../asset/mod.zig");
const systems = @import("systems.zig");

pub const phases = @import("phases.zig");

const typeId = aya.utils.typeId;

const Allocator = std.mem.Allocator;

const World = app.World;
const Resources = app.Resources;
const AssetServer = aya.AssetServer;
const Assets = aya.Assets;
const AssetLoader = assets.AssetLoader;

const SystemSort = systems.SystemSort;
const AppWrapper = systems.AppWrapper;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub const App = struct {
    const Self = @This();

    world: World,
    plugins: std.AutoHashMap(u32, void),
    phase_insert_indices: std.AutoHashMap(u64, i32),
    last_added_system: ?u64 = null,

    pub fn init() *Self {
        const allocator = gpa.allocator();
        const world = World.init(allocator);

        // register our phases
        inline for (@typeInfo(phases).Struct.decls) |decl| {
            @field(phases, decl.name) = flecs.ecs_new_w_id(world.ecs, flecs.EcsPhase);
        }

        var self = allocator.create(App) catch unreachable;
        self.* = .{
            .world = world,
            .plugins = std.AutoHashMap(u32, void).init(allocator),
            .phase_insert_indices = std.AutoHashMap(u64, i32).init(allocator),
        };

        world.ecs.setSingleton(&AppWrapper{ .app = self });

        return self;
    }

    pub fn deinit(self: *Self) void {
        var allocator = self.phase_insert_indices.allocator;
        self.world.deinit();
        self.plugins.deinit();
        self.phase_insert_indices.deinit();
        allocator.destroy(self);

        if (gpa.detectLeaks())
            std.debug.print("GPA has leaks. Check previous logs.\n", .{});
    }

    fn addDefaultPlugins(self: *Self) void {
        _ = self.addPlugin(aya.AssetPlugin)
            .addPlugin(aya.InputPlugin)
            .addPlugin(aya.WindowPlugin);
    }

    pub fn run(self: *Self) void {
        self.addDefaultPlugins();
        self.plugins.clearAndFree();

        runStartupPipeline(self.world.ecs);
        setCorePipeline(self.world.ecs);

        // main loop
        self.world.ecs.progress(0);

        self.deinit();
    }

    /// Plugins must implement `build(App)`
    pub fn addPlugin(self: *Self, comptime T: type) *Self {
        std.debug.assert(@typeInfo(@TypeOf(T)) == .Type);

        const type_hash = aya.utils.hashTypeName(T);
        if (self.plugins.contains(type_hash)) return self;
        self.plugins.put(type_hash, {}) catch unreachable;

        T.build(self);
        return self;
    }

    pub fn addPlugins(self: *Self, comptime types: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(types)) == .Struct);
        inline for (types) |T| {
            switch (@typeInfo(@TypeOf(T))) {
                .Struct => {
                    _ = self.insertPlugin(T);
                },
                .Type => {
                    _ = self.addPlugin(T);
                },
                else => |p| {
                    @compileError("cannot compare untagged union type " ++ @typeName(p));
                },
            }
        }
        return self;
    }

    /// inserted plugins must implement `build(Self, App)`
    pub fn insertPlugin(self: *Self, value: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(value)) == .Struct);

        const type_hash = aya.utils.hashTypeName(@TypeOf(value));
        if (self.plugins.contains(type_hash)) return self;
        self.plugins.put(type_hash, {}) catch unreachable;

        value.build(self);
        return self;
    }

    // Assets
    pub fn initAsset(self: *Self, comptime T: type) *Self {
        _ = self.world.resources.initResource(Assets(T));
        return self;
    }

    pub fn initAssetLoader(self: *Self, comptime T: type, loadFn: *const fn ([]const u8, AssetLoader(T).settings_type) T) *Self {
        const asset_server = self.world.resource(AssetServer) orelse @panic("AssetServer not found in Resources");
        asset_server.registerLoader(T, loadFn);
        return self;
    }

    // Resources
    pub fn insertResource(self: *Self, resource: anytype) *Self {
        self.world.insertResource(resource);
        return self;
    }

    pub fn initResource(self: *Self, comptime T: type) *Self {
        self.world.initResource(T);
        return self;
    }

    // States
    pub fn addState(self: *Self, comptime T: type, current_state: T) *Self {
        std.debug.assert(@typeInfo(T) == .Enum);

        std.debug.print("-- add state: {}\n", .{current_state});

        const enum_entity = self.world.ecs.newId();
        _ = flecs.ecs_add_id(self.world.ecs, enum_entity, flecs.EcsUnion);

        const EnumMap = std.enums.EnumMap(T, u64);
        var map = EnumMap{};

        for (std.enums.values(T)) |val| {
            map.put(val, flecs.ecs_new_id(self.world.ecs));
        }

        _ = self.insertResource(State(T).init(enum_entity, current_state, map));
        _ = self.insertResource(NextState(T).init(current_state));

        // WHEN ADDING SYSTEMS: add the state to the system entity so we can query for it (see init.zig on bottom or below)
        const system_entity = flecs.ecs_new_id(self.world.ecs);
        self.world.ecs.addPair(system_entity, enum_entity, map.getAssertContains(current_state));

        // add system for this T that will handle disabling/enabling systems with the state when it changes
        _ = self.addSystem(phases.state_transition, StateChangeCheckSystem(T).run);

        // MAYBE TODO? add a system in startup that enables all systems of the current_state

        // ELSEWHERE, when we need to query for systems with this state
        // grab the resource for the enum T
        const state_resource = self.world.getResource(State(T)).?;

        // find all systems with the state
        var filter_desc = std.mem.zeroes(c.ecs_filter_desc_t);
        filter_desc.terms[0].id = self.world.ecs.pair(state_resource.base, flecs.EcsWildcard);
        filter_desc.terms[1].id = c.EcsSystem;

        const filter = c.ecs_filter_init(self.world.ecs, &filter_desc);
        defer c.ecs_filter_fini(filter);

        // in the iterator, this is how to fetch the union relationship value
        // const system_state = c.ecs_get_target(it.world, it.entities[i], state_resource.base, 0);

        // system_state can then be compared to map
        // const from_state_entity = map.getAssertContains(prev_state);
        // const to_state_entity = map.getAssertContains(current_state);
        // if (from_state_entity == system_state) { } // in prev_state

        // TODO:
        // - init state enum with an EcsUnion (see init example at bottom)
        // - set the current state
        // - when NextState changes, query for all with the base tag of the enum
        //     * any sytems in the current state, normal phases are disabled
        //     * any systems in the current state OnExit run (handle later, needs thought)
        //     * any systems in next state OnEnter run (handle later, needs thought)
        //     * any systems with OnTransition(T) { .from: T, .to: T } should be called
        //     * any systems in normal phases are enabled (can use run_if for these or change detection on NextState)

        // self.init_resource::<State<S>>()
        //     .init_resource::<NextState<S>>()
        //     .add_systems(
        //         StateTransition,
        //         (
        //             run_enter_schedule::<S>.run_if(run_once_condition()),
        //             apply_state_transition::<S>,
        //         )
        //             .chain(),
        //     );
        return self;
    }

    pub fn inState(self: *Self, comptime T: type, state: T) *Self {
        if (self.last_added_system) |system| {
            // add the State tag entity to the system and disable it if the state isnt active
            const state_res = self.world.getResource(State(T)).?;
            const entity = ecs.Entity.init(self.world.ecs, system);
            entity.addPair(state_res.base, state_res.entityForTag(state));

            if (state_res.state != state)
                entity.enable(false);

            self.last_added_system = null;
            return self;
        }
        unreachable;
    }

    // Systems
    pub fn addSystem(self: *Self, phase: u64, runFn: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(runFn)) == .Fn);

        var phase_insertions = self.phase_insert_indices.getOrPut(phase) catch unreachable;
        const order_in_phase = blk: {
            if (!phase_insertions.found_existing) {
                phase_insertions.value_ptr.* = 0;
                break :blk 0;
            }
            phase_insertions.value_ptr.* += 1;
            break :blk phase_insertions.value_ptr.*;
        };

        self.last_added_system = systems.addSystem(self.world.ecs, phase, runFn);
        const system_entity = ecs.Entity.init(self.world.ecs, self.last_added_system.?);
        system_entity.set(SystemSort{
            .phase = phase,
            .order_in_phase = order_in_phase,
        });

        return self;
    }

    pub fn before(self: *Self, runFn: anytype) *Self {
        if (self.last_added_system) |system| {
            const entity = ecs.Entity.init(self.world.ecs, system);

            // find the other system by its name and grab its SystemSort
            const other_entity = self.world.ecs.lookupFullPath(@typeName(@TypeOf(runFn))) orelse @panic("could not find other system");
            const other_sort = other_entity.get(SystemSort) orelse @panic("other does not appear to be a system");

            const current_sort = entity.getMut(SystemSort) orelse unreachable;
            if (other_sort.phase != current_sort.phase) @panic("other_system is in a different phase. Cannot add before unless they are in the same phase");

            current_sort.order_in_phase = other_sort.order_in_phase - 1;
            self.updateSystemOrder(current_sort.phase, other_sort.order_in_phase, -1);

            self.last_added_system = null;
            return self;
        }
        unreachable;
    }

    pub fn after(self: *Self, runFn: anytype) *Self {
        if (self.last_added_system) |system| {
            const entity = ecs.Entity.init(self.world.ecs, system);

            // find the other system by its name and grab its SystemSort
            const other_entity = self.world.ecs.lookupFullPath(@typeName(@TypeOf(runFn))) orelse @panic("could not find other system");
            const other_sort = other_entity.get(SystemSort) orelse @panic("other does not appear to be a system");

            const current_sort = entity.getMut(SystemSort) orelse unreachable;
            if (other_sort.phase != current_sort.phase) @panic("other_system is in a different phase. Cannot add before unless they are in the same phase");

            current_sort.order_in_phase = other_sort.order_in_phase + 1;
            self.updateSystemOrder(current_sort.phase, other_sort.order_in_phase, 1);

            self.last_added_system = null;
            return self;
        }
        unreachable;
    }

    fn updateSystemOrder(self: *Self, phase: u64, other_order_in_phase: i32, direction: i32) void {
        var filter_desc = std.mem.zeroes(flecs.ecs_filter_desc_t);
        filter_desc.terms[0].id = self.world.ecs.componentId(SystemSort);
        filter_desc.terms[0].inout = flecs.EcsInOut;

        const filter = flecs.ecs_filter_init(self.world.ecs, &filter_desc);
        defer flecs.ecs_filter_fini(filter);

        var it = flecs.ecs_filter_iter(self.world.ecs, filter);
        while (flecs.ecs_filter_next(&it)) {
            const system_sorts = ecs.field(&it, SystemSort, 1);

            var i: usize = 0;
            while (i < it.count) : (i += 1) {
                if (system_sorts[i].phase != phase) continue;
                if (direction > 0) {
                    if (system_sorts[i].order_in_phase > other_order_in_phase)
                        system_sorts[i].order_in_phase += direction;
                } else {
                    if (system_sorts[i].order_in_phase < other_order_in_phase)
                        system_sorts[i].order_in_phase += direction;
                }
            }
        }
    }

    pub fn addObserver(self: *Self, event: ecs.Event, runFn: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(runFn)) == .Fn);
        systems.addObserver(self.world.ecs, @intFromEnum(event), runFn);
        return self;
    }
};

fn pipelineSystemSortCompare(e1: u64, ptr1: ?*const anyopaque, e2: u64, ptr2: ?*const anyopaque) callconv(.C) c_int {
    const sort1 = @as(*const SystemSort, @ptrCast(@alignCast(ptr1)));
    const sort2 = @as(*const SystemSort, @ptrCast(@alignCast(ptr2)));

    const phase_1: c_int = if (sort1.phase > sort2.phase) 1 else 0;
    const phase_2: c_int = if (sort1.phase < sort2.phase) 1 else 0;

    // sort by: phase, order_in_phase then entity_id
    if (sort1.phase == sort2.phase) {
        // std.debug.print("SAME PHASE. order: {} vs {}, entity: {}, {}\n", .{ sort1.order_in_phase, sort2.order_in_phase, e1, e2 });
        const order_1: c_int = if (sort1.order_in_phase > sort2.order_in_phase) 1 else 0;
        const order_2: c_int = if (sort1.order_in_phase < sort2.order_in_phase) 1 else 0;

        const order_in_phase = order_1 - order_2;
        if (order_in_phase != 0) return order_in_phase;

        const first: c_int = if (e1 > e2) 1 else 0;
        const second: c_int = if (e1 < e2) 1 else 0;

        return first - second;
    }

    return phase_1 - phase_2;
}

/// runs a Pipeline that matches only the startup phases then deletes all systems in those phases
fn runStartupPipeline(world: *flecs.ecs_world_t) void {
    var pip_desc = std.mem.zeroes(flecs.ecs_pipeline_desc_t);
    pip_desc.entity = flecs.ecs_entity_init(world, &std.mem.zeroInit(flecs.ecs_entity_desc_t, .{ .name = "StartupPipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = world.componentId(SystemSort);

    pip_desc.query.filter.terms[0].id = flecs.EcsSystem;
    pip_desc.query.filter.terms[1] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = phases.pre_startup,
        .oper = flecs.EcsOr,
    });
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = phases.startup,
        .oper = flecs.EcsOr,
    });
    pip_desc.query.filter.terms[3].id = phases.post_startup;
    pip_desc.query.filter.terms[4] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = world.componentId(SystemSort),
        .inout = flecs.EcsIn,
    });

    const startup_pipeline = flecs.ecs_pipeline_init(world, &pip_desc);
    flecs.ecs_set_pipeline(world, startup_pipeline);
    _ = flecs.ecs_progress(world, 0);

    flecs.ecs_delete_with(world, phases.pre_startup);
    flecs.ecs_delete_with(world, phases.startup);
    flecs.ecs_delete_with(world, phases.post_startup);
}

/// creates and sets a Pipeline that handles system sorting
fn setCorePipeline(world: *flecs.ecs_world_t) void {
    var pip_desc = std.mem.zeroes(flecs.ecs_pipeline_desc_t);
    pip_desc.entity = flecs.ecs_entity_init(world, &std.mem.zeroInit(flecs.ecs_entity_desc_t, .{ .name = "CorePipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = world.componentId(SystemSort);

    pip_desc.query.filter.terms[0].id = flecs.EcsSystem;
    pip_desc.query.filter.terms[1].id = world.componentId(SystemSort);
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = flecs.EcsDisabled,
        .src = std.mem.zeroInit(flecs.ecs_term_id_t, .{
            .flags = flecs.EcsUp,
            .trav = flecs.EcsDependsOn,
        }),
        .oper = flecs.EcsNot,
    });
    pip_desc.query.filter.terms[3] = std.mem.zeroInit(flecs.ecs_term_t, .{
        .id = flecs.EcsDisabled,
        .src = std.mem.zeroInit(flecs.ecs_term_id_t, .{
            .flags = flecs.EcsUp,
            .trav = flecs.EcsChildOf,
        }),
        .oper = flecs.EcsNot,
    });

    const pipeline = flecs.ecs_pipeline_init(world, &pip_desc);
    flecs.ecs_set_pipeline(world, pipeline);
}

// states, organize these
pub fn State(comptime T: type) type {
    return struct {
        const Self = @This();
        base: u64,
        state: T,
        state_map: std.enums.EnumMap(T, u64),

        pub fn init(base: u64, state: T, state_map: std.enums.EnumMap(T, u64)) Self {
            return .{ .base = base, .state = state, .state_map = state_map };
        }

        pub fn entityForTag(self: Self, state: T) u64 {
            return self.state_map.getAssertContains(state);
        }
    };
}

pub fn NextState(comptime T: type) type {
    return struct {
        const Self = @This();
        state: T,

        pub fn init(state: T) Self {
            return .{ .state = state };
        }

        pub fn set(self: *Self, world: *c.ecs_world_t, new_state: T) void {
            self.state = new_state;
            world.newEntity().set(StateChanged(T){ .next_state = new_state });
        }
    };
}

fn StateChanged(comptime T: type) type {
    return struct { next_state: T };
}

fn StateChangeCheckSystem(comptime T: type) type {
    return struct {
        const Self = @This();
        next_state: *StateChanged(T),

        fn run(state: ResMut(State(T)), iter: *ecs.Iterator(Self)) void {
            std.debug.assert(iter.iter.count <= 1);

            while (iter.next()) |comps| {
                std.debug.print("-- -- -- -- --StateChangeCheckSystem(T) {}\n", .{comps.next_state});
                // set State(T) to the new state
                const prev_state = state.get().?.state;
                _ = prev_state;
                state.get().?.state = comps.next_state.next_state;

                // disable all systems with prev_state
                // enable all systems with comps.next_state.next_state

                iter.entity().delete();
            }
        }
    };
}

// resources, organize these
pub fn Res(comptime T: type) type {
    return struct {
        pub const res_type = T;
        const Self = @This();

        resource: ?*const T,

        pub fn get(self: Self) ?*const T {
            return self.resource;
        }
    };
}

pub fn ResMut(comptime T: type) type {
    return struct {
        pub const res_mut_type = T;
        const Self = @This();

        resource: ?*T,

        pub fn get(self: Self) ?*T {
            return self.resource;
        }
    };
}
