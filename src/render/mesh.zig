const std = @import("std");
const aya = @import("../aya.zig");

pub const Indices = union {
    u16: []u16,
    u32: []u32,
};

pub const PrimitiveTopology = enum {
    points,
    lines,
    line_strip,
    triangles,
    triangle_strip,
};

pub const VertexFormat = enum {
    float32,
    float32x2,
    float32x3,
    float32x4,
    float16x2,
    float16x4,
};

pub const MeshVertexAttributeId = u8;

pub const MeshVertexAttribute = struct {
    /// The friendly name of the vertex attribute
    name: []const u8,

    /// The _unique_ id of the vertex attribute. This will also determine sort ordering
    /// when generating vertex buffers. Built-in / standard attributes will use "close to zero"
    /// indices. When in doubt, use a random / very large usize to avoid conflicts.
    id: MeshVertexAttributeId,

    /// The format of the vertex attribute.
    format: VertexFormat,
};

pub const VertexAttributeValues = union(VertexFormat) {
    float32: []f32,
    float32x2: [][2]f32,
    float32x3: [][3]f32,
    float32x4: [][4]f32,
    float16x2: [][2]f16,
    float16x4: [][4]f16,
};

pub const MeshAttributeData = struct {
    attribute: MeshVertexAttribute,
    values: VertexAttributeValues,
};

pub const Mesh = struct {
    topology: PrimitiveTopology,
    indices: ?Indices = null,
    attributes: std.AutoHashMap(MeshVertexAttributeId, MeshAttributeData),

    pub const ATTRIBUTE_POSITION: MeshVertexAttribute = .{ .name = "Vertex_Position", .id = 0, .format = .float32x3 };
    pub const ATTRIBUTE_NORMAL: MeshVertexAttribute = .{ .name = "Vertex_Normal", .id = 1, .format = .float32x3 };
    pub const ATTRIBUTE_UV_0: MeshVertexAttribute = .{ .name = "Vertex_UV", .id = 2, .format = .float32x2 };
    pub const ATTRIBUTE_UV_1: MeshVertexAttribute = .{ .name = "Vertex_UV_1", .id = 3, .format = .float32x2 };
    pub const ATTRIBUTE_TANGENT: MeshVertexAttribute = .{ .name = "Vertex_Tangent", .id = 4, .format = .float32x4 };
    pub const ATTRIBUTE_COLOR: MeshVertexAttribute = .{ .name = "Vertex_Color", .id = 5, .format = .float32x4 };

    pub fn init(topology: PrimitiveTopology) Mesh {
        return .{
            .topology = topology,
            .attributes = std.AutoHashMap(MeshVertexAttributeId, MeshAttributeData).init(aya.allocator),
        };
    }

    pub fn insertAttribute(self: *Mesh, attribute: MeshVertexAttribute, values: anytype) void {
        const val = switch (attribute.format) {
            inline else => |tag| blk: {
                if (@TypeOf(values) == std.meta.FieldType(VertexAttributeValues, tag)) {
                    break :blk @unionInit(VertexAttributeValues, @tagName(tag), values);
                }
                @panic("values type does not match attribute.format! attribute.format is " ++ @tagName(tag) ++ " != " ++ @typeName(@TypeOf(values)));
            },
        };

        const data: MeshAttributeData = .{
            .attribute = attribute,
            .values = val,
        };

        self.attributes.put(attribute.id, data) catch unreachable;
    }

    pub fn setIndices(self: *Mesh, indices: Indices) void {
        self.indices = indices;
    }

    pub fn prepareAsset(asset: Mesh.ExtractedAsset, param: Mesh.Param) Mesh.PreparedAsset {
        _ = param;
        return asset;
    }

    pub const ExtractedAsset = Mesh;
    pub const PreparedAsset = Mesh;

    /// only Resources allowed
    pub const Param = struct {
        assets: *aya.Assets(Mesh),
    };
};

test "mesh.insertAttribute" {
    std.debug.print("--\n", .{});

    var mesh = Mesh.init(.triangles);
    const values = try std.testing.allocator.alloc([3]f32, 1);
    defer std.testing.allocator.free(values);

    const indices = Indices{ .u16 = try std.testing.allocator.alloc(u16, 1) };
    defer std.testing.allocator.free(indices.u16);

    values[0] = [_]f32{ 1.0, 0.0, 0.0 };
    mesh.insertAttribute(Mesh.ATTRIBUTE_POSITION, values);
    mesh.insertAttribute(.{ .name = "Fuck_Off", .id = 99, .format = .float32x3 }, values);
    mesh.setIndices(indices);

    var iter = mesh.attributes.iterator();
    while (iter.next()) |attr| {
        std.debug.print("key: {}, val: {}\n", .{ attr.key_ptr.*, attr.value_ptr.values });
    }
}
