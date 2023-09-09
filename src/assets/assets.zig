const std = @import("std");
const aya = @import("../aya.zig");

const App = aya.App;
const Allocator = std.mem.Allocator;

pub const AssetServer = @import("asset_server.zig").AssetServer;
pub const AssetId = @import("handles.zig").AssetId;
pub const Handle = @import("handles.zig").Handle;

pub const AssetPlugin = struct {
    pub fn build(_: AssetPlugin, app: *App) void {
        _ = app.initResource(AssetServer);
    }
};

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

test "assets" {
    try std.testing.expect(true);
}

// test "tickles" {
//     std.debug.print("ImageHandle.phantom: {}\n", .{ImageHandle.phantom});
//     std.debug.print("Handle(Image): {}\n", .{Handle(Image).phantom});
//     std.debug.print("Handle(Thing): {}\n", .{Handle(Thing).phantom});

//     var asset_server = AssetServer.init(std.testing.allocator);
//     defer asset_server.deinit();

//     asset_server.registerLoader(Image, loadImage);
//     const img_handle = asset_server.load(Image, "fook", {});
//     std.debug.print("img_handle: {}\n", .{img_handle});

//     asset_server.registerLoader(Thing, loadThing);
//     const thing_handle = asset_server.load(Thing, "fook", 55);
//     std.debug.print("thing_handle: {}\n", .{thing_handle});
// }

// const Image = struct {};
// const Thing = struct {
//     const settings_type: type = u8;
// };

// const ImageHandle = Handle(Image);

// fn loadImage(path: []const u8, _: void) Image {
//     _ = path;
//     return Image{};
// }

// fn loadThing(path: []const u8, settings: u8) Thing {
//     _ = settings;
//     _ = path;
//     return Thing{};
// }
