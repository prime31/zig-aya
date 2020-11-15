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
        renderer.destroyBufferBindings(self.bindings);
    }

    pub fn bindImage(self: Mesh, image: renderkit.Image, slot: c_uint) void {
        renderer.bindImageToBufferBindings(self.bindings, image, slot);
    }

    pub fn draw(self: Mesh) void {
        renderer.drawBufferBindings(self.bindings, 0, self.element_count, 0);
    }
};

/// Contains a dynamic vert buffer and a slice of verts
pub fn DynamicMesh(comptime IndexT: type, comptime VertT: type) type {
    std.debug.assert(IndexT == u16 or IndexT == u32);

    return struct {
        const Self = @This();

        bindings: renderkit.BufferBindings,
        vertex_buffer: renderkit.Buffer,
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
                .vertex_buffer = vertex_buffer,
                .verts = try alloc.alloc(VertT, vertex_count),
                .element_count = @intCast(c_int, indices.len),
                .allocator = alloc,
            };
        }

        pub fn deinit(self: *Self) void {
            // vertex_buffer is owned by BufferBindings so we dont deinit it here
            renderer.destroyBufferBindings(self.bindings);
            self.allocator.free(self.verts);
        }

        pub fn updateAllVerts(self: *Self) void {
            renderer.updateBuffer(VertT, self.vertex_buffer, self.verts);
        }

        /// uploads to the GPU the slice from start_index with num_verts
        pub fn updateVertSlice(self: *Self, start_index: usize, num_verts: usize) void {
            std.debug.assert(start_index + num_verts <= self.verts.len);
            const vert_slice = self.verts[start_index .. start_index + num_verts];
            renderer.updateBuffer(VertT, self.vertex_buffer, vert_slice);
        }

        pub fn bindImage(self: Self, image: renderkit.Image, slot: c_uint) void {
            renderer.bindImageToBufferBindings(self.bindings, image, slot);
        }

        pub fn draw(self: Self, element_count: c_int) void {
            renderer.drawBufferBindings(self.bindings, 0, element_count, 0);
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
            // Buffers are owned by BufferBindings so we dont deinit it here
            renderer.destroyBufferBindings(self.bindings);
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
