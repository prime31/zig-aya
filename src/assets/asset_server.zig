const std = @import("std");
const typeId = @import("../type_id.zig").typeId;

const Allocator = std.mem.Allocator;
const Handle = @import("assets.zig").Handle;

pub fn AssetLoader(comptime T: type) type {
    return struct {
        const settings_type: type = if (@hasDecl(T, "settings_type")) T.settings_type else void;

        load: *const fn ([]const u8, settings: settings_type) T,
    };
}

/// Resource. Manages the loading of assets by type for each registered asset type + loader.
pub const AssetServer = struct {
    loaders: std.AutoHashMap(usize, ErasedPtr),

    /// TODO: copied from Resources
    const ErasedPtr = struct {
        ptr: usize,
        deinit: *const fn (ErasedPtr, Allocator) void,

        pub fn init(comptime T: type, allocator: Allocator) ErasedPtr {
            const res = allocator.create(T) catch unreachable;
            res.* = if (@hasDecl(T, "init")) T.init(allocator) else std.mem.zeroes(T);
            return initWithPtr(T, @intFromPtr(res));
        }

        pub fn initWithPtr(comptime T: type, ptr: usize) ErasedPtr {
            return .{
                .ptr = ptr,
                .deinit = struct {
                    fn deinit(self: ErasedPtr, allocator: Allocator) void {
                        const res = self.asPtr(T);
                        if (@hasDecl(T, "deinit")) res.deinit();
                        allocator.destroy(res);
                    }
                }.deinit,
            };
        }

        pub fn asPtr(self: ErasedPtr, comptime T: type) *T {
            return @as(*T, @ptrFromInt(self.ptr));
        }
    };

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
