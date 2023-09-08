const std = @import("std");
const typeId = @import("../type_id.zig").typeId;

const Allocator = std.mem.Allocator;
const Resources = @import("resources.zig").Resources;

pub const App = struct {
    const Self = @This();

    resources: Resources,

    pub fn init(allocator: Allocator) Self {
        return .{ .resources = Resources.init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.resources.deinit();
    }

    pub fn run(self: *Self) void {
        _ = self;
    }

    // Plugins
    pub fn addPlugin(self: *Self, comptime T: type) void {
        std.mem.zeroes(T).build(self);
    }

    pub fn addPlugins(self: *Self, comptime types: anytype) void {
        std.debug.assert(@typeInfo(@TypeOf(types)) == .Struct);
        inline for (types) |T| self.addPlugin(T);
    }

    pub fn insertPlugin(self: *Self, value: anytype) void {
        value.build(self);
    }

    // Assets
    pub fn initAsset(self: *Self, comptime T: type) void {
        _ = self;
        _ = T;
        // let assets = Assets::<T>::default();
        // self.world.resource::<AssetServer>().register_asset(&assets);
    }

    pub fn initAssetLoader(self: *Self, comptime T: type) void {
        _ = self;
        _ = T;
        // self.world.resource::<AssetServer>().register_loader(loader);
    }

    // Resources
    pub fn insertResource(self: *Self, resource: anytype) void {
        self.resources.insert(resource);
    }

    pub fn initResource(self: *Self, comptime T: type) *App {
        self.resources.initResource(T);
    }
};
