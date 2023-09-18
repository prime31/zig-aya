const std = @import("std");
const ecs = @import("ecs");
const flecs = ecs.c;
const aya = @import("../aya.zig");
const app = @import("mod.zig");
const assets = @import("../asset/mod.zig");

const typeId = aya.utils.typeId;

const Allocator = std.mem.Allocator;

const World = app.World;
const Resources = app.Resources;
const AssetServer = aya.AssetServer;
const Assets = aya.Assets;
const AssetLoader = assets.AssetLoader;

pub const App = struct {
    const Self = @This();

    world: World,
    plugins: std.AutoHashMap(u32, void),
    phase_insert_indices: std.AutoHashMap(u64, i32),

    pub fn init(allocator: Allocator) Self {
        return .{
            .world = World.init(allocator),
            .plugins = std.AutoHashMap(u32, void).init(allocator),
            .phase_insert_indices = std.AutoHashMap(u64, i32).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.world.deinit();
        self.plugins.deinit();
        self.phase_insert_indices.deinit();
    }

    fn addDefaultPlugins(self: *Self) void {
        _ = self.addPlugin(aya.AssetsPlugin)
            .addPlugin(aya.InputPlugin)
            .addPlugin(aya.WindowPlugin);
    }

    pub fn run(self: *Self) void {
        self.addDefaultPlugins();
        self.plugins.clearAndFree();
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
        const asset_server = self.world.getResource(AssetServer) orelse @panic("AssetServer not found in Resources");
        asset_server.registerLoader(T, loadFn);
        return self;
    }

    // Resources
    pub fn insertResource(self: *Self, resource: anytype) *App {
        self.world.insertResource(resource);
        return self;
    }

    pub fn initResource(self: *Self, comptime T: type) *App {
        self.world.initResource(T);
        return self;
    }

    // States
    pub fn addState(self: *Self, comptime T: type, current_state: T) *App {
        std.debug.assert(@typeInfo(T) == .Enum);

        std.debug.print("state: {}\n", .{current_state});
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

    // Systems
    pub fn addSystem(self: *Self, name: [*:0]const u8, phase: u64, runFn: anytype) *App {
        var phase_insertions = self.phase_insert_indices.getOrPut(phase) catch unreachable;
        const order_in_phase = blk: {
            if (!phase_insertions.found_existing) {
                phase_insertions.value_ptr.* = 0;
                break :blk 0;
            }
            phase_insertions.value_ptr.* += 1;
            break :blk phase_insertions.value_ptr.*;
        };

        var system_desc: flecs.ecs_system_desc_t = std.mem.zeroInit(flecs.ecs_system_desc_t, .{ .run = runFn });
        ecs.SYSTEM(self.world.ecs, name, phase, order_in_phase, &system_desc);
        return self;
    }

    pub fn addSystemAfter(self: *Self, name: [*:0]const u8, phase: u64, runFn: anytype, after_system: []const u8) *App {
        const other_system = flecs.ecs_lookup(self.world.ecs, after_system.ptr);
        if (other_system == 0) @panic("addSystemAfter could not find after_system");

        const other_sort = ecs.get(self.world.ecs, other_system, ecs.SystemSort).?;
        if (other_sort.phase != phase) @panic("other_system is in a different phase. Cannot addSystemAfter unless they are in the same phase");
        const other_order_in_phase = other_sort.order_in_phase;
        std.debug.print("other_order_in_phase: {}\n", .{other_order_in_phase});

        var filter_desc = std.mem.zeroes(flecs.ecs_filter_desc_t);
        filter_desc.terms[0].id = ecs.COMPONENT(self.world.ecs, ecs.SystemSort);
        filter_desc.terms[0].inout = flecs.EcsInOut;

        const filter = flecs.ecs_filter_init(self.world.ecs, &filter_desc);
        defer flecs.ecs_filter_fini(filter);

        var it = flecs.ecs_filter_iter(self.world.ecs, filter);
        while (flecs.ecs_filter_next(&it)) {
            const system_sorts = ecs.field(&it, ecs.SystemSort, 1);

            var i: usize = 0;
            while (i < it.count) : (i += 1) {
                if (system_sorts[i].phase == phase and system_sorts[i].order_in_phase > other_order_in_phase) {
                    std.debug.print("iter: {d}, entity: {}, sort: {}\n", .{ i, it.entities[i], system_sorts[i] });
                    system_sorts[i].order_in_phase += 1;
                }
            }
        }

        // increment our phase_insert_indices since we are adding a new system
        var phase_insertion = self.phase_insert_indices.getPtr(phase).?;
        phase_insertion.* += 1;

        var system_desc: flecs.ecs_system_desc_t = std.mem.zeroInit(flecs.ecs_system_desc_t, .{ .run = runFn });
        ecs.SYSTEM(self.world.ecs, name, phase, other_order_in_phase + 1, &system_desc);
        std.debug.print("new order_in_phase: {}\n", .{other_order_in_phase + 1});

        return self;
    }

    pub fn addSystemBefore(self: *Self, name: [*:0]const u8, phase: u64, runFn: anytype, before_system: []const u8) *App {
        const other_system = flecs.ecs_lookup(self.world.ecs, before_system.ptr);
        if (other_system == 0) @panic("addSystemAfter could not find after_system");

        const other_sort = ecs.get(self.world.ecs, other_system, ecs.SystemSort).?;
        if (other_sort.phase != phase) @panic("other_system is in a different phase. Cannot addSystemAfter unless they are in the same phase");
        const other_order_in_phase = other_sort.order_in_phase;
        std.debug.print("other_order_in_phase: {}\n", .{other_order_in_phase});

        var filter_desc = std.mem.zeroes(flecs.ecs_filter_desc_t);
        filter_desc.terms[0].id = ecs.COMPONENT(self.world.ecs, ecs.SystemSort);
        filter_desc.terms[0].inout = flecs.EcsInOut;

        const filter = flecs.ecs_filter_init(self.world.ecs, &filter_desc);
        defer flecs.ecs_filter_fini(filter);

        var it = flecs.ecs_filter_iter(self.world.ecs, filter);
        while (flecs.ecs_filter_next(&it)) {
            const system_sorts = ecs.field(&it, ecs.SystemSort, 1);

            var i: usize = 0;
            while (i < it.count) : (i += 1) {
                if (system_sorts[i].phase == phase and system_sorts[i].order_in_phase < other_order_in_phase) {
                    std.debug.print("iter: {d}, entity: {}, sort: {}\n", .{ i, it.entities[i], system_sorts[i] });
                    system_sorts[i].order_in_phase -= 1;
                }
            }
        }

        // increment our phase_insert_indices since we are adding a new system
        var phase_insertion = self.phase_insert_indices.getPtr(phase).?;
        phase_insertion.* -= 1;

        var system_desc: flecs.ecs_system_desc_t = std.mem.zeroInit(flecs.ecs_system_desc_t, .{ .run = runFn });
        ecs.SYSTEM(self.world.ecs, name, phase, other_order_in_phase - 1, &system_desc);
        std.debug.print("new order_in_phase: {}\n", .{other_order_in_phase - 1});

        return self;
    }
};

// states, organize these
pub fn State(comptime T: type) type {
    return struct { current: T };
}

pub fn NextState(comptime T: type) type {
    return struct {
        const Self = @This();
        state: T,

        pub fn set(self: Self, new_state: T) void {
            self.state = new_state;
        }
    };
}
