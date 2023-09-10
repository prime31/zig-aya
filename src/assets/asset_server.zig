const std = @import("std");
const aya = @import("../aya.zig");
const assets = @import("mod.zig");

const typeId = aya.utils.typeId;

const Allocator = std.mem.Allocator;
const Handle = assets.Handle;
const ErasedPtr = aya.utils.ErasedPtr;

pub fn AssetLoader(comptime T: type) type {
    return struct {
        const settings_type: type = if (@hasDecl(T, "settings_type")) T.settings_type else void;

        load: *const fn ([]const u8, settings: settings_type) T,
    };
}

/// Resource. Manages the loading of assets by type for each registered asset type + loader.
pub const AssetServer = struct {
    loaders: std.AutoHashMap(usize, ErasedPtr),

    pub fn init(allocator: Allocator) AssetServer {
        return .{ .loaders = std.AutoHashMap(usize, ErasedPtr).init(allocator) };
    }

    pub fn deinit(self: *AssetServer) void {
        var iter = self.loaders.iterator();
        while (iter.next()) |entry| entry.value_ptr.deinit(entry.value_ptr.*, self.loaders.allocator);
        self.loaders.deinit();
    }

    pub fn load(self: AssetServer, comptime T: type, path: []const u8, settings: AssetLoader(T).settings_type) Handle(T) {
        if (self.loaders.get(typeId(T))) |res| {
            const loader = res.asPtr(AssetLoader(T));
            const asset = loader.load(path, settings);
            _ = asset;
            // add asset to Assets(T)
        }
        return Handle(T){};
    }

    pub fn registerLoader(self: *AssetServer, comptime T: type, loadFn: *const fn ([]const u8, AssetLoader(T).settings_type) T) void {
        const loader = self.loaders.allocator.create(AssetLoader(T)) catch unreachable;
        loader.load = loadFn;
        self.loaders.put(typeId(T), ErasedPtr.initWithPtr(AssetLoader(T), @intFromPtr(loader))) catch unreachable;
    }
};
