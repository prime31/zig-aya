const std = @import("std");
const aya = @import("aya");
const zmesh = @import("zmesh");

const App = aya.App;
const ResMut = aya.ResMut;
const AssetServer = aya.AssetServer;
const Assets = aya.Assets;
const Mesh = aya.Mesh;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Startup, .{ CreateTriMeshSystem, CreateQuadMeshSystem, GltfSystem })
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

const GltfSystem = struct {
    pub fn run(assets_res: ResMut(Assets(Mesh))) void {
        const assets = assets_res.getAssertExists();

        zmesh.init(aya.allocator);
        defer zmesh.deinit();

        const data = zmesh.io.parseAndLoadFile("examples/assets/monkey.glb") catch unreachable;
        defer zmesh.io.freeData(data);

        var mesh_indices = std.ArrayList(u32).init(aya.allocator);
        defer mesh_indices.deinit();
        var mesh_positions = std.ArrayList([3]f32).init(aya.allocator);
        defer mesh_positions.deinit();
        var mesh_colors = std.ArrayList([4]f32).init(aya.allocator);
        defer mesh_colors.deinit();

        zmesh.io.appendMeshPrimitive(
            data, // *zmesh.io.cgltf.Data
            0, // mesh index
            0, // gltf primitive index (submesh index)
            &mesh_indices,
            &mesh_positions,
            null, // normals (optional)
            null, // texcoords (optional)
            null, // tangents (optional)
            &mesh_colors, // colors (optional)
        ) catch unreachable;

        // mesh_colors.ensureTotalCapacityPrecise(mesh_positions.items.len) catch unreachable;
        // mesh_colors.expandToCapacity();
        // for (mesh_colors.items) |*col| col.* = [_]f32{ 1, 1, 1, 1 };
        // std.debug.print("pos: {}\n", .{mesh_positions.items.len});

        var mesh = Mesh.init(.triangles);
        mesh.insertAttribute(Mesh.ATTRIBUTE_POSITION, mesh_positions.toOwnedSlice() catch unreachable);
        mesh.insertAttribute(Mesh.ATTRIBUTE_COLOR, mesh_colors.toOwnedSlice() catch unreachable);
        mesh.setIndices(.{ .u32 = mesh_indices.toOwnedSlice() catch unreachable });

        const handle = assets.add(mesh);
        _ = handle;
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
