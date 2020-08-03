const std = @import("std");
const aya = @import("../aya.zig");
const gfx = aya.gfx;
const buffers = @import("buffers.zig");
usingnamespace aya.sokol;

pub const Mesh = struct {
    bindings: sg_bindings = undefined,
    element_count: c_int,

    pub fn init(comptime T: type, verts: []T, indices: []u16) Mesh {
        const vertex_buffer = buffers.VertexBuffer.make(T, verts, .SG_USAGE_IMMUTABLE);
        const index_buffer = buffers.IndexBuffer.make(u16, indices, .SG_USAGE_IMMUTABLE);
        return .{
            .bindings = buffers.Bindings.make(vertex_buffer, index_buffer),
            .element_count = @intCast(c_int, indices.len),
        };
    }

    pub fn deinit(self: Mesh) void {
        sg_destroy_buffer(self.bindings.vertex_buffers[0]);
        sg_destroy_buffer(self.bindings.index_buffer);
    }

    pub fn draw(self: *Mesh) void {
        sg_apply_bindings(&self.bindings);
        sg_draw(0, self.element_count, 1);
    }
};

/// Contains a dynamic vert buffer and a slice of verts
pub fn DynamicMesh(comptime T: type) type {
    return struct {
        const Self = @This();

        bindings: sg_bindings,
        verts: []T,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: ?*std.mem.Allocator, vertex_count: usize, indices: []u16) !Self {
            const alloc = allocator orelse aya.mem.allocator;
            const vertex_buffer = buffers.VertexBuffer.makeMutable(T, vertex_count, .SG_USAGE_DYNAMIC);
            const index_buffer = buffers.IndexBuffer.make(u16, indices, .SG_USAGE_IMMUTABLE);

            return Self {
                .bindings = buffers.Bindings.make(vertex_buffer, index_buffer),
                .verts = try alloc.alloc(T, @intCast(usize, vertex_count)),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: Self) void {
            self.index_buffer.deinit();
            self.vert_buffer.deinit();
            self.allocator.free(self.verts);
            if (self.indices.len > 0) self.allocator.free(self.indices);
        }

        /// deinits the current VertexBuffer and creates a new one with the new_vertex_count
        pub fn expandBuffers(self: *Self, new_vertex_count: i32, new_index_count: i32) !void {
            self.vert_buffer.deinit();
            self.vert_buffer = buffers.VertexBuffer.init(T, new_vertex_count, true);
            self.vert_buffer_binding.vertexBuffer = self.vert_buffer.buffer;
            self.verts = try self.allocator.realloc(self.verts, @intCast(usize, new_vertex_count));

            const ibuff_dynamic = self.indices.len > 0;
            self.index_buffer.deinit();
            self.index_buffer = buffers.IndexBuffer.init(new_index_count, ibuff_dynamic);
            if (ibuff_dynamic) {
                self.indices = try self.allocator.realloc(self.indices, @intCast(usize, new_index_count));
            }
        }

        /// try not to use .none when using dynamic vert buffers
        pub fn updateAllVerts(self: Self, options: fna.SetDataOptions) void {
            self.vert_buffer.setData(T, self.verts, 0, options);
        }

        /// uploads to the GPU the slice from start to end
        pub fn appendVertSlice(self: Self, start_index: i32, num_verts: i32) void {
            std.debug.assert(start_index + num_verts <= self.verts.len);
            // cheat a bit here and use the VertexBufferBinding data to get the element size of our verts
            const offset_in_bytes = start_index * @intCast(i32, @sizeOf(T));
            const vert_slice = self.verts[@intCast(usize, start_index)..@intCast(usize, start_index + num_verts)];

            // self.vert_buffer.setData(T, vert_slice, offset_in_bytes);
        }

        pub fn updateIndices(self: Self, options: fna.SetDataOptions) void {
            std.debug.assert(self.indices.len > 0);
            self.index_buffer.setData(i16, self.indices, 0, options);
        }

        pub fn drawQuads(self: *Self, base_vertex: i32, num_vertices: i32) void {
            const primitive_count = @divExact(num_vertices, 2); // assuming .triangle_list
            self.draw(base_vertex, num_vertices, primitive_count);
        }

        pub fn drawTriangles(self: *Self, base_vertex: i32, num_vertices: i32) void {
            const primitive_count = @divExact(num_vertices, 3); // assuming .triangle_list
            self.draw(base_vertex, num_vertices, primitive_count);
        }

        pub fn draw(self: *Self, base_vertex: i32, num_vertices: i32, primitive_count: i32) void {
            // aya.gfx.device.applyVertexBufferBindings(&self.vert_buffer_binding, 1, false, base_vertex);
            // aya.gfx.device.drawIndexedPrimitives(.triangle_list, base_vertex, 0, num_vertices, 0, primitive_count, self.index_buffer.buffer, .sixteen_bit);
        }
    };
}
