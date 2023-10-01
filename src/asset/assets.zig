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
        instances: std.ArrayList(T),
        handle_provider: AssetHandleProvider,

        pub fn init(allocator: Allocator) Self {
            return .{
                .instances = std.ArrayList(T).init(allocator),
                .handle_provider = AssetHandleProvider.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.instances.deinit();
            self.handle_provider.deinit();
        }

        pub fn insert(self: *Self, id: AssetId, asset: T) void {
            self.instances.ensureTotalCapacity(id.index) catch unreachable;
            self.instances.expandToCapacity();
            self.instances.items[id.index] = asset;
        }

        pub fn get(self: Self, handle: Handle(T)) ?T {
            std.debug.assert(self.handle_provider.alive(handle.asset_id));
            return self.instances.items[handle.asset_id.index];
        }

        pub fn remove(self: Self, handle: Handle(T)) void {
            _ = self.instances.remove(handle.asset_id.index);
            self.handle_provider.remove(handle.asset_id);
        }
    };
}

test "assets" {
    const AssetServer = assets.AssetServer;

    var asset_server = AssetServer.init(std.testing.allocator);
    defer asset_server.deinit();

    var images = Assets(Image).init(std.testing.allocator);
    defer images.deinit();

    var things = Assets(Thing).init(std.testing.allocator);
    defer things.deinit();

    asset_server.registerLoader(Image, loadImage);
    const img_handle = asset_server.load(Image, &images, "fook", {});
    const img = images.get(img_handle);
    try std.testing.expect(img != null);

    asset_server.registerLoader(Thing, loadThing);
    const thing_handle = asset_server.load(Thing, &things, "fook", 55);
    _ = thing_handle;
    // std.debug.print("----------- thing_handle: {}\n", .{thing_handle});
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
