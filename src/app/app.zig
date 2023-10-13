const std = @import("std");
const ecs = @import("../ecs/mod.zig");
const c = ecs.c;
const aya = @import("../aya.zig");
const app = @import("mod.zig");
const systems = @import("systems.zig");

const phases = @import("phases.zig");
const assertMsg = aya.meta.assertMsg;

pub const AppExitEvent = struct {};

const Allocator = std.mem.Allocator;

const World = app.World;
const Resources = app.Resources;
const AssetServer = aya.AssetServer;
const Assets = aya.Assets;
const AssetLoader = aya.AssetLoader;
const Entity = aya.Entity;

const SystemSort = systems.SystemSort;
const SystemPaused = systems.SystemPaused;
const AppWrapper = systems.AppWrapper;

const Events = app.Events;
const EventUpdateSystem = @import("event.zig").EventUpdateSystem;

const FromTransition = @import("state.zig").FromTransition;
const ToTransition = @import("state.zig").ToTransition;
const Res = app.Res;
const ResMut = app.ResMut;
const State = app.State;
const NextState = app.NextState;

const StateChangeCheckSystem = @import("state.zig").StateChangeCheckSystem;
const ScratchAllocator = @import("../mem/scratch_allocator.zig").ScratchAllocator;

const PhaseSort = struct { order: i32 };
// relation tagging system sets
const SystemSet = struct {};

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
    set_insert_indices: std.AutoHashMap(u64, i32),
    last_added_systems: std.ArrayList(u64),
    runFn: ?*const fn (*App) void = null,

    pub fn init() *Self {
        const world = World.init(allocator);

        tmp_allocator_instance = ScratchAllocator.init(allocator);
        tmp_allocator = tmp_allocator_instance.allocator();

        var self: *App = aya.mem.create(App);
        self.* = .{
            .world = world,
            .plugins = std.AutoHashMap(u32, void).init(allocator),
            .phase_insert_indices = std.AutoHashMap(u64, i32).init(allocator),
            .set_insert_indices = std.AutoHashMap(u64, i32).init(allocator),
            .last_added_systems = std.ArrayList(u64).init(allocator),
        };

        // register startup phases
        self.world.ecs.getEntity(phases.Startup).add(c.EcsPhase);
        self.world.ecs.registerComponents(.{ phases.PreStartup, phases.Startup, phases.PostStartup });

        // register our phases. The first one depends on nothing so we add it manually
        const phase_entity = self.world.ecs.getEntity(phases.First);
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
        self.set_insert_indices.deinit();
        self.last_added_systems.deinit();
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
        if (!@import("build_options").include_flecs_explorer) return self;

        self.world.ecs.enableWebExplorer();

        // get the Flecs system running in our custom pipeline
        const phase = self.world.ecs.componentId(phases.Last);
        const rest_system = self.world.ecs.lookupFullPath("flecs.rest.DequeueRest") orelse @panic("could not find DequeueRest system");
        rest_system.add(phase);
        rest_system.set(systems.SystemSort{
            .phase = phase,
            .order_in_phase = self.getNextOrderInPhase(self.world.ecs.componentId(aya.Last)),
        });

        std.debug.print("Flecs explorer enabled. Go to: https://flecs.dev/explorer\n", .{});

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

        const other_phase = self.world.ecs.getEntity(OtherPhase);
        const other_sort_order = other_phase.get(PhaseSort).?.order;

        var phase_sort_map = std.AutoHashMap(u64, i32).init(aya.tmp_allocator);
        defer phase_sort_map.deinit();

        {
            // update any affected phases, those before/after the inserted phase
            var filter_desc = c.ecs_filter_desc_t{};
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
            var filter_desc = c.ecs_filter_desc_t{};
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

        const phase = self.world.ecs.getEntity(Phase);
        phase.add(c.EcsPhase);
        phase.set(PhaseSort{ .order = phase_order });

        return self;
    }

    /// Allowed types: type (with `fn build(Self, *App)`) and default values for all fields), struct instance
    /// (with `fn build(Self, *App)`), DefaultPlugins or an instance of DefaultPlugins
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
    /// adds relevant resources, events and systems for handling an asset. If T.prepareAsset exists, RenderAssetPlugin will also
    /// be added which allows converteing an asset to a different format (eg Image -> GpuImage).
    pub fn initAsset(self: *Self, comptime T: type) *Self {
        // if the asset has a `prepareAsset` method add the RenderAssetPlugin so that it can process the asset after loading it
        if (@hasDecl(T, "prepareAsset"))
            _ = self.addPlugins(aya.RenderAssetPlugin(T));

        return self
            .initResource(Assets(T))
            .addEvent(aya.AssetEvent(T))
            .addSystems(aya.PostUpdate, aya.AssetChangeEventSystem(T)); // TODO: add AssetEvents phase after PostUpdate perhaps?
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

        const enum_entity = self.world.ecs.newEntityNamed(@typeName(T)).id;
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
        _ = self.addSystem(phases.StateTransition, StateChangeCheckSystem(T));

        return self;
    }

    pub fn inState(self: *Self, comptime state: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(state)) == .Enum);
        std.debug.assert(self.last_added_systems.items.len > 0);

        // add the State tag entity to the system and disable it if the state isnt active
        const state_res = self.world.getResource(State(@TypeOf(state))).?;

        for (self.last_added_systems.items) |system| {
            const entity = self.world.ecs.getEntity(system);
            entity.addPair(state_res.base_entity, state_res.entityForTag(state));

            if (state_res.state != state)
                entity.enable(false);
        }
        return self;
    }

    // System Sets
    fn createSystemSet(self: *Self, comptime T: type, phase: u64) Entity {
        const set_entity = self.world.ecs.getEntity(T);
        assertMsg(!set_entity.has(SystemSet), "attempting to create Set {s} but it already exists", .{@typeName(T)});

        const phase_order = self.world.ecs.getEntity(phase).get(PhaseSort).?.order;
        const order_in_phase = self.getNextOrderInPhase(phase);

        set_entity.add(SystemSet);
        set_entity.set(SystemSort{
            .phase = phase,
            .phase_order = phase_order,
            .order_in_phase = order_in_phase,
        });

        return set_entity;
    }

    /// adds a system set to Phase. If ordering via configureSystemSet isnt required then system sets can be added
    /// on-the-fly addSystems
    pub fn addSets(self: *Self, comptime Phase: type, Sets: anytype) *Self {
        const phase = self.world.ecs.componentId(Phase);
        std.debug.assert(self.world.ecs.getEntity(phase).has(c.EcsPhase));

        // normalize a single Set or a tuple of Sets to an array of Sets
        const ti = @typeInfo(@TypeOf(Sets));
        const new_sets = if (ti == .Struct and ti.Struct.is_tuple) Sets else .{Sets};
        inline for (new_sets) |Set| _ = self.createSystemSet(Set, phase);

        return self;
    }

    /// adds a system set relative to SetOrSystem
    pub fn configureSets(self: *Self, Sets: anytype, where: enum { before, after }, comptime SetOrSystem: type) *Self {
        const other_sort: SystemSort = if (@hasDecl(SetOrSystem, "run")) blk: {
            break :blk self.getSystemSortForSystemType(SetOrSystem);
        } else self.world.ecs.getEntity(SetOrSystem).get(SystemSort).?.*; // we want a copy because we are gonna mutate the archtype!

        // normalize a single Set or a tuple of Sets to an array of Sets
        const ti = @typeInfo(@TypeOf(Sets));
        const new_sets = if (ti == .Struct and ti.Struct.is_tuple) Sets else .{Sets};
        inline for (new_sets) |Set| {
            std.debug.assert(@typeInfo(Set) == .Struct and @sizeOf(Set) == 0);

            // create the Set if it doesnt already exist
            const set_entity = self.createSystemSet(Set, other_sort.phase);
            const set_sort: *SystemSort = set_entity.getMut(SystemSort);
            assertMsg(set_sort.phase == other_sort.phase, "cannot order System Set with a system or set that is in a different phase", .{});

            // move Set's order_in_phase relative to the other SetOrSystem then shift all systems
            set_sort.order_in_phase = if (where == .before) other_sort.order_in_phase - 1 else other_sort.order_in_phase + 1;
            self.updateSystemOrder(set_sort.phase, other_sort.order_in_phase, if (where == .before) -1 else 1);
        }

        return self;
    }

    /// fetches the last inserted index in the given phase then increments and returns it
    fn getNextOrderInSet(self: *Self, set: u64) i32 {
        var set_insertions = self.set_insert_indices.getOrPut(set) catch unreachable;
        return blk: {
            if (!set_insertions.found_existing) {
                set_insertions.value_ptr.* = 0;
                break :blk 0;
            }
            set_insertions.value_ptr.* += 1;
            break :blk set_insertions.value_ptr.*;
        };
    }

    // Systems
    fn getSystemSortForSystemType(self: *const Self, comptime T: type) *const SystemSort {
        const system_name = if (@hasDecl(T, "name")) T.name else aya.utils.typeNameLastComponent(T);
        const entity = self.world.ecs.lookupFullPath(system_name) orelse @panic("could not find other system: " ++ @typeName(T));
        return entity.get(SystemSort) orelse @panic("other does not appear to be a system");
    }

    /// fetches the last inserted index in the given phase then increments and returns it
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

    // Phase can be a Phase type or a phase entity (64)
    fn addSystem(self: *Self, Phase: anytype, comptime T: type) *Self {
        std.debug.assert(@typeInfo(T) == .Struct);
        std.debug.assert(@hasDecl(T, "run"));
        std.debug.assert(@TypeOf(Phase) == type or @TypeOf(Phase) == u64);

        const phase = if (@TypeOf(Phase) == type) self.world.ecs.componentId(Phase) else Phase;
        const order_in_phase = self.getNextOrderInPhase(phase);
        const phase_order = if (self.world.ecs.getEntity(phase).get(PhaseSort)) |sort| sort.order else 0;

        const sys = systems.addSystem(self.world.ecs, phase, T);
        self.last_added_systems.append(sys) catch unreachable;

        const system_entity = self.world.ecs.getEntity(sys);
        system_entity.set(SystemSort{
            .phase = phase,
            .phase_order = phase_order,
            .order_in_phase = order_in_phase,
            .set = 0,
        });

        return self;
    }

    fn addSystemInSet(self: *Self, comptime Set: type, comptime T: type) void {
        const set_entity = self.world.ecs.getEntity(Set);
        std.debug.assert(set_entity.has(SystemSet));

        const set_sort: *const SystemSort = set_entity.get(SystemSort).?;
        _ = self.addSystem(set_sort.phase, T);
        const system_entity = self.world.ecs.getEntity(self.last_added_systems.getLast());

        // add the SystemSet pair to the system
        system_entity.addPair(SystemSet, set_entity.id);

        // update the system's SystemSort with the order_in_phase/set/order_in_set from the set
        const system_sort = system_entity.getMut(SystemSort);
        system_sort.order_in_phase = set_sort.order_in_phase;
        system_sort.set = set_entity.id;
        system_sort.order_in_set = self.getNextOrderInSet(set_entity.id);
    }

    /// phase_state_set can either be a Phase tag, a State enum tag wrapped in OnEnter/OnExit/OnTransition or a SystemSet
    /// Systems should be a single type or a tuple of types
    pub fn addSystems(self: *Self, phase_state_set: anytype, comptime Systems: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(Systems)) == .Struct or @typeInfo(Systems) == .Struct);

        self.last_added_systems.clearRetainingCapacity();

        // normalize a single system or a tuple of systems to an array of systems
        const ti = @typeInfo(@TypeOf(Systems));
        const new_systems = if (ti == .Struct and ti.Struct.is_tuple) Systems else .{Systems};

        inline for (new_systems) |T| {
            std.debug.assert(@hasDecl(T, "run"));

            if (@hasDecl(phase_state_set, "state_type")) {
                // OnEnter/OnExit systems are not associated with a phase or sort
                var state_res = self.world.getResource(State(phase_state_set.state_type)).?;

                // add our system but without a phase so it isnt in the normal schedule
                const system_id = systems.addSystem(self.world.ecs, 0, T);

                if (@hasDecl(phase_state_set, "on_transition")) {
                    const from = state_res.entityForTag(phase_state_set.from_state);
                    const to = state_res.entityForTag(phase_state_set.to_state);
                    c.ecs_add_id(self.world.ecs, system_id, self.world.ecs.pair(FromTransition, from));
                    c.ecs_add_id(self.world.ecs, system_id, self.world.ecs.pair(ToTransition, to));
                } else {
                    // find the enter/exit entity so we can put it on the system
                    const state_entity = if (@hasDecl(phase_state_set, "on_enter")) state_res.entityForEnterTag(phase_state_set.state) else state_res.entityForExitTag(phase_state_set.state);
                    c.ecs_add_id(self.world.ecs, system_id, state_entity);
                }
            } else if (@typeInfo(@TypeOf(phase_state_set)) == .Type) {
                const type_id = self.world.ecs.typeId(phase_state_set);
                assertMsg(type_id > 0, "invalid argument. param must be a valid, registered Phase or SystemSet", .{});
                if (c.ecs_has_id(self.world.ecs, type_id, c.EcsPhase)) {
                    _ = self.addSystem(phase_state_set, T);
                } else {
                    self.addSystemInSet(phase_state_set, T);
                }
            } else {
                @panic("addSystems called with invalid params. phase_or_state must be OnEnter/OnExit/OnTransition or a phase type. Systems must be a system struct or tuple of system structs");
            }
        }

        return self;
    }

    pub fn before(self: *Self, comptime SystemOrSet: type) *Self {
        self.shiftLastAddedSystems(.before, SystemOrSet);
        return self;
    }

    pub fn after(self: *Self, comptime SystemOrSet: type) *Self {
        self.shiftLastAddedSystems(.after, SystemOrSet);
        return self;
    }

    fn shiftLastAddedSystems(self: *Self, where: enum { before, after }, comptime SystemOrSet: type) void {
        std.debug.assert(self.last_added_systems.items.len > 0);

        // grab the SystemSort from the other System or SystemSet
        const other_sort: *const SystemSort = if (@hasDecl(SystemOrSet, "run")) blk: {
            break :blk self.getSystemSortForSystemType(SystemOrSet);
        } else self.world.ecs.getEntity(SystemOrSet).get(SystemSort).?;

        const direction: i32 = if (where == .before) -1 else 1;
        for (self.last_added_systems.items) |system| {
            const entity = self.world.ecs.getEntity(system);

            const current_sort = entity.getMut(SystemSort);
            if (other_sort.phase != current_sort.phase) @panic("SystemOrSet " ++ @typeName(SystemOrSet) ++ " is in a different phase. Cannot add before unless they are in the same phase");

            // if both systems are in the same set we update order_in_set instead of order_in_phase
            if (other_sort.set > 0 and other_sort.set == current_sort.set) {
                current_sort.order_in_set = other_sort.order_in_set + direction;
                self.updateSystemOrderInSet(current_sort.set, other_sort.order_in_set, direction);
            } else {
                current_sort.order_in_phase = other_sort.order_in_phase + direction;
                self.updateSystemOrder(current_sort.phase, other_sort.order_in_phase, direction);
            }
        }
    }

    fn updateSystemOrder(self: *Self, phase: u64, other_order_in_phase: i32, direction: i32) void {
        var filter_desc = c.ecs_filter_desc_t{};
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

    fn updateSystemOrderInSet(self: *Self, set: u64, other_order_in_set: i32, direction: i32) void {
        var filter_desc = c.ecs_filter_desc_t{};
        filter_desc.terms[0].id = self.world.ecs.componentId(SystemSort);
        filter_desc.terms[0].inout = c.EcsInOut;

        const filter = c.ecs_filter_init(self.world.ecs, &filter_desc);
        defer c.ecs_filter_fini(filter);

        var it = c.ecs_filter_iter(self.world.ecs, filter);
        while (c.ecs_filter_next(&it)) {
            const system_sorts = ecs.field(&it, SystemSort, 1);

            var i: usize = 0;
            while (i < it.count) : (i += 1) {
                if (system_sorts[i].set != set) continue;
                if (direction > 0) {
                    if (system_sorts[i].order_in_set > other_order_in_set)
                        system_sorts[i].order_in_set += direction;
                } else {
                    if (system_sorts[i].order_in_set < other_order_in_set)
                        system_sorts[i].order_in_set += direction;
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

/// runs a Pipeline that matches only the startup phases then deletes all systems in those phases
fn runStartupPipeline(world: *c.ecs_world_t) void {
    var pip_desc = c.ecs_pipeline_desc_t{
        .entity = c.ecs_entity_init(world, &.{ .name = "StartupPipeline" }),
        .query = .{
            .order_by = pipelineSystemSortCompare,
            .order_by_component = world.componentId(SystemSort),
        },
    };

    pip_desc.query.filter.terms[0].id = c.EcsSystem;
    pip_desc.query.filter.terms[1] = .{
        .id = world.componentId(phases.PreStartup),
        .oper = c.EcsOr,
    };
    pip_desc.query.filter.terms[2] = .{
        .id = world.componentId(phases.Startup),
        .oper = c.EcsOr,
    };
    pip_desc.query.filter.terms[3].id = world.componentId(phases.PostStartup);
    pip_desc.query.filter.terms[4] = .{
        .id = world.componentId(SystemSort),
        .inout = c.EcsIn,
    };

    const startup_pipeline = c.ecs_pipeline_init(world, &pip_desc);
    c.ecs_set_pipeline(world, startup_pipeline);
    _ = c.ecs_progress(world, 0);

    c.ecs_delete_with(world, world.componentId(phases.PreStartup));
    c.ecs_delete_with(world, world.componentId(phases.Startup));
    c.ecs_delete_with(world, world.componentId(phases.PostStartup));
}

/// creates and sets a Pipeline that handles system sorting
fn setCorePipeline(world: *c.ecs_world_t) void {
    var pip_desc = c.ecs_pipeline_desc_t{
        .entity = c.ecs_entity_init(world, &.{ .name = "CorePipeline" }),
        .query = .{
            .order_by = pipelineSystemSortCompare,
            .order_by_component = world.componentId(SystemSort),
        },
    };

    pip_desc.query.filter.terms[0].id = c.EcsSystem;

    pip_desc.query.filter.terms[1].id = world.componentId(SystemSort);
    pip_desc.query.filter.terms[1].inout = c.EcsInOutNone;

    pip_desc.query.filter.terms[2].id = world.componentId(SystemPaused); // does not have SystemPaused
    pip_desc.query.filter.terms[2].inout = c.EcsInOutNone;
    pip_desc.query.filter.terms[2].oper = c.EcsNot;

    pip_desc.query.filter.terms[3] = .{
        .id = c.EcsDisabled,
        .src = .{
            .flags = c.EcsUp,
            .trav = c.EcsDependsOn,
        },
        .oper = c.EcsNot,
    };
    pip_desc.query.filter.terms[4] = .{
        .id = c.EcsDisabled,
        .src = .{
            .flags = c.EcsUp,
            .trav = c.EcsChildOf,
        },
        .oper = c.EcsNot,
    };

    const pipeline = c.ecs_pipeline_init(world, &pip_desc);
    c.ecs_set_pipeline(world, pipeline);
}

fn pipelineSystemSortCompare(e1: u64, ptr1: ?*const anyopaque, e2: u64, ptr2: ?*const anyopaque) callconv(.C) c_int {
    if (e1 == e2) return 0;

    const sort1 = @as(*const SystemSort, @ptrCast(@alignCast(ptr1)));
    const sort2 = @as(*const SystemSort, @ptrCast(@alignCast(ptr2)));

    // sort by: phase_order, order_in_phase, if(in_set) order_in_set, then entity_id
    if (sort1.phase == sort2.phase) {
        // std.debug.print("SAME PHASE ({}). order_in_phase: {} vs {}, phase_order: {} vs {}, entity: {}, {}\n", .{ sort1.phase, sort1.order_in_phase, sort2.order_in_phase, sort1.phase_order, sort2.phase_order, e1, e2 });
        const order_1: c_int = if (sort1.order_in_phase > sort2.order_in_phase) 1 else 0;
        const order_2: c_int = if (sort1.order_in_phase < sort2.order_in_phase) 1 else 0;

        const order_in_phase = order_1 - order_2;
        if (order_in_phase != 0) return order_in_phase;

        // if both systems are in a matching set, use the order_in_set
        if (sort1.set > 0 and sort1.set == sort2.set) {
            const order_in_set_1: c_int = if (sort1.order_in_set > sort2.order_in_set) 1 else 0;
            const order_in_set_2: c_int = if (sort1.order_in_set < sort2.order_in_set) 1 else 0;

            return order_in_set_1 - order_in_set_2;
        }

        // systems that didnt specify order will be sorted by entity
        const first: c_int = if (e1 > e2) 1 else 0;
        const second: c_int = if (e1 < e2) 1 else 0;

        return first - second;
    }

    const phase_1: c_int = if (sort1.phase_order > sort2.phase_order) 1 else 0;
    const phase_2: c_int = if (sort1.phase_order < sort2.phase_order) 1 else 0;

    return phase_1 - phase_2;
}
