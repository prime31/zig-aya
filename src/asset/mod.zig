const std = @import("std");
const aya = @import("../aya.zig");

const App = aya.App;
const Allocator = std.mem.Allocator;
const AssetServer = @import("asset_server.zig").AssetServer;
const Res = aya.Res;
const ResMut = aya.ResMut;

pub const AssetIndex = @import("asset_handle_provider.zig").AssetIndex;
pub const AssetId = @import("asset_handle_provider.zig").AssetId;

pub usingnamespace @import("assets.zig");
pub usingnamespace @import("asset_server.zig");
pub usingnamespace @import("handles.zig");

pub const AssetPlugin = struct {
    pub fn build(_: AssetPlugin, app: *App) void {
        _ = app.initResource(AssetServer);
    }
};

/// Plugin used for any Asset types that need further processing after being loaded (ex Image => GpuImage)
pub fn RenderAssetPlugin(comptime T: type) type {
    return struct {
        const Self = @This();

        pub fn build(_: Self, app: *App) void {
            _ = app
                .initResource(ExtractedAssets(T))
                .initResource(RenderAssets(T))
                .addSystems(aya.PostUpdate, ExtractAssetSystem(T))
                .addSystems(aya.PostUpdate, PrepareRenderAssetSystem(T));
        }
    };
}

/// Resource
pub fn ExtractedAssets(comptime T: type) type {
    return struct {
        pub const asset_type = T;
        const Self = @This();

        const RenderAssetData = struct { id: AssetIndex, asset: T.ExtractedAsset };

        extracted: std.ArrayList(RenderAssetData),
        removed: std.ArrayList(AssetIndex),

        pub fn init() Self {
            return .{
                .extracted = std.ArrayList(RenderAssetData).init(aya.allocator),
                .removed = std.ArrayList(AssetIndex).init(aya.allocator),
            };
        }

        pub fn deinit(self: Self) void {
            for (self.extracted.items) |*data| {
                data.asset.deinit();
            }
            self.extracted.deinit();
            self.removed.deinit();
        }

        pub fn clear(self: *Self) void {
            self.extracted.clearRetainingCapacity();
            self.removed.clearRetainingCapacity();
        }
    };
}

/// Resource. stores the converted/processed assets
pub fn RenderAssets(comptime T: type) type {
    return struct {
        pub const asset_type = T;
        const Self = @This();

        assets: std.AutoHashMap(AssetIndex, T.PreparedAsset),

        pub fn init() Self {
            return .{ .assets = std.AutoHashMap(AssetIndex, T.PreparedAsset).init(aya.allocator) };
        }

        pub fn deinit(self: *Self) void {
            if (@hasDecl(T.PreparedAsset, "deinit")) {
                var iter = self.assets.valueIterator();
                while (iter.next()) |asset| asset.deinit();
            }
            self.assets.deinit();
        }

        pub fn insert(self: *Self, id: AssetIndex, asset: T.PreparedAsset) void {
            self.assets.put(id, asset) catch unreachable;
        }

        pub fn get(self: *Self, id: AssetIndex) ?T.PreparedAsset {
            return self.assets.get(id);
        }

        pub fn remove(self: *Self, id: AssetIndex) void {
            _ = self.assets.remove(id);
        }
    };
}

/// prepares all assets of the corresponding `RenderAsset` type which where extracted this frame for the GPU. Calls
/// `prepareAsset(AssetIndex, Asset)` on the asset type.
pub fn PrepareRenderAssetSystem(comptime T: type) type {
    return struct {
        pub const name = "aya.systems.assets.RenderAssetSystem_" ++ aya.utils.typeNameLastComponent(T);

        pub fn run(world: *aya.World, extracted_assets_res: ResMut(ExtractedAssets(T)), render_assets_res: ResMut(RenderAssets(T))) void {
            const extracted_assets = extracted_assets_res.getAssertExists();
            const render_assets = render_assets_res.getAssertExists();

            // process all ExtractedAssets
            for (extracted_assets.extracted.items) |obj| {
                const render_asset = T.prepareAsset(&obj.asset, world.extractResources(T.Param));
                render_assets.insert(obj.id, render_asset);
            }

            for (extracted_assets.removed.items) |rem| {
                render_assets.remove(rem);
            }

            extracted_assets.clear();
        }
    };
}

/// extracts all created or modified assets
pub fn ExtractAssetSystem(comptime T: type) type {
    return struct {
        pub const name = "aya.systems.assets.ExtractAssetSystem_" ++ aya.utils.typeNameLastComponent(T);

        pub fn run(
            extracted_assets_res: ResMut(ExtractedAssets(T)),
            event_reader: aya.EventReader(aya.AssetEvent(T)),
            assets_res: Res(aya.Assets(T)),
        ) void {
            const extracted_assets = extracted_assets_res.getAssertExists();
            const asset: *const aya.Assets(T) = assets_res.getAssertExists();

            // TODO: use a HashSet to ensure we dont queue up multiple evnets if an asset is added and removed in one frame for example
            for (event_reader.read()) |evt| {
                switch (evt) {
                    .added, .modified => |mod| {
                        if (asset.get(mod.index)) |ass| {
                            extracted_assets.extracted.append(.{ .id = mod.index, .asset = ass }) catch unreachable;
                        }
                    },
                    .removed => |rem| extracted_assets.removed.append(rem.index) catch unreachable,
                }
            }
        }
    };
}
