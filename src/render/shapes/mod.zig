const aya = @import("../../aya.zig");
const Mesh = @import("../mesh.zig").Mesh;

pub const Cube = struct {
    size: f32,

    pub fn init(size: f32) Cube {
        return .{ .size = size };
    }

    pub fn toMesh(self: Cube) Mesh {
        return Box.init(self.size, self.size, self.size).toMesh();
    }
};

pub const Box = struct {
    min_x: f32,
    max_x: f32,
    min_y: f32,
    max_y: f32,
    min_z: f32,
    max_z: f32,

    pub fn init(x_length: f32, y_length: f32, z_length: f32) Box {
        return .{
            .max_x = x_length / 2.0,
            .min_x = -x_length / 2.0,
            .max_y = y_length / 2.0,
            .min_y = -y_length / 2.0,
            .max_z = z_length / 2.0,
            .min_z = -z_length / 2.0,
        };
    }

    pub fn toMesh(self: Box) Mesh {
        var mesh = Mesh.init(.triangles);
        const positions = aya.mem.alloc([3]f32, 24);
        positions[0..24].* = .{
            // Front
            .{ self.min_x, self.min_y, self.max_z },
            .{ self.max_x, self.min_y, self.max_z },
            .{ self.max_x, self.max_y, self.max_z },
            .{ self.min_x, self.max_y, self.max_z },
            // Back
            .{ self.min_x, self.max_y, self.min_z },
            .{ self.max_x, self.max_y, self.min_z },
            .{ self.max_x, self.min_y, self.min_z },
            .{ self.min_x, self.min_y, self.min_z },
            // Right
            .{ self.max_x, self.min_y, self.min_z },
            .{ self.max_x, self.max_y, self.min_z },
            .{ self.max_x, self.max_y, self.max_z },
            .{ self.max_x, self.min_y, self.max_z },
            // Left
            .{ self.min_x, self.min_y, self.max_z },
            .{ self.min_x, self.max_y, self.max_z },
            .{ self.min_x, self.max_y, self.min_z },
            .{ self.min_x, self.min_y, self.min_z },
            // Top
            .{ self.max_x, self.max_y, self.min_z },
            .{ self.min_x, self.max_y, self.min_z },
            .{ self.min_x, self.max_y, self.max_z },
            .{ self.max_x, self.max_y, self.max_z },
            // Bottom
            .{ self.max_x, self.min_y, self.max_z },
            .{ self.min_x, self.min_y, self.max_z },
            .{ self.min_x, self.min_y, self.min_z },
            .{ self.max_x, self.min_y, self.min_z },
        };

        const uvs = aya.mem.alloc([2]f32, 24);
        uvs[0..24].* = .{
            .{ 0, 0 },
            .{ 1.0, 0 },
            .{ 1.0, 1.0 },
            .{ 0, 1.0 },
            .{ 1.0, 0 },
            .{ 0, 0 },
            .{ 0, 1.0 },
            .{ 1.0, 1.0 },
            .{ 0, 0 },
            .{ 1.0, 0 },
            .{ 1.0, 1.0 },
            .{ 0, 1.0 },
            .{ 1.0, 0 },
            .{ 0, 0 },
            .{ 0, 1.0 },
            .{ 1.0, 1.0 },
            .{ 1.0, 0 },
            .{ 0, 0 },
            .{ 0, 1.0 },
            .{ 1.0, 1.0 },
            .{ 0, 0 },
            .{ 1.0, 0 },
            .{ 1.0, 1.0 },
            .{ 0, 1.0 },
        };

        const normals = aya.mem.alloc([3]f32, 24);
        normals[0..24].* = .{
            .{ 0, 0, 1.0 },
            .{ 0, 0, 1.0 },
            .{ 0, 0, 1.0 },
            .{ 0, 0, 1.0 },
            .{ 0, 0, -1.0 },
            .{ 0, 0, -1.0 },
            .{ 0, 0, -1.0 },
            .{ 0, 0, -1.0 },
            .{ 1.0, 0, 0 },
            .{ 1.0, 0, 0 },
            .{ 1.0, 0, 0 },
            .{ 1.0, 0, 0 },
            .{ -1.0, 0, 0 },
            .{ -1.0, 0, 0 },
            .{ -1.0, 0, 0 },
            .{ -1.0, 0, 0 },
            .{ 0, 1.0, 0 },
            .{ 0, 1.0, 0 },
            .{ 0, 1.0, 0 },
            .{ 0, 1.0, 0 },
            .{ 0, -1.0, 0 },
            .{ 0, -1.0, 0 },
            .{ 0, -1.0, 0 },
            .{ 0, -1.0, 0 },
        };

        const colors = aya.mem.alloc([4]f32, 24);
        for (0..24) |i| colors[i] = .{ 1, 1, 1, 1 };

        var indices = aya.mem.alloc(u16, 36);
        indices[0..36].* = .{
            0, 1, 2, 2, 3, 0, // front
            4, 5, 6, 6, 7, 4, // back
            8, 9, 10, 10, 11, 8, // right
            12, 13, 14, 14, 15, 12, // left
            16, 17, 18, 18, 19, 16, // top
            20, 21, 22, 22, 23, 20, // bottom
        };

        mesh.insertAttribute(Mesh.ATTRIBUTE_POSITION, positions);
        mesh.insertAttribute(Mesh.ATTRIBUTE_UV_0, uvs);
        mesh.insertAttribute(Mesh.ATTRIBUTE_NORMAL, normals);
        mesh.insertAttribute(Mesh.ATTRIBUTE_COLOR, colors);

        mesh.setIndices(.{ .u16 = indices });

        return mesh;
    }
};
