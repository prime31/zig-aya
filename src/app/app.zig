const std = @import("std");
const aya = @import("../aya.zig");

const typeId = aya.utils.typeId;

const Allocator = std.mem.Allocator;

pub const World = @import("world.zig").World;
pub const Resources = @import("resources.zig").Resources;

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
        _ = T;
        // let assets = Assets::<T>::default();
        // self.world.resource::<AssetServer>().register_asset(&assets);
        return self;
    }

    pub fn initAssetLoader(self: *Self, comptime T: type) *Self {
        _ = T;
        // self.world.resource::<AssetServer>().register_loader(loader);
        return self;
    }

    // Resources
    pub fn insertResource(self: *Self, resource: anytype) *App {
        self.world.insert(resource);
        return self;
    }

    pub fn initResource(self: *Self, comptime T: type) *App {
        self.world.initResource(T);
        return self;
    }
};
