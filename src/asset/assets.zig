const std = @import("std");
const aya = @import("../aya.zig");
const assets = @import("mod.zig");

const App = aya.App;
const Allocator = std.mem.Allocator;
const Handle = assets.Handle;
const AssetId = assets.AssetId;
const AssetIndex = assets.AssetIndex;
const AssetHandleProvider = @import("asset_handle_provider.zig").AssetHandleProvider;

/// Resource. Manages the storage assets of type T.
pub fn Assets(comptime T: type) type {
    return struct {
        const Self = @This();

        instances: std.AutoHashMap(u32, T),
        handle_provider: AssetHandleProvider,
        queued_events: std.ArrayList(AssetEvent(T)),

        pub fn init(allocator: Allocator) Self {
            return .{
                .instances = std.AutoHashMap(u32, T).init(allocator),
                .handle_provider = AssetHandleProvider.init(allocator),
                .queued_events = std.ArrayList(AssetEvent(T)).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            if (@hasDecl(T, "deinit")) {
                var iter = self.instances.valueIterator();
                while (iter.next()) |asset| asset.deinit();
            }
            self.instances.deinit();
            self.handle_provider.deinit();
            self.queued_events.deinit();
        }

        pub fn add(self: *Self, asset: T) Handle(T) {
            const id = self.handle_provider.create();
            self.instances.put(id.index, asset) catch unreachable;

            self.queued_events.append(AssetEvent(T){ .added = AssetId(T){ .index = id } }) catch unreachable;
            return Handle(T).init(id);
        }

        pub fn insert(self: *Self, id: AssetIndex, asset: T) void {
            const res = self.instances.getOrPut(id.index) catch unreachable;
            res.value_ptr.* = asset;

            if (res.found_existing) {
                if (@hasDecl(T, "deinit")) res.value_ptr.deinit();
                self.queued_events.append(AssetEvent(T){ .modified = AssetId(T){ .index = id } }) catch unreachable;
            } else {
                self.queued_events.append(AssetEvent(T){ .added = AssetId(T){ .index = id } }) catch unreachable;
            }
        }

        /// gets an asset using a Handle(T) or AssetIndex
        pub fn get(self: Self, handle: anytype) ?T {
            const asset_index = if (@TypeOf(handle) == Handle(T)) handle.asset_index else handle;
            std.debug.assert(self.handle_provider.alive(asset_index));
            return self.instances.get(asset_index.index);
        }

        pub fn remove(self: Self, handle: Handle(T)) void {
            if (self.instances.fetchRemove(handle.asset_index.index)) |kv| {
                if (@hasDecl(T, "deinit")) kv.value.deinit();
                self.handle_provider.remove(handle.asset_index);
                self.queued_events.append(AssetEvent(T){ .removed = AssetId(T){ .index = handle.asset_index } }) catch unreachable;
            }
        }
    };
}

pub fn AssetEvent(comptime T: type) type {
    return union(enum) {
        const Self = @This();

        added: AssetId(T),
        modified: AssetId(T),
        removed: AssetId(T),

        pub fn isAdded(self: Self) bool {
            return std.meta.activeTag(self) == .added;
        }

        pub fn isModified(self: Self) bool {
            return std.meta.activeTag(self) == .modified;
        }

        pub fn isRemoved(self: Self) bool {
            return std.meta.activeTag(self) == .removed;
        }
    };
}

/// A system that applies accumulated asset change events to the Events resource.
pub fn AssetChangeEventSystem(comptime T: type) type {
    return struct {
        pub const name = "aya.systems.assets.AssetChangeEventSystem_" ++ aya.utils.typeNameLastComponent(T);

        pub fn run(assets_res: aya.ResMut(Assets(T)), event_writer: aya.EventWriter(AssetEvent(T))) void {
            const asset = assets_res.getAssertExists();
            event_writer.sendBatch(asset.queued_events.items);
            asset.queued_events.clearRetainingCapacity();
        }
    };
}

test "assets" {
    const Image = struct {};

    const Thing = struct {
        pub const settings_type: type = u8;
    };

    const ImageHandle = Handle(Image);
    _ = ImageHandle;

    const Funcs = struct {
        fn loadImage(path: []const u8, _: void) Image {
            _ = path;
            return Image{};
        }

        fn loadThing(path: []const u8, settings: u8) Thing {
            _ = settings;
            _ = path;
            return Thing{};
        }
    };

    const AssetServer = assets.AssetServer;

    var asset_server = AssetServer.init(aya.allocator);
    defer asset_server.deinit();

    var images = Assets(Image).init(aya.allocator);
    defer images.deinit();

    var things = Assets(Thing).init(aya.allocator);
    defer things.deinit();

    asset_server.registerLoader(Image, Funcs.loadImage);
    const img_handle = asset_server.load(Image, &images, "fook", {});
    const img = images.get(img_handle);
    try std.testing.expect(img != null);

    asset_server.registerLoader(Thing, Funcs.loadThing);
    const thing_handle = asset_server.load(Thing, &things, "fook", 55);
    _ = thing_handle;
    // std.debug.print("----------- thing_handle: {}\n", .{thing_handle});

    var slice = aya.mem.alloc(u8, 3);
    setSlice(u8, slice, .{ 55, 1, 2 });
    std.debug.print("{} -> {} -> {}\n", .{ slice[0], slice[1], slice[2] });

    var slice2 = aya.mem.alloc([2]u8, 3);
    setSlice([2]u8, slice2, .{ [_]u8{ 4, 5 }, [_]u8{ 77, 25 } });
    try std.testing.expectEqual([_]u8{ 4, 5 }, slice2[0]);
    std.debug.print("{any} -> {any}\n", .{ slice2[0], slice2[1] });

    var slice3 = aya.mem.alloc([2]u8, 3);
    slice3[0..2].* = .{ .{ 23, 24 }, .{ 25, 26 } };
    std.debug.print("{any} -> {any}\n", .{ slice3[0], slice3[1] });
}

fn setSlice(comptime T: type, slice: []T, init: anytype) void {
    switch (@typeInfo(@TypeOf(init))) {
        .Struct => |init_info| {
            if (init_info.is_tuple) {
                inline for (init, 0..) |item, i| {
                    slice[i] = item;
                }
            }
        },
        else => {},
    }
}
