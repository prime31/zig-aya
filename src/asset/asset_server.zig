const std = @import("std");
const aya = @import("../aya.zig");

const typeId = aya.utils.typeId;

const Allocator = std.mem.Allocator;
const Assets = aya.Assets;
const Handle = @import("mod.zig").Handle;
const AssetHandleProvider = @import("asset_handle_provider.zig").AssetHandleProvider;
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
    handle_providers: std.AutoHashMap(usize, *AssetHandleProvider),

    pub fn init(allocator: Allocator) AssetServer {
        return .{
            .loaders = std.AutoHashMap(usize, ErasedPtr).init(allocator),
            .handle_providers = std.AutoHashMap(usize, *AssetHandleProvider).init(allocator),
        };
    }

    pub fn deinit(self: *AssetServer) void {
        var iter = self.loaders.iterator();
        while (iter.next()) |entry| entry.value_ptr.deinit(entry.value_ptr.*, self.loaders.allocator);
        self.loaders.deinit();

        self.handle_providers.deinit();
    }

    // TODO: make this do the asset loading async and dont require Assets(T) param. pull that from World somehow...maybe push loads to a system
    pub fn load(self: *AssetServer, comptime T: type, assets: *Assets(T), path: []const u8, settings: AssetLoader(T).settings_type) Handle(T) {
        const ptr = self.loaders.get(typeId(T)) orelse @panic("No registered AssetLoader for type " ++ @typeName(T));

        const handle = Handle(T).init(assets.handle_provider.create());
        const loader = ptr.asPtr(AssetLoader(T));
        const asset = loader.load(path, settings);
        assets.insert(handle.asset_index, asset);
        return handle;
    }

    pub fn registerLoader(self: *AssetServer, comptime T: type, loadFn: *const fn ([]const u8, AssetLoader(T).settings_type) T) void {
        const loader = self.loaders.allocator.create(AssetLoader(T)) catch unreachable;
        loader.load = loadFn;
        self.loaders.put(typeId(T), ErasedPtr.initWithPtr(AssetLoader(T), @intFromPtr(loader))) catch unreachable;
    }
};
