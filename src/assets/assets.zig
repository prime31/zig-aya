const std = @import("std");

pub fn typeId(comptime T: type) usize {
    return @intFromPtr(&TypeIdStruct(T).unique_global);
}

pub fn TypeIdStruct(comptime _: type) type {
    return struct {
        pub var unique_global: u8 = 0;
    };
}

const Allocator = std.mem.Allocator;

pub fn Handle(comptime T: type) type {
    return struct {
        const Self = @This();
        const phantom = T;

        asset_id: AssetId = .{},
    };
}

// AssetId is the same as AssetIndex in bevy
// pub struct AssetIndex {
//     pub(crate) generation: u32,
//     pub(crate) index: u32,
// }
pub const AssetId = struct {};

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

pub fn AssetLoader(comptime T: type) type {
    return struct {
        const settings_type: type = if (@hasDecl(T, "settings_type")) T.settings_type else void;

        load: *const fn ([]const u8, settings: settings_type) T,
    };
}

/// Resource. Manages the storage assets of type T.
pub fn Assets(comptime T: type) type {
    return struct {
        // handles: AssetHandleProvider,

        pub fn insert(id: AssetId, asset: T) void {
            _ = asset;
            _ = id;
        }

        pub fn add(asset: T) Handle(T) {
            _ = asset;
            return Handle(T){};
        }

        pub fn get(id: AssetId) T {
            _ = id;
            return T{};
        }

        pub fn remove(id: AssetId) T {
            _ = id;
            return T{};
        }
    };
}

test "tickles" {
    std.debug.print("ImageHandle.phantom: {}\n", .{ImageHandle.phantom});
    std.debug.print("Handle(Image): {}\n", .{Handle(Image).phantom});
    std.debug.print("Handle(Thing): {}\n", .{Handle(Thing).phantom});

    var asset_server = AssetServer.init(std.testing.allocator);
    defer asset_server.deinit();

    asset_server.registerLoader(Image, loadImage);
    const img_handle = asset_server.load(Image, "fook", {});
    std.debug.print("img_handle: {}\n", .{img_handle});

    asset_server.registerLoader(Thing, loadThing);
    const thing_handle = asset_server.load(Thing, "fook", 55);
    std.debug.print("thing_handle: {}\n", .{thing_handle});
}

const Image = struct {};
const Thing = struct {
    const settings_type: type = u8;
};

const ImageHandle = Handle(Image);

fn loadImage(path: []const u8, _: void) Image {
    _ = path;
    return Image{};
}

fn loadThing(path: []const u8, settings: u8) Thing {
    _ = settings;
    _ = path;
    return Thing{};
}
