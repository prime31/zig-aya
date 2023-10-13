const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const ResMut = aya.ResMut;
const AssetServer = aya.AssetServer;
const Assets = aya.Assets;
const Mesh = aya.Mesh;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Startup, CreateMeshSystem)
        .addSystems(aya.Startup, LoadAssetSystem)
        .addSystems(aya.Update, AssetEventSystem)
        .run();
}

const CreateMeshSystem = struct {
    pub fn run(assets_res: ResMut(Assets(Mesh))) void {
        const assets = assets_res.getAssertExists();

        var mesh = Mesh.init(.points);
        var indices = aya.tmp_allocator.alloc(u16, 3) catch unreachable;
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        mesh.setIndices(.{ .u16 = indices });

        const handle = assets.add(mesh);
        std.debug.print("handle: {}\n", .{handle});
    }
};

const LoadAssetSystem = struct {
    pub fn run(asset_server_res: ResMut(AssetServer)) void {
        const asset_server: *AssetServer = asset_server_res.getAssertExists();
        _ = asset_server;
    }
};

const AssetEventSystem = struct {
    pub fn run(event_reader: aya.EventReader(aya.AssetEvent(Mesh))) void {
        for (event_reader.read()) |evt| {
            std.debug.print("AssetEvent: {}, added: {}\n", .{ evt, evt.isAdded() });
        }
    }
};
