const std = @import("std");
const aya = @import("../../aya.zig");
const renderkit = @import("renderkit");
const renderer = renderkit.renderer;

pub const Mesh = struct {
    bindings: renderer.BufferBindings,
    element_count: c_int,

    pub fn init(comptime IndexT: type, indices: []IndexT, comptime VertT: type, verts: []VertT) Mesh {
        std.debug.assert(IndexT == u16 or IndexT == u32);
        var vbuffer = renderer.createBuffer(VertT, .{
            .content = verts,
        });
        var ibuffer = renderer.createBuffer(IndexT, .{
            .type = .index,
            .content = indices,
        });
        var bindings = renderer.createBufferBindings(ibuffer, &[_]renderkit.Buffer{vbuffer});

        return .{
            .bindings = bindings,
            .element_count = @intCast(c_int, indices.len),
        };
    }

    pub fn deinit(self: Mesh) void {
        renderer.destroyBuffer(self.bindings.index_buffer);
        renderer.destroyBuffer(self.bindings.vert_buffers[0]);
    }

    pub fn bindImage(self: Mesh, image: renderkit.Image, slot: c_uint) void {
        renderer.bindImageToBufferBindings(self.bindings, image, slot);
    }

    pub fn draw(self: Mesh) void {
        renderer.drawBufferBindings(self.bindings, 0, self.element_count, 1);
    }
};

/// Contains a dynamic vert buffer and a slice of verts
pub fn DynamicMesh(comptime IndexT: type, comptime VertT: type) type {
    std.debug.assert(IndexT == u16 or IndexT == u32);

    return struct {
        const Self = @This();

        bindings: renderkit.BufferBindings,
        verts: []VertT,
        element_count: c_int,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: ?*std.mem.Allocator, vertex_count: usize, indices: []IndexT) !Self {
            const alloc = allocator orelse aya.mem.allocator;

            var ibuffer = renderer.createBuffer(IndexT, .{
                .type = .index,
                .content = indices,
            });
            var vertex_buffer = renderer.createBuffer(VertT, .{
                .usage = .stream,
                .size = @intCast(c_long, vertex_count * @sizeOf(VertT)),
            });
            var bindings = renderer.createBufferBindings(ibuffer, &[_]renderkit.Buffer{vertex_buffer});

            return Self{
                .bindings = bindings,
                .verts = try alloc.alloc(VertT, vertex_count),
                .element_count = @intCast(c_int, indices.len),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: *Self) void {
            renderer.destroyBuffer(self.bindings.index_buffer);
            renderer.destroyBuffer(self.bindings.vert_buffers[0]);
            self.allocator.free(self.verts);
        }

        pub fn updateAllVerts(self: *Self) void {
            renderer.updateBuffer(VertT, self.bindings.vert_buffers[0], self.verts);
        }

        /// uploads to the GPU the slice from start_index with num_verts
        pub fn updateVertSlice(self: *Self, num_verts: usize) void {
            std.debug.assert(num_verts <= self.verts.len);
            const vert_slice = self.verts[0..num_verts];
            renderer.updateBuffer(VertT, self.bindings.vert_buffers[0], vert_slice);
        }

        /// uploads to the GPU the slice from start with num_verts. Records the offset in the BufferBindings allowing you
        /// to interleave appendVertSlice and draw calls. When calling draw after appendVertSlice
        /// the base_element is reset to the start of the newly updated data so you would pass in 0 for base_element.
        pub fn appendVertSlice(self: *Self, start_index: usize, num_verts: usize) void {
            std.debug.assert(start_index + num_verts <= self.verts.len);
            const vert_slice = self.verts[start_index..start_index + num_verts];
            self.bindings.vertex_buffer_offsets[0] = renderer.appendBuffer(VertT, self.bindings.vert_buffers[0], vert_slice);
        }

        pub fn bindImage(self: *Self, image: renderkit.Image, slot: c_uint) void {
            self.bindings.bindImage(image, slot);
        }

        pub fn draw(self: Self, base_element: c_int, element_count: c_int) void {
            renderer.applyBindings(self.bindings);
            renderer.draw(base_element, element_count, 1);
        }

        pub fn drawAllVerts(self: Self) void {
            self.draw(@intCast(c_int, self.element_count));
        }
    };
}

/// Contains a dynamic instance buffer and a slice of verts CPU side
pub fn InstancedMesh(comptime IndexT: type, comptime VertT: type, comptime InstanceT: type) type {
    std.debug.assert(IndexT == u16 or IndexT == u32);

    return struct {
        const Self = @This();

        bindings: renderkit.BufferBindings,
        instance_buffer: renderkit.Buffer,
        instance_data: []InstanceT,
        element_count: c_int,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: ?*std.mem.Allocator, instance_count: usize, indices: []IndexT, verts: []VertT) !Self {
            const alloc = allocator orelse aya.mem.allocator;

            var ibuffer = renderer.createBuffer(IndexT, .{
                .type = .index,
                .content = indices,
            });
            var vertex_buffer = renderer.createBuffer(VertT, .{
                .content = verts,
            });
            var instance_buffer = renderer.createBuffer(InstanceT, .{
                .usage = .stream,
                .size = @intCast(c_long, 100 * @sizeOf(InstanceT)),
                .step_func = .per_instance,
            });

            var bindings = renderer.createBufferBindings(ibuffer, &[_]renderkit.Buffer{ vertex_buffer, instance_buffer });
            return Self{
                .bindings = bindings,
                .instance_buffer = instance_buffer,
                .instance_data = try alloc.alloc(InstanceT, instance_count),
                .element_count = @intCast(c_int, indices.len),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: *Self) void {
            renderer.destroyBuffer(self.bindings.index_buffer);
            renderer.destroyBuffer(self.bindings.vert_buffers[0]);
            self.allocator.free(self.instance_data);
        }

        pub fn updateInstanceData(self: *Self) void {
            renderer.updateBuffer(InstanceT, self.instance_buffer, self.instance_data);
        }

        /// uploads to the GPU the slice from start_index with num_verts
        pub fn updateInstanceDataSlice(self: *Self, start_index: usize, num_verts: usize) void {
            std.debug.assert(start_index + num_verts <= self.verts.len);
            const slice = self.instance_data[start_index .. start_index + num_verts];
            renderer.updateBuffer(InstanceT, self.instance_buffer, slice);
        }

        pub fn bindImage(self: Self, image: renderkit.Image, slot: c_uint) void {
            renderer.bindImageToBufferBindings(self.bindings, image, slot);
        }

        pub fn draw(self: Self, instance_count: c_int) void {
            renderer.drawBufferBindings(self.bindings, 0, self.element_count, instance_count);
        }

        pub fn drawAll(self: Self) void {
            self.draw(@intCast(c_int, self.instance_data.len));
        }
    };
}
