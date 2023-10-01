const std = @import("std");
const ecs = @import("../ecs/mod.zig");
const c = ecs.c;
const aya = @import("../aya.zig");
const app = @import("mod.zig");
const systems = @import("systems.zig");

const phases = @import("phases.zig");

pub const AppExitEvent = struct {};

const Allocator = std.mem.Allocator;

const World = app.World;
const Resources = app.Resources;
const AssetServer = aya.AssetServer;
const Assets = aya.Assets;
const AssetLoader = aya.AssetLoader;

const SystemSort = systems.SystemSort;
const SystemPaused = systems.SystemPaused;
const AppWrapper = systems.AppWrapper;

const Events = app.Events;
const EventUpdateSystem = @import("event.zig").EventUpdateSystem;

const Res = app.Res;
const ResMut = app.ResMut;
const State = app.State;
const NextState = app.NextState;

const StateChangeCheckSystem = @import("state.zig").StateChangeCheckSystem;
const ScratchAllocator = @import("../mem/scratch_allocator.zig").ScratchAllocator;

const PhaseSort = struct { order: i32 };

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

pub const App = struct {
    const Self = @This();

    world: World,
    plugins: std.AutoHashMap(u32, void),
    phase_insert_indices: std.AutoHashMap(u64, i32),
    last_added_system: ?u64 = null,
    runFn: ?*const fn (*App) void = null,

    pub fn init() *Self {
        const world = World.init(allocator);

        tmp_allocator_instance = ScratchAllocator.init(allocator);
        tmp_allocator = tmp_allocator_instance.allocator();

        var self: *App = allocator.create(App) catch unreachable;
        self.* = .{
            .world = world,
            .plugins = std.AutoHashMap(u32, void).init(allocator),
            .phase_insert_indices = std.AutoHashMap(u64, i32).init(allocator),
        };

        // register startup phases
        self.world.ecs.registerComponents(.{ phases.PreStartup, phases.Startup, phases.PostStartup });

        // register our phases. The first one depends on nothing so we add it manually
        const phase_entity = aya.Entity.init(self.world.ecs, self.world.ecs.componentId(phases.First));
        phase_entity.add(c.EcsPhase);
        phase_entity.set(PhaseSort{ .order = 0 });

        _ = self.addPhase(phases.PreUpdate, .after, phases.First);
        _ = self.addPhase(phases.StateTransition, .after, phases.PreUpdate);
        _ = self.addPhase(phases.Update, .after, phases.StateTransition);
        _ = self.addPhase(phases.PostUpdate, .after, phases.Update);
        _ = self.addPhase(phases.Last, .after, phases.PostUpdate);

        world.ecs.setSingleton(&AppWrapper{ .app = self });
        self.enableTimers();
        return self.addEvent(AppExitEvent);
    }

    pub fn deinit(self: *Self) void {
        self.plugins.deinit();
        self.phase_insert_indices.deinit();
        tmp_allocator_instance.deinit();
        self.world.deinit();
        allocator.destroy(self);

        if (gpa.deinit() == .leak)
            std.debug.print("GPA has leaks. Check previous logs.\n", .{});
    }

    pub fn run(self: *Self) void {
        self.plugins.clearAndFree();

        runStartupPipeline(self.world.ecs);
        setCorePipeline(self.world.ecs);

        // main loop
        if (self.runFn) |runFn| runFn(self) else {
            self.world.ecs.progress(0);
            self.world.ecs.progress(0);
        }

        self.deinit();
    }

    /// Sets the function that will be called when the app is run. The runner function is called only once. If the
    /// presence of a main loop in the app is desired, it is the responsibility of the runner function to provide it.
    /// Note that startup systems will always be run before runFn is called.
    pub fn setRunner(self: *Self, runFn: *const fn (*App) void) *Self {
        self.runFn = runFn;
        return self;
    }

    /// available at: https://flecs.dev/explorer
    /// debug check if its running: http://localhost:27750/entity/flecs/core/World
    pub fn enableWebExplorer(self: *Self) *Self {
        if (!@import("options").include_flecs_explorer) return self;

        self.world.ecs.enableWebExplorer();

        // get the Flecs system running in our custom pipeline
        const phase = self.world.ecs.componentId(phases.Last);
        const rest_system = self.world.ecs.lookupFullPath("flecs.rest.DequeueRest") orelse @panic("could not find DequeueRest system");
        rest_system.add(phase);
        rest_system.set(systems.SystemSort{
            .phase = phase,
            .order_in_phase = self.getNextOrderInPhase(.last),
        });

        return self;
    }

    /// fixes all the flecs Timer systems so they run in our pipeline
    fn enableTimers(self: *Self) void {
        const phase = self.world.ecs.componentId(phases.First);
        const timer_systems = .{ "AddTickSource", "ProgressTimers", "ProgressRateFilters", "ProgressTickSource" };
        inline for (timer_systems) |sys| {
            if (self.world.ecs.lookupFullPath("flecs.timer." ++ sys)) |system| {
                system.add(phase);
                system.set(systems.SystemSort{
                    .phase = phase,
                    .order_in_phase = self.getNextOrderInPhase(phase),
                });
            }
        }
    }

    pub fn addPhase(self: *Self, comptime Phase: type, where: enum { before, after }, comptime OtherPhase: type) *Self {
        std.debug.assert(@sizeOf(Phase) == 0 and @sizeOf(OtherPhase) == 0);

        const other_phase = aya.Entity.init(self.world.ecs, self.world.ecs.componentId(OtherPhase));
        const other_sort_order = other_phase.get(PhaseSort).?.order;

        var phase_sort_map = std.AutoHashMap(u64, i32).init(aya.tmp_allocator);
        defer phase_sort_map.deinit();

        {
            // update any affected phases, those before/after the inserted phase
            var filter_desc = std.mem.zeroes(c.ecs_filter_desc_t);
            filter_desc.terms[0].id = self.world.ecs.componentId(PhaseSort);
            filter_desc.terms[0].inout = c.EcsInOut;
            filter_desc.terms[1].id = c.EcsPhase;
            filter_desc.terms[1].inout = c.EcsInOutNone;

            const filter = c.ecs_filter_init(self.world.ecs, &filter_desc);
            defer c.ecs_filter_fini(filter);

            var it = c.ecs_filter_iter(self.world.ecs, filter);
            while (c.ecs_filter_next(&it)) {
                const phase_sorts = ecs.field(&it, PhaseSort, 1);

                var i: usize = 0;
                while (i < it.count) : (i += 1) {
                    if (where == .after) {
                        if (phase_sorts[i].order > other_sort_order) {
                            phase_sorts[i].order += 1;
                            phase_sort_map.put(it.entities[i], phase_sorts[i].order) catch unreachable;
                        }
                    } else {
                        if (phase_sorts[i].order < other_sort_order) {
                            phase_sorts[i].order -= 1;
                            phase_sort_map.put(it.entities[i], phase_sorts[i].order) catch unreachable;
                        }
                    }
                }
            }
        }

        {
            // update any systems that are in the phases that changed their sort order
            var filter_desc = std.mem.zeroes(c.ecs_filter_desc_t);
            filter_desc.terms[0].id = self.world.ecs.componentId(SystemSort);
            filter_desc.terms[0].inout = c.EcsInOut;

            const filter = c.ecs_filter_init(self.world.ecs, &filter_desc);
            defer c.ecs_filter_fini(filter);

            var it = c.ecs_filter_iter(self.world.ecs, filter);
            while (c.ecs_filter_next(&it)) {
                var system_sorts = ecs.field(&it, SystemSort, 1);

                var i: usize = 0;
                while (i < it.count) : (i += 1) {
                    var sort = &system_sorts[i];

                    if (phase_sort_map.get(sort.phase)) |phase_order| {
                        sort.phase_order = phase_order;
                    }
                }
            }
        }

        // create the new phase and assign it an order relative to other_sort_order
        const phase_order = if (where == .before) other_sort_order - 1 else other_sort_order + 1;

        const phase = aya.Entity.init(self.world.ecs, self.world.ecs.componentId(Phase));
        phase.add(c.EcsPhase);
        phase.set(PhaseSort{ .order = phase_order });

        return self;
    }

    /// Plugins must implement `build(Self, *App)` and have default values for all fields
    pub fn addPlugin(self: *Self, comptime T: type) *Self {
        return self.insertPlugin(T{});
    }

    /// Allowed types: type (with `fn build(Self, *App)`) and default values for all fields), DefaultPlugins, struct instance
    /// (with `fn build(Self, *App)`)
    pub fn addPlugins(self: *Self, comptime plugins: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(plugins)) == .Struct or @typeInfo(@TypeOf(plugins)) == .Type);

        const ti = @typeInfo(@TypeOf(plugins));
        if (ti == .Struct and ti.Struct.is_tuple) {
            inline for (plugins) |T| {
                switch (@typeInfo(@TypeOf(T))) {
                    .Struct => _ = self.addPlugins(T),
                    .Type => _ = self.addPlugins(T{}),
                    else => |p| @compileError("cannot compare untagged union type " ++ @typeName(p)),
                }
            }
        } else if (ti == .Type and plugins == app.DefaultPlugins) {
            _ = self.addPlugins(app.DefaultPlugins.init());
        } else if (@TypeOf(plugins) == app.DefaultPlugins) {
            inline for (std.meta.fields(app.DefaultPlugins)) |field| {
                if (@field(plugins, field.name)) |plugin| _ = self.addPlugins(plugin);
            }
        } else if (ti == .Type) {
            return self.insertPlugin(plugins{});
        } else if (ti == .Struct) {
            return self.insertPlugin(plugins);
        }

        return self;
    }

    /// Inserts an instantiated plugin struct. Plugins must implement `build(Self, *App)`
    fn insertPlugin(self: *Self, value: anytype) *Self {
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

    // Events
    pub fn addEvent(self: *Self, comptime T: type) *Self {
        if (!self.world.containsResource(Events(T))) {
            return self.initResource(Events(T))
                .addSystem(phases.First, EventUpdateSystem(T));
        }

        return self;
    }

    // States
    pub fn addState(self: *Self, comptime T: type, current_state: T) *Self {
        std.debug.assert(@typeInfo(T) == .Enum);

        const enum_entity = self.world.ecs.newId();
        _ = c.ecs_add_id(self.world.ecs, enum_entity, c.EcsUnion);

        const EnumMap = std.enums.EnumMap(T, u64);
        var state_map = EnumMap{};
        var enter_state_map = EnumMap{};
        var exit_state_map = EnumMap{};

        for (std.enums.values(T)) |val| {
            state_map.put(val, c.ecs_new_id(self.world.ecs));
            enter_state_map.put(val, c.ecs_new_id(self.world.ecs));
            exit_state_map.put(val, c.ecs_new_id(self.world.ecs));
        }

        self.world.insertResource(State(T).init(enum_entity, current_state, state_map, enter_state_map, exit_state_map));
        self.world.insertResource(NextState(T).init(current_state));

        // add system for this T that will handle disabling/enabling systems with the state when it changes
        _ = self.addSystem(.state_transition, StateChangeCheckSystem(T));

        return self;
    }

    pub fn inState(self: *Self, comptime T: type, state: T) *Self {
        std.debug.assert(@typeInfo(T) == .Enum);

        if (self.last_added_system) |system| {
            // add the State tag entity to the system and disable it if the state isnt active
            const state_res = self.world.getResource(State(T)).?;

            const entity = ecs.Entity.init(self.world.ecs, system);
            entity.addPair(state_res.base_entity, state_res.entityForTag(state));

            if (state_res.state != state)
                entity.enable(false);

            self.last_added_system = null;
            return self;
        }
        @panic("inState called but there is no last_added_system to modify");
    }

    // Systems
    fn getNextOrderInPhase(self: *Self, phase: u64) i32 {
        var phase_insertions = self.phase_insert_indices.getOrPut(phase) catch unreachable;
        return blk: {
            if (!phase_insertions.found_existing) {
                phase_insertions.value_ptr.* = 0;
                break :blk 0;
            }
            phase_insertions.value_ptr.* += 1;
            break :blk phase_insertions.value_ptr.*;
        };
    }

    pub fn addSystem(self: *Self, comptime Phase: type, comptime T: type) *Self {
        std.debug.assert(@typeInfo(T) == .Struct);
        std.debug.assert(@hasDecl(T, "run"));

        const phase = self.world.ecs.componentId(Phase);
        const order_in_phase = self.getNextOrderInPhase(phase);
        const phase_order = if (aya.Entity.init(self.world.ecs, phase).get(PhaseSort)) |sort| sort.order else 0;

        self.last_added_system = systems.addSystem(self.world.ecs, phase, T);
        const system_entity = ecs.Entity.init(self.world.ecs, self.last_added_system.?);
        system_entity.set(SystemSort{
            .phase = phase,
            .phase_order = phase_order,
            .order_in_phase = order_in_phase,
        });

        return self;
    }

    /// phase_or_state can either be a tag of Phases or a State enum tag wrapped in OnEnter/OnExit
    pub fn addSystems(self: *Self, phase_or_state: anytype, comptime T: type) *Self {
        std.debug.assert(@typeInfo(T) == .Struct);
        std.debug.assert(@hasDecl(T, "run"));

        if (@typeInfo(@TypeOf(phase_or_state)) == .EnumLiteral) {
            return self.addSystem(phase_or_state, T);
        } else if (@hasDecl(phase_or_state, "state_type")) {
            // OnEnter/OnExit systems are not associated with a phase or sort
            var state_res = self.world.getResource(State(phase_or_state.state_type)).?;

            // find the enter/exit entity so we can put it on the system
            const state_entity = if (@hasDecl(phase_or_state, "on_enter")) state_res.entityForEnterTag(phase_or_state.state) else state_res.entityForExitTag(phase_or_state.state);

            // add our system but without a phase so it isnt in the normal schedule
            const system_id = systems.addSystem(self.world.ecs, 0, T);
            c.ecs_add_id(self.world.ecs, system_id, state_entity);

            return self;
        } else if (@typeInfo(@TypeOf(phase_or_state)) == .Type) {
            return self.addSystem(phase_or_state, T);
        }

        @panic("addSystems called with invalid params. phase_or_state must be OnEnter/OnExit or a Phase type");
    }

    pub fn before(self: *Self, comptime T: type) *Self {
        if (self.last_added_system) |system| {
            const entity = ecs.Entity.init(self.world.ecs, system);

            // find the other system by its name and grab its SystemSort
            const system_name = if (@hasDecl(T, "name")) T.name else aya.utils.typeNameLastComponent(T);
            const other_entity = self.world.ecs.lookupFullPath(system_name) orelse @panic("could not find other system");
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
        var filter_desc = std.mem.zeroes(c.ecs_filter_desc_t);
        filter_desc.terms[0].id = self.world.ecs.componentId(SystemSort);
        filter_desc.terms[0].inout = c.EcsInOut;

        const filter = c.ecs_filter_init(self.world.ecs, &filter_desc);
        defer c.ecs_filter_fini(filter);

        var it = c.ecs_filter_iter(self.world.ecs, filter);
        while (c.ecs_filter_next(&it)) {
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

    const phase_1: c_int = if (sort1.phase_order > sort2.phase_order) 1 else 0;
    const phase_2: c_int = if (sort1.phase_order < sort2.phase_order) 1 else 0;

    // sort by: phase_order, order_in_phase then entity_id
    if (sort1.phase == sort2.phase) {
        // std.debug.print("SAME PHASE ({}). order_in_phase: {} vs {}, phase_order: {} vs {}, entity: {}, {}\n", .{ sort1.phase, sort1.order_in_phase, sort2.order_in_phase, sort1.phase_order, sort2.phase_order, e1, e2 });
        const order_1: c_int = if (sort1.order_in_phase > sort2.order_in_phase) 1 else 0;
        const order_2: c_int = if (sort1.order_in_phase < sort2.order_in_phase) 1 else 0;

        const order_in_phase = order_1 - order_2;
        if (order_in_phase != 0) return order_in_phase;

        // systems that didnt specify order will be sorted by entity
        const first: c_int = if (e1 > e2) 1 else 0;
        const second: c_int = if (e1 < e2) 1 else 0;

        return first - second;
    }

    return phase_1 - phase_2;
}

/// runs a Pipeline that matches only the startup phases then deletes all systems in those phases
fn runStartupPipeline(world: *c.ecs_world_t) void {
    var pip_desc = std.mem.zeroes(c.ecs_pipeline_desc_t);
    pip_desc.entity = c.ecs_entity_init(world, &std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = "StartupPipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = world.componentId(SystemSort);

    pip_desc.query.filter.terms[0].id = c.EcsSystem;
    pip_desc.query.filter.terms[1] = std.mem.zeroInit(c.ecs_term_t, .{
        .id = world.componentId(phases.PreStartup),
        .oper = c.EcsOr,
    });
    pip_desc.query.filter.terms[2] = std.mem.zeroInit(c.ecs_term_t, .{
        .id = world.componentId(phases.Startup),
        .oper = c.EcsOr,
    });
    pip_desc.query.filter.terms[3].id = world.componentId(phases.PostStartup);
    pip_desc.query.filter.terms[4] = std.mem.zeroInit(c.ecs_term_t, .{
        .id = world.componentId(SystemSort),
        .inout = c.EcsIn,
    });

    const startup_pipeline = c.ecs_pipeline_init(world, &pip_desc);
    c.ecs_set_pipeline(world, startup_pipeline);
    _ = c.ecs_progress(world, 0);

    c.ecs_delete_with(world, world.componentId(phases.PreStartup));
    c.ecs_delete_with(world, world.componentId(phases.Startup));
    c.ecs_delete_with(world, world.componentId(phases.PostStartup));
}

/// creates and sets a Pipeline that handles system sorting
fn setCorePipeline(world: *c.ecs_world_t) void {
    var pip_desc = std.mem.zeroes(c.ecs_pipeline_desc_t);
    pip_desc.entity = c.ecs_entity_init(world, &std.mem.zeroInit(c.ecs_entity_desc_t, .{ .name = "CorePipeline" }));
    pip_desc.query.order_by = pipelineSystemSortCompare;
    pip_desc.query.order_by_component = world.componentId(SystemSort);

    pip_desc.query.filter.terms[0].id = c.EcsSystem;

    pip_desc.query.filter.terms[1].id = world.componentId(SystemSort);
    pip_desc.query.filter.terms[1].inout = c.EcsInOutNone;

    pip_desc.query.filter.terms[2].id = world.componentId(SystemPaused); // does not have SystemPaused
    pip_desc.query.filter.terms[2].inout = c.EcsInOutNone;
    pip_desc.query.filter.terms[2].oper = c.EcsNot;

    pip_desc.query.filter.terms[3] = std.mem.zeroInit(c.ecs_term_t, .{
        .id = c.EcsDisabled,
        .src = std.mem.zeroInit(c.ecs_term_id_t, .{
            .flags = c.EcsUp,
            .trav = c.EcsDependsOn,
        }),
        .oper = c.EcsNot,
    });
    pip_desc.query.filter.terms[4] = std.mem.zeroInit(c.ecs_term_t, .{
        .id = c.EcsDisabled,
        .src = std.mem.zeroInit(c.ecs_term_id_t, .{
            .flags = c.EcsUp,
            .trav = c.EcsChildOf,
        }),
        .oper = c.EcsNot,
    });

    const pipeline = c.ecs_pipeline_init(world, &pip_desc);
    c.ecs_set_pipeline(world, pipeline);
}
