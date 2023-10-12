const std = @import("std");
const aya = @import("../aya.zig");

const App = aya.App;
const Allocator = std.mem.Allocator;
const AssetServer = @import("asset_server.zig").AssetServer;

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
        pub fn build(_: AssetPlugin, app: *App) void {
            _ = app.initResource(ExtractedAssets(T))
                .initResource(RenderAssets(T));
        }
    };
}

pub fn ExtractedAssets(comptime T: type) type {
    return struct {
        pub const asset_type = T;
        const Self = @This();

        const Fook = struct { id: AssetId, asset: T.extracted_asset };

        extracted: std.ArrayList(Fook),
        removed: std.ArrayList(AssetId),

        pub fn init() Self {
            return .{
                .extracted = std.ArrayList(Fook).init(aya.allocator),
                .removed = std.ArrayList(AssetId).init(aya.allocator),
            };
        }

        pub fn deinit(self: Self) void {
            self.extracted.deinit();
            self.removed.deinit();
        }
    };
}

pub fn RenderAssets(comptime T: type) type {
    return struct {
        pub const asset_type = T;
        const Self = @This();

        assets: std.AutoHashMap(AssetId, T.prepared_asset),

        pub fn init() Self {
            return .{ .assets = std.AutoHashMap(AssetId, T.extracted_asset).init(aya.allocator) };
        }

        pub fn deinit(self: Self) void {
            self.assets.deinit();
        }

        pub fn insert(self: *Self, id: AssetId, asset: T.prepared_asset) void {
            self.assets.put(id, asset) catch unreachable;
        }
    };
}

pub fn RenderAssetSystem(comptime T: type) type {
    return struct {
        pub const name = "aya.systems.assets.RenderAssetSystem_" ++ aya.utils.typeNameLastComponent(T);

        pub fn run(extracted_assets_res: aya.ResMut(ExtractedAssets(T)), render_assets_res: aya.ResMut(RenderAssets(T))) void {
            const extracted_assets = extracted_assets_res.getAssertExists();
            const render_assets = render_assets_res.getAssertExists();

            // process all ExtractedAssets
            for (extracted_assets.extracted) |obj| {
                const render_asset = T.prepareAsset(obj.id, obj.asset);
                render_assets.insert(obj.id, render_asset);
            }
        }
    };
}

// impl<A: RenderAsset, AFTER: RenderAssetDependency + 'static> Plugin
//     for RenderAssetPlugin<A, AFTER>
// {
//     fn build(&self, app: &mut App) {
//         if let Ok(render_app) = app.get_sub_app_mut(RenderApp) {
//             render_app
//                 .init_resource::<ExtractedAssets<A>>()
//                 .init_resource::<RenderAssets<A>>()
//                 .init_resource::<PrepareNextFrameAssets<A>>()
//                 .add_systems(ExtractSchedule, extract_render_asset::<A>);
//             AFTER::register_system(
//                 render_app,
//                 prepare_assets::<A>.in_set(RenderSet::PrepareAssets),
//             );
//         }
//     }
// }
