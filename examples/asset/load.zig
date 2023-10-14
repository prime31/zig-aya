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
        .addSystems(aya.Startup, .{ CreateTriMeshSystem, CreateQuadMeshSystem })
        .addSystems(aya.Startup, LoadAssetSystem)
        .addSystems(aya.Update, AssetEventSystem)
        .run();
}

const CreateTriMeshSystem = struct {
    pub fn run(assets_res: ResMut(Assets(Mesh))) void {
        const assets = assets_res.getAssertExists();

        var mesh = Mesh.init(.triangles);
        const values = aya.mem.alloc([3]f32, 3);
        values[0] = [_]f32{ 0.0, 0.55, 0.0 };
        values[1] = [_]f32{ 0.25, 0.05, 0.0 };
        values[2] = [_]f32{ -0.25, 0.05, 0.0 };
        mesh.insertAttribute(Mesh.ATTRIBUTE_POSITION, values);

        const colors = aya.mem.alloc([4]f32, 3);
        colors[0..3].* = .{
            .{ 1, 0, 0, 1 },
            .{ 0, 1, 0, 1 },
            .{ 0, 0, 1, 1 },
        };
        mesh.insertAttribute(Mesh.ATTRIBUTE_COLOR, colors);

        var indices = aya.mem.alloc(u16, 3);
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        mesh.setIndices(.{ .u16 = indices });

        const handle = assets.add(mesh);
        _ = handle;
    }
};

const CreateQuadMeshSystem = struct {
    pub fn run(assets_res: ResMut(Assets(Mesh))) void {
        const assets = assets_res.getAssertExists();

        var mesh = Mesh.init(.triangles);
        const values = aya.mem.alloc([3]f32, 4);
        values[0] = [_]f32{ -0.25, -0.05, 0.0 };
        values[1] = [_]f32{ 0.25, -0.05, 0.0 };
        values[2] = [_]f32{ 0.25, -0.55, 0.0 };
        values[3] = [_]f32{ -0.25, -0.55, 0.0 };
        mesh.insertAttribute(Mesh.ATTRIBUTE_POSITION, values);

        const colors = aya.mem.alloc([4]f32, 4);
        colors[0] = [_]f32{ 1, 0, 0, 1 };
        colors[1] = [_]f32{ 0, 1, 0, 1 };
        colors[2] = [_]f32{ 0, 0, 1, 1 };
        colors[2] = [_]f32{ 1, 0, 1, 1 };
        mesh.insertAttribute(Mesh.ATTRIBUTE_COLOR, colors);

        var indices = aya.mem.alloc(u16, 6);
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        indices[3] = 0;
        indices[4] = 2;
        indices[5] = 3;
        mesh.setIndices(.{ .u16 = indices });

        const handle = assets.add(mesh);
        _ = handle;
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
            _ = evt;
            // std.debug.print("AssetEvent: {}, added: {}\n", .{ evt, evt.isAdded() });
        }
    }
};
