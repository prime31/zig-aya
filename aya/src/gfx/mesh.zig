const std = @import("std");
const aya = @import("../aya.zig");
const gfx = aya.gfx;
const buffers = @import("buffers.zig");
usingnamespace aya.sokol;

pub const Mesh = struct {
    bindings: sg_bindings = undefined,
    element_count: c_int,

    pub fn init(comptime T: type, verts: []T, indices: []u16) Mesh {
        const vertex_buffer = buffers.VertexBuffer.make(T, verts);
        const index_buffer = buffers.IndexBuffer.make(u16, indices);
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
        element_count: c_int,
        verts_updated: bool = false,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: ?*std.mem.Allocator, vertex_count: usize, indices: []u16) !Self {
            return initWithOptions(allocator, vertex_count, indices, .SG_USAGE_DYNAMIC);
        }

        pub fn initWithOptions(allocator: ?*std.mem.Allocator, vertex_count: usize, indices: []u16, usage: sg_usage) !Self {
            const alloc = allocator orelse aya.mem.allocator;
            const vertex_buffer = buffers.VertexBuffer.makeMutable(T, vertex_count, usage);
            const index_buffer = buffers.IndexBuffer.make(u16, indices);

            return Self{
                .bindings = buffers.Bindings.make(vertex_buffer, index_buffer),
                .verts = try alloc.alloc(T, @intCast(usize, vertex_count)),
                .element_count = @intCast(c_int, indices.len),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: Self) void {
            sg_destroy_buffer(self.bindings.vertex_buffers[0]);
            sg_destroy_buffer(self.bindings.index_buffer);
            self.allocator.free(self.verts);
        }

        /// deinits the current VertexBuffer and creates a new one with the new_vertex_count
        pub fn expandBuffers(self: *Self, new_vertex_count: usize, new_index_count: usize) !void {
            @panic("wtf, just make a new mesh or something");
            // self.vert_buffer.deinit();
            // self.vert_buffer = buffers.VertexBuffer.init(T, new_vertex_count, true);
            // self.vert_buffer_binding.vertexBuffer = self.vert_buffer.buffer;
            // self.verts = try self.allocator.realloc(self.verts, @intCast(usize, new_vertex_count));

            // const ibuff_dynamic = self.indices.len > 0;
            // self.index_buffer.deinit();
            // self.index_buffer = buffers.IndexBuffer.init(new_index_count, ibuff_dynamic);
            // if (ibuff_dynamic) {
            //     self.indices = try self.allocator.realloc(self.indices, @intCast(usize, new_index_count));
            // }
        }

        /// try not to use .none when using dynamic vert buffers
        pub fn updateAllVerts(self: *Self) void {
            if (self.verts_updated) {
                return;
            }
            self.verts_updated = true;

            sg_update_buffer(self.bindings.vertex_buffers[0], self.verts.ptr, @intCast(c_int, self.verts.len * @sizeOf(T)));
        }

        /// uploads to the GPU the slice from start with num_verts
        pub fn appendVertSlice(self: *Self, start_index: i32, num_verts: i32) void {
            std.debug.assert(start_index + num_verts <= self.verts.len);
            const vert_slice = self.verts[@intCast(usize, start_index)..@intCast(usize, start_index + num_verts)];
            self.bindings.vertex_buffer_offsets[0] = sg_append_buffer(self.bindings.vertex_buffers[0], vert_slice.ptr, @intCast(c_int, vert_slice.len * @sizeOf(T)));
        }

        pub fn draw(self: *Self) void {
            self.drawPartialBuffer(0, self.element_count);
        }

        pub fn drawPartialBuffer(self: *Self, base_element: i32, num_elements: i32) void {
            sg_apply_bindings(&self.bindings);
            sg_draw(base_element, num_elements, 1);
            self.verts_updated = false;
        }
    };
}
