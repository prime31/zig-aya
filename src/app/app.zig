const std = @import("std");
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

    pub fn init(allocator: Allocator) Self {
        return .{
            .world = World.init(allocator),
            .plugins = std.AutoHashMap(u32, void).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.world.deinit();
        self.plugins.deinit();
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
