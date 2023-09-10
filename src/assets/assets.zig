const std = @import("std");
const aya = @import("../aya.zig");
const assets = @import("mod.zig");

const App = aya.App;
const Allocator = std.mem.Allocator;
const Handle = assets.Handle;
const AssetId = assets.AssetId;
const AssetHandleProvider = @import("asset_handle_provider.zig").AssetHandleProvider;

/// Resource. Manages the storage assets of type T.
pub fn Assets(comptime T: type) type {
    return struct {
        const Self = @This();
        handle_provider: AssetHandleProvider,
        instances: std.AutoHashMap(AssetId, T),

        pub fn init(allocator: Allocator) Self {
            return .{
                .instances = std.AutoHashMap(AssetId, T).init(allocator),
                .handle_provider = AssetHandleProvider.init(allocator),
            };
        }

        pub fn deinit(self: Self) void {
            self.instances.deinit();
            self.handle_provider.deinit();
        }

        pub fn insert(self: Self, id: AssetId, asset: T) void {
            self.instances.put(id, asset) catch unreachable;
        }

        pub fn get(self: Self, id: AssetId) ?T {
            std.debug.assert(self.handle_provider.alive(id));
            return self.instances.get(id);
        }

        pub fn remove(self: Self, id: AssetId) void {
            _ = self.instances.remove(id);
            self.handle_provider.remove(id);
        }
    };
}

test "assets" {
    const AssetServer = assets.AssetServer;

    var asset_server = AssetServer.init(std.testing.allocator);
    defer asset_server.deinit();

    asset_server.registerLoader(Image, loadImage);
    const img_handle = asset_server.load(Image, "fook", {});
    std.debug.print("----------- img_handle: {}\n", .{img_handle});

    asset_server.registerLoader(Thing, loadThing);
    const thing_handle = asset_server.load(Thing, "fook", 55);
    std.debug.print("----------- thing_handle: {}\n", .{thing_handle});
}

const Image = struct {};

const Thing = struct {
    pub const settings_type: type = u8;
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
