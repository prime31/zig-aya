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
        const primitive_count = @divExact(num_vertices, 2); // assuming Triangle_List

        fna.FNA3D_ApplyVertexBufferBindings(aya.gfx.device, &self.vert_buffer_binding, 1, 0, 0); // last 2 params: bindings_updated: u8, base_vertex: i32
        fna.FNA3D_DrawIndexedPrimitives(aya.gfx.device, .triangle_list, 0, 0, num_vertices, 0, primitive_count, self.index_buffer.buffer, .sixteen_bit);
    }
};

pub const DynamicMesh = struct {
    index_buffer: buffers.IndexBuffer,
    vert_buffer: buffers.VertexBuffer,
    vert_buffer_binding: fna.VertexBufferBinding = undefined,

    pub fn init(comptime T: type, vertex_count: i32, index_count: i32, ibuff_dynamic: bool) DynamicMesh {
        var mesh = DynamicMesh{
            .index_buffer = buffers.IndexBuffer.init(index_count, ibuff_dynamic),
            .vert_buffer = buffers.VertexBuffer.init(T, vertex_count, true),
        };

        mesh.vert_buffer_binding = fna.VertexBufferBinding{
            .vertexBuffer = mesh.vert_buffer.buffer,
            .vertexDeclaration = buffers.VertexBuffer.vertexDeclarationForType(T) catch unreachable,
        };

        return mesh;
    }
};

test "test mesh" {
    var mesh = Mesh.init(buffers.Vertex, 5, 5, true, false);
    mesh.draw(2);
}
