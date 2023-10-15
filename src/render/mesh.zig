const std = @import("std");
const aya = @import("../aya.zig");
const sg = @import("sokol").gfx;

pub const IndexFormat = enum { u16, u32 };

pub const Indices = union(IndexFormat) {
    u16: []u16,
    u32: []u32,

    pub fn deinit(self: Indices) void {
        return switch (self) {
            inline else => |val| aya.mem.free(val),
        };
    }

    pub fn getBytes(self: Indices) []u8 {
        return switch (self) {
            inline else => |val| std.mem.sliceAsBytes(val),
        };
    }

    pub fn getLength(self: Indices) usize {
        return switch (self) {
            inline else => |val| val.len,
        };
    }
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

    pub fn getSize(self: VertexFormat) usize {
        return switch (self) {
            .float32 => 4,
            .float32x2 => 4 * 2,
            .float32x3 => 4 * 3,
            .float32x4 => 4 * 4,
            .float16x2 => 2 * 2,
            .float16x4 => 2 * 4,
        };
    }

    pub fn toSokol(self: VertexFormat) sg.VertexFormat {
        return switch (self) {
            .float32 => .FLOAT,
            .float32x2 => .FLOAT2,
            .float32x3 => .FLOAT3,
            .float32x4 => .FLOAT4,
            .float16x2 => .HALF2,
            .float16x4 => .HALF4,
        };
    }
};

pub const MeshVertexAttributeId = u8;

pub const MeshVertexAttribute = struct {
    name: []const u8,
    /// The _unique_ id of the vertex attribute. This will also determine sort ordering
    /// when generating vertex buffers. Built-in / standard attributes will use "close to zero"
    /// indices. When in doubt, use a random / very large u8 to avoid conflicts.
    id: MeshVertexAttributeId,
    format: VertexFormat,
};

pub const VertexAttributeValues = union(VertexFormat) {
    float32: []f32,
    float32x2: [][2]f32,
    float32x3: [][3]f32,
    float32x4: [][4]f32,
    float16x2: [][2]f16,
    float16x4: [][4]f16,

    pub fn deinit(self: VertexAttributeValues) void {
        return switch (self) {
            inline else => |val| aya.mem.free(val),
        };
    }

    pub fn getBytes(self: VertexAttributeValues) []u8 {
        return switch (self) {
            inline else => |val| std.mem.sliceAsBytes(val),
        };
    }

    pub fn getLength(self: VertexAttributeValues) usize {
        return switch (self) {
            inline else => |val| val.len,
        };
    }
};

