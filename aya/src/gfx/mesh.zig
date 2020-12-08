const std = @import("std");
const aya = @import("../../aya.zig");
const renderkit = @import("renderkit");
const renderer = renderkit.renderer;

pub const Mesh = struct {
    bindings: renderer.BufferBindings,
    element_count: c_int,

    pub fn init(comptime IndexT: type, indices: []IndexT, comptime VertT: type, verts: []VertT) Mesh {
        var ibuffer = renderer.createBuffer(IndexT, .{
            .type = .index,
            .content = indices,
        });
        var vbuffer = renderer.createBuffer(VertT, .{
            .content = verts,
        });

        return .{
            .bindings = renderer.BufferBindings.init(ibuffer, &[_]renderer.Buffer{vbuffer}),
            .element_count = @intCast(c_int, indices.len),
        };
    }

    pub fn deinit(self: Mesh) void {
        renderer.destroyBuffer(self.bindings.index_buffer);
        renderer.destroyBuffer(self.bindings.vert_buffers[0]);
    }

    pub fn bindImage(self: *Mesh, image: renderkit.Image, slot: c_uint) void {
        self.bindings.bindImage(image, slot);
    }

    pub fn draw(self: Mesh) void {
        renderer.applyBindings(self.bindings);
        renderer.draw(0, self.element_count, 1);
    }
};

/// Contains a dynamic vert buffer and a slice of verts
pub fn DynamicMesh(comptime IndexT: type, comptime VertT: type) type {
    std.debug.assert(IndexT == u16 or IndexT == u32 or IndexT == void);

    return struct {
        const Self = @This();

        bindings: renderkit.BufferBindings,
        verts: []VertT,
        element_count: c_int,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: ?*std.mem.Allocator, vertex_count: usize, indices: []IndexT) !Self {
            const alloc = allocator orelse aya.mem.allocator;

            var ibuffer = if (IndexT == void) @as(renderer.Buffer, 0) else renderer.createBuffer(IndexT, .{
                .type = .index,
                .content = indices,
            });
            var vertex_buffer = renderer.createBuffer(VertT, .{
                .usage = .stream,
                .size = @intCast(c_long, vertex_count * @sizeOf(VertT)),
            });

            return Self{
                .bindings = renderer.BufferBindings.init(ibuffer, &[_]renderer.Buffer{vertex_buffer}),
                .verts = try alloc.alloc(VertT, vertex_count),
                .element_count = @intCast(c_int, indices.len),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: *Self) void {
            if (IndexT != void)
                renderer.destroyBuffer(self.bindings.index_buffer);
            renderer.destroyBuffer(self.bindings.vert_buffers[0]);
            self.allocator.free(self.verts);
        }

        pub fn updateAllVerts(self: *Self) void {
            renderer.updateBuffer(VertT, self.bindings.vert_buffers[0], self.verts);
            // updateBuffer gives us a fresh buffer so make sure we reset our append offset
            self.bindings.vertex_buffer_offsets[0] = 0;
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
            const vert_slice = self.verts[start_index .. start_index + num_verts];
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
            self.draw(0, @intCast(c_int, self.element_count));
        }
    };
}

/// Contains a dynamic instance buffer and a slice of verts CPU side
pub fn InstancedMesh(comptime IndexT: type, comptime VertT: type, comptime InstanceT: type) type {
    std.debug.assert(IndexT == u16 or IndexT == u32);

    return struct {
        const Self = @This();

        bindings: renderkit.BufferBindings,
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
                .size = @intCast(c_long, instance_count * @sizeOf(InstanceT)),
                .step_func = .per_instance,
            });

            return Self{
                .bindings = renderer.BufferBindings.init(ibuffer, &[_]renderer.Buffer{ vertex_buffer, instance_buffer }),
                .instance_data = try alloc.alloc(InstanceT, instance_count),
                .element_count = @intCast(c_int, indices.len),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: *Self) void {
            renderer.destroyBuffer(self.bindings.index_buffer);
            renderer.destroyBuffer(self.bindings.vert_buffers[0]);
            renderer.destroyBuffer(self.bindings.vert_buffers[1]);
            self.allocator.free(self.instance_data);
        }

        pub fn updateInstanceData(self: *Self) void {
            renderer.updateBuffer(InstanceT, self.bindings.vert_buffers[1], self.instance_data);
            // updateBuffer gives us a fresh buffer so make sure we reset our append offset
            self.bindings.vertex_buffer_offsets[1] = 0;
        }

        /// uploads to the GPU the slice up to num_elements
        pub fn updateInstanceDataSlice(self: *Self, num_elements: usize) void {
            std.debug.assert(num_elements <= self.instance_data.len);
            const slice = self.instance_data[0..num_elements];
            renderer.updateBuffer(InstanceT, self.bindings.vert_buffers[1], slice);
        }

        pub fn bindImage(self: *Self, image: renderkit.Image, slot: c_uint) void {
            self.bindings.bindImage(image, slot);
        }

        pub fn draw(self: Self, base_element: c_int, element_count: c_int, instance_count: c_int) void {
            renderer.applyBindings(self.bindings);
            renderer.draw(base_element, element_count, instance_count);
        }

        pub fn drawAll(self: Self) void {
            self.draw(0, @intCast(c_int, self.element_count), @intCast(c_int, self.instance_data.len));
        }
    };
}
