const std = @import("std");
const fna = @import("../deps/fna/fna.zig");
const aya = @import("../aya.zig");
const gfx = @import("gfx.zig");
const buffers = @import("buffers.zig");

pub const Mesh = struct {
    index_buffer: buffers.IndexBuffer,
    vert_buffer: buffers.VertexBuffer,
    vert_buffer_binding: fna.VertexBufferBinding = undefined,

    pub fn init(comptime T: type, vertex_count: i32, index_count: i32, vbuff_dynamic: bool, ibuff_dynamic: bool) Mesh {
        var mesh = Mesh{
            .index_buffer = buffers.IndexBuffer.init(index_count, ibuff_dynamic),
            .vert_buffer = buffers.VertexBuffer.init(T, vertex_count, vbuff_dynamic),
        };

        mesh.vert_buffer_binding = fna.VertexBufferBinding{
            .vertexBuffer = mesh.vert_buffer.buffer,
            .vertexDeclaration = buffers.VertexBuffer.vertexDeclarationForType(T) catch unreachable,
        };

        return mesh;
    }

    pub fn deinit(self: Mesh) void {
        self.index_buffer.deinit();
        self.vert_buffer.deinit();
    }

    /// render the mesh. Assumes .triangle_list and .sixteen_bit index buffer ele size
    pub fn draw(self: *Mesh, num_vertices: i32) void {
        const primitive_count = @divExact(num_vertices, 2);

        fna.FNA3D_ApplyVertexBufferBindings(aya.gfx.device, &self.vert_buffer_binding, 1, 0, 0); // last 2 params: bindings_updated: u8, base_vertex: i32
        fna.FNA3D_DrawIndexedPrimitives(aya.gfx.device, .triangle_list, 0, 0, num_vertices, 0, primitive_count, self.index_buffer.buffer, .sixteen_bit);
    }
};

/// Contains a dynamic VertexBuffer and a slice of verts. The IndexBuffer is optionally dynammic. If it is dynamic
/// a slice of indices will also be maintained.
pub fn DynamicMesh(comptime T: type) type {
    return struct {
        const Self = @This();

        index_buffer: buffers.IndexBuffer,
        vert_buffer: buffers.VertexBuffer,
        vert_buffer_binding: fna.VertexBufferBinding = undefined,
        verts: []T,
        indices: []i16 = undefined,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: ?*std.mem.Allocator, vertex_count: i32, index_count: i32, ibuff_dynamic: bool) !Self {
            const alloc = allocator orelse aya.mem.allocator;

            var mesh = Self{
                .index_buffer = buffers.IndexBuffer.init(index_count, ibuff_dynamic),
                .vert_buffer = buffers.VertexBuffer.init(T, vertex_count, true),
                .verts = try alloc.alloc(T, @intCast(usize, vertex_count)),
                .indices = &[_]i16{},
                .allocator = alloc,
            };

            if (ibuff_dynamic) {
                mesh.indices = try alloc.alloc(i16, @intCast(usize, index_count));
            }

            mesh.vert_buffer_binding = fna.VertexBufferBinding{
                .vertexBuffer = mesh.vert_buffer.buffer,
                .vertexDeclaration = buffers.VertexBuffer.vertexDeclarationForType(T) catch unreachable,
            };

            return mesh;
        }

        pub fn deinit(self: Self) void {
            self.index_buffer.deinit();
            self.vert_buffer.deinit();
            self.allocator.free(self.verts);
            if (self.indices.len > 0) self.allocator.free(self.indices);
        }

        /// Try not to use .none when using dynamic vert buffers
        pub fn updateAllVerts(self: Self, options: fna.SetDataOptions) void {
            self.vert_buffer.setData(T, self.verts, 0, options);
        }

        /// uploads to the GPU the slice from start to end
        pub fn appendVertSlice(self: Self, start_index: i32, num_verts: i32, options: fna.SetDataOptions) void {
            std.debug.assert(start_index + num_verts <= self.verts.len);
            // cheat a bit here and use the VertexBufferBinding data to get the element size of our verts
            const offset_in_bytes = start_index * self.vert_buffer_binding.vertexDeclaration.vertexStride;
            const vert_slice = self.verts[start_index .. start_index + num_verts];

            self.vert_buffer.setData(vert_slice, offset_in_bytes, options);
        }

        pub fn updateIndices(self: Self, options: fna.SetDataOptions) void {
            std.debug.assert(self.indices.len > 0);
            self.index_buffer.setData(i16, self.indices, 0, options);
        }

        pub fn draw(self: *Self, base_vertex: i32, num_vertices: i32) void {
            const primitive_count = @divExact(num_vertices, 2); // assuming .triangle_list

            fna.FNA3D_ApplyVertexBufferBindings(aya.gfx.device, &self.vert_buffer_binding, 1, 0, base_vertex); // last 2 params: bindings_updated: u8, base_vertex: i32
            fna.FNA3D_DrawIndexedPrimitives(aya.gfx.device, .triangle_list, base_vertex, 0, num_vertices, 0, primitive_count, self.index_buffer.buffer, .sixteen_bit);
        }
    };
}

test "test mesh" {
    var mesh = Mesh.init(buffers.Vertex, 5, 5, true, false);
    mesh.draw(2);
    mesh.deinit();

    var dyn_mesh = try DynamicMesh(buffers.Vertex).init(null, 10, 10, false);
    dyn_mesh.updateAllVerts(.none);
    dyn_mesh.draw(0, 2);
    dyn_mesh.deinit();
}
