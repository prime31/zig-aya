const std = @import("std");
const typeId = @import("../type_id.zig").typeId;

const Allocator = std.mem.Allocator;
const World = @import("world.zig").World;
const AssetPlugin = @import("../assets/assets.zig").AssetPlugin;

pub const App = struct {
    const Self = @This();

    world: World,

    pub fn init(allocator: Allocator) Self {
        var app = Self{ .world = World.init(allocator) };
        _ = app.addPlugin(AssetPlugin);
        return app;
    }

    pub fn deinit(self: *Self) void {
        self.world.deinit();
    }

    pub fn run(self: *Self) void {
        _ = self;
    }

    // Plugins
    pub fn addPlugin(self: *Self, comptime T: type) *Self {
        std.mem.zeroes(T).build(self);
        return self;
    }

    pub fn addPlugins(self: *Self, comptime types: anytype) *Self {
        std.debug.assert(@typeInfo(@TypeOf(types)) == .Struct);
        inline for (types) |T| self.addPlugin(T);
        return self;
    }

    pub fn insertPlugin(self: *Self, value: anytype) *Self {
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
