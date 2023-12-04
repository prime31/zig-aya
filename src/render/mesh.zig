const std = @import("std");
const aya = @import("../aya.zig");

pub const Mesh = struct {
    ibuff: aya.BufferHandle,
    vbuff: aya.BufferHandle,
    element_count: u32,

    pub fn init(comptime IndexT: type, indices: []IndexT, comptime VertT: type, verts: []VertT) Mesh {
        if (true) @panic("untested, fix me");
        var ibuff = aya.gctx.createBufferInit("mesh_index_buffer", .{ .copy_dst = true, .index = true }, IndexT, indices);
        var vbuff = aya.gctx.createBufferInit("mesh_vert_buffer", .{ .copy_dst = true, .vertex = true }, VertT, verts);

        return .{
            .ibuff = ibuff,
            .vbuff = vbuff,
            .element_count = @intCast(indices.len),
        };
    }

    pub fn deinit(self: *Mesh) void {
        aya.gctx.destroyResource(self.ibuff);
        aya.gctx.destroyResource(self.vbuff);
    }
};

pub fn DynamicMesh(comptime IndexT: type, comptime VertT: type) type {
    std.debug.assert(IndexT == u16 or IndexT == u32 or IndexT == void);

    return struct {
        const Self = @This();

        ibuff: aya.BufferHandle,
        vbuff: aya.BufferHandle,
        buffer_offset: u32 = 0,
        verts: []VertT,
        element_count: u32,

        pub fn init(vertex_count: usize, indices: []IndexT) Self {
            var ibuff = aya.gctx.createBufferInit("dynamic_mesh_index_buffer", .{ .copy_dst = true, .index = true }, IndexT, indices);
            var vbuff = aya.gctx.createBuffer(&.{
                .usage = .{ .copy_dst = true, .vertex = true },
                .size = vertex_count * @sizeOf(VertT),
            });
            aya.gctx.lookupResource(vbuff).?.unmap();

            return Self{
                .ibuff = ibuff,
                .vbuff = vbuff,
                .verts = aya.mem.alloc(VertT, vertex_count),
                .element_count = @intCast(indices.len),
            };
        }

        pub fn deinit(self: *Self) void {
            aya.gctx.destroyResource(self.ibuff);
            aya.gctx.destroyResource(self.vbuff);
            aya.mem.free(self.verts);
        }

        pub fn updateAllVerts(self: *Self) void {
            aya.gctx.writeBuffer(self.vbuff, 0, VertT, self.verts);
            self.buffer_offset = 0;
        }

        /// uploads to the GPU the slice from 0 to num_verts
        pub fn updateVertSlice(self: *Self, num_verts: usize) void {
            std.debug.assert(num_verts <= self.verts.len);
            const vert_slice = self.verts[0..num_verts];
            aya.gctx.writeBuffer(self.vbuff, self.buffer_offset, VertT, vert_slice);
            self.buffer_offset += vert_slice.len * @sizeOf(VertT);
        }

        /// uploads to the GPU the slice from start with num_verts. Records the offset in the BufferBindings allowing you
        /// to interleave appendVertSlice and draw calls. When calling draw after appendVertSlice
        /// the base_element is reset to the start of the newly updated data so you would pass in 0 for base_element.
        pub fn appendVertSlice(self: *Self, start_index: usize, num_verts: usize) void {
            std.debug.assert(start_index + num_verts <= self.verts.len);
            const vert_slice = self.verts[start_index .. start_index + num_verts];
            aya.gctx.writeBuffer(self.vbuff, self.buffer_offset, VertT, vert_slice);
            self.buffer_offset += @intCast(vert_slice.len * @sizeOf(VertT));
        }
    };
}

/// Contains a dynamic instance buffer and a slice of verts CPU side
pub fn InstancedMesh(comptime IndexT: type, comptime VertT: type, comptime InstanceT: type) type {
    std.debug.assert(IndexT == u16 or IndexT == u32);

    return struct {
        const Self = @This();

        ibuff: aya.BufferHandle,
        vbuff: aya.BufferHandle,
        instance_buff: aya.BufferHandle,
        instance_data: []InstanceT,
        buffer_offset: u32 = 0,
        element_count: u32,

        pub fn init(instance_count: usize, indices: []IndexT, verts: []VertT) Self {
            if (true) @panic("untested, fix me");
            var ibuff = aya.gctx.createBufferInit("instanced_mesh_index_buffer", .{ .copy_dst = true, .index = true }, IndexT, indices);
            var vbuff = aya.gctx.createBufferInit("mesh_vert_buffer", .{ .copy_dst = true, .vertex = true }, VertT, verts);
            var instance_buff = aya.gctx.createBuffer(&.{
                .usage = .{ .copy_dst = true, .vertex = true },
                .size = instance_count * @sizeOf(InstanceT),
                .step_func = .per_instance,
            });

            return Self{
                .ibuff = ibuff,
                .vbuff = vbuff,
                .instance_buff = instance_buff,
                .instance_data = aya.mem.alloc(InstanceT, instance_count),
                .element_count = @as(c_int, @intCast(indices.len)),
            };
        }

        pub fn deinit(self: *Self) void {
            aya.gctx.destroyResource(self.ibuff);
            aya.gctx.destroyResource(self.vbuff);
            aya.gctx.destroyResource(self.instance_buff);
            aya.mem.free(self.instance_data);
        }

        pub fn updateInstanceData(self: *Self) void {
            aya.gctx.writeBuffer(self.instance_buff, 0, InstanceT, self.instance_data);
            self.buffer_offset = 0;
        }

        /// uploads to the GPU the slice up to num_elements
        pub fn updateInstanceDataSlice(self: *Self, num_elements: usize) void {
            std.debug.assert(num_elements <= self.instance_data.len);
            const slice = self.instance_data[0..num_elements];
            aya.gctx.writeBuffer(self.instance_buff, self.buffer_offset, InstanceT, slice);
            self.buffer_offset += slice.len * @sizeOf(InstanceT);
        }
    };
}