pub const MeshAttributeData = struct {
    attribute: MeshVertexAttribute,
    values: VertexAttributeValues,

    pub fn deinit(self: MeshAttributeData) void {
        self.values.deinit();
    }
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

    pub fn deinit(self: *Mesh) void {
        var iter = self.attributes.valueIterator();
        while (iter.next()) |data| data.deinit();

        if (self.indices) |ind| ind.deinit();
        self.attributes.deinit();
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

    pub fn getMeshVertexBufferLayout(self: *const Mesh) MeshVertexBufferLayout {
        var attributes = aya.mem.alloc(VertexAttribute, self.attributes.count());
        var attribute_ids = aya.mem.alloc(MeshVertexAttributeId, self.attributes.count());
        var accumulated_offset: usize = 0;
        var i: usize = 0;

        var iter = self.attributes.valueIterator();
        while (iter.next()) |data| {
            attribute_ids[i] = data.attribute.id;
            attributes[i] = .{
                .offset = accumulated_offset,
                .format = data.attribute.format,
                .shader_location = @intCast(i),
            };
            accumulated_offset += data.attribute.format.getSize();
            i += 1;
        }

        return .{
            .layout = .{
                .array_stride = @intCast(accumulated_offset),
                .step_mode = .per_vertex,
                .attributes = attributes,
            },
            .attribute_ids = attribute_ids,
        };
    }

    /// Counts all vertices of the mesh. If the attributes have different vertex counts, the smallest is returned.
    pub fn countVertices(self: Mesh) usize {
        var vertex_count: ?usize = null;
        var iter = self.attributes.iterator();
        while (iter.next()) |entry| {
            const attribute_len = entry.value_ptr.values.getLength();
            if (vertex_count) |prev_vertex_count| {
                if (prev_vertex_count != attribute_len) {
                    std.log.warn("[{s}] ({}) has a different vertex count ({}) than other attributes ({}) in this mesh. all attributes will be truncated to match the smallest.", .{ entry.value_ptr.attribute.name, entry.key_ptr.*, attribute_len, prev_vertex_count });
                    vertex_count = @min(prev_vertex_count, attribute_len);
                }
            } else {
                vertex_count = attribute_len;
            }
        }

        return vertex_count orelse 0;
    }

    pub fn getVertexBufferData(self: *const Mesh) []u8 {
        var vertex_size: u64 = 0;
        var iter = self.attributes.valueIterator();
        while (iter.next()) |attribute_data| {
            vertex_size += attribute_data.attribute.format.getSize();
        }

        var vertex_count = self.countVertices();
        var attributes_interleaved_buffer = aya.mem.alloc(u8, vertex_count * vertex_size);
        var fixed_buffer_stream = std.io.fixedBufferStream(attributes_interleaved_buffer);
        var interleaved_buffer_writer = fixed_buffer_stream.writer();

        // bundle into interleaved buffers
        iter = self.attributes.valueIterator();
        while (iter.next()) |attribute_data| {
            const attributes_bytes = attribute_data.values.getBytes();
            interleaved_buffer_writer.writeAll(attributes_bytes) catch unreachable;
        }

        return attributes_interleaved_buffer;
    }

    pub fn prepareAsset(mesh: *const Mesh.ExtractedAsset, _: Mesh.Param) Mesh.PreparedAsset {
        var vertex_buffer_data = mesh.getVertexBufferData();
        var vertex_buffer = sg.makeBuffer(.{
            .type = .VERTEXBUFFER,
            .label = "Mesh Vertex Buffer",
            .data = sg.asRange(vertex_buffer_data),
        });
        aya.mem.free(vertex_buffer_data);

        const buffer_info: GpuBufferInfo = if (mesh.indices) |indices| blk: {
            break :blk .{
                .indexed = .{
                    .buffer = sg.makeBuffer(.{
                        .type = .INDEXBUFFER,
                        .label = "Mesh Index Buffer",
                        .data = sg.asRange(indices.getBytes()),
                    }),
                    .count = @intCast(indices.getLength()),
                    .index_format = std.meta.activeTag(indices),
                },
            };
        } else .{ .non_indexed = {} };

        return .{
            .vertex_buffer = vertex_buffer,
            .vertex_count = @intCast(mesh.countVertices()),
            .buffer_info = buffer_info,
            .primitive_topology = mesh.topology,
            .layout = mesh.getMeshVertexBufferLayout(),
        };
    }

    // Asset trait types
    pub const ExtractedAsset = Mesh;
    pub const PreparedAsset = GpuMesh;

    /// only Resources allowed
    pub const Param = struct {
        assets: *aya.Assets(Mesh),
    };
};

pub const GpuMesh = struct {
    vertex_buffer: sg.Buffer,
    vertex_count: u32,
    buffer_info: GpuBufferInfo,
    primitive_topology: PrimitiveTopology,
    layout: MeshVertexBufferLayout,

    pub fn deinit(self: GpuMesh) void {
        sg.destroyBuffer(self.vertex_buffer);
        self.buffer_info.deinit();
        self.layout.deinit();
    }

    pub fn getBindings(self: GpuMesh) sg.Bindings {
        var bindings = sg.Bindings{};

        for (self.layout.layout.attributes, 0..) |attribute, i| {
            bindings.vertex_buffers[i] = self.vertex_buffer;
            bindings.vertex_buffer_offsets[i] = @intCast(attribute.offset * self.vertex_count);
        }

        switch (self.buffer_info) {
            .indexed => |indexed| bindings.index_buffer = indexed.buffer,
            else => {},
        }
        return bindings;
    }

    pub fn getPipelineDesc(self: GpuMesh) sg.PipelineDesc {
        var pip_desc = sg.PipelineDesc{
            .depth = .{
                .compare = .LESS_EQUAL,
                .write_enabled = true,
            },
        };

        switch (self.buffer_info) {
            .indexed => |indexed| {
                switch (indexed.index_format) {
                    .u16 => pip_desc.index_type = .UINT16,
                    .u32 => pip_desc.index_type = .UINT32,
                }
            },
            else => {},
        }

        for (self.layout.layout.attributes, 0..) |attribute, i| {
            pip_desc.layout.attrs[i].format = attribute.format.toSokol();
            pip_desc.layout.attrs[i].buffer_index = @intCast(i);
        }

        return pip_desc;
    }
};

pub const VertexStepMode = enum {
    per_vertex,
    per_instance,
};

pub const VertexAttribute = struct {
    offset: u64,
    format: VertexFormat,
    shader_location: u32,
};

pub const VertexBufferLayout = struct {
    /// The stride, in bytes, between elements of this buffer.
    array_stride: i32,
    /// How often this vertex buffer is "stepped" forward.
    step_mode: VertexStepMode,
    /// The list of attributes which comprise a single vertex.
    attributes: []VertexAttribute,

    pub fn deinit(self: VertexBufferLayout) void {
        aya.mem.free(self.attributes);
    }
};

pub const MeshVertexBufferLayout = struct {
    attribute_ids: []MeshVertexAttributeId,
    layout: VertexBufferLayout,

    pub fn deinit(self: MeshVertexBufferLayout) void {
        aya.mem.free(self.attribute_ids);
        self.layout.deinit();
    }
};

pub const GpuBufferInfo = union(enum) {
    indexed: struct {
        buffer: sg.Buffer,
        count: u32,
        index_format: IndexFormat,
    },
    non_indexed: void,

    pub fn deinit(self: GpuBufferInfo) void {
        switch (self) {
            .indexed => |indexed| sg.destroyBuffer(indexed.buffer),
            else => {},
        }
    }
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
