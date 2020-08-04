const std = @import("std");
const aya = @import("../aya.zig");
const fna = @import("fna");
const math = aya.math;
const Vertex = @import("buffers.zig").Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;

pub const TriangleBatcher = struct {
    mesh: DynamicMesh(Vertex),
    draw_calls: std.ArrayList(i32),
    white_tex: aya.gfx.Texture = undefined,

    vert_index: usize = 0, // current index into the vertex array
    vert_count: i32 = 0, // total verts that we have not yet rendered
    buffer_offset: i32 = 0, // offset into the vertex buffer of the first non-rendered vert

    pub fn init(allocator: ?*std.mem.Allocator, max_tris: usize) !TriangleBatcher {
        const alloc = allocator orelse aya.mem.allocator;

        var indices = try aya.mem.tmp_allocator.alloc(u16, @intCast(usize, max_tris * 3));
        var i: usize = 0;
        while (i < max_tris) : (i += 1) {
            indices[i * 3 + 0] = @intCast(u16, i) * 3 + 0;
            indices[i * 3 + 1] = @intCast(u16, i) * 3 + 1;
            indices[i * 3 + 2] = @intCast(u16, i) * 3 + 2;
        }

        var batcher = TriangleBatcher{
            .mesh = try DynamicMesh(Vertex).init(alloc, max_tris * 3, indices),
            .draw_calls = try std.ArrayList(i32).initCapacity(alloc, 10),
        };
        errdefer batcher.deinit();

        var pixels = [_]u32{ 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
        batcher.white_tex = aya.gfx.Texture.initWithColorData(pixels[0..], 2, 2, .nearest);

        return batcher;
    }

    pub fn deinit(self: TriangleBatcher) void {
        self.mesh.deinit();
        self.draw_calls.deinit();
        self.white_tex.deinit();
    }

    /// call at the end of the frame when all drawing is complete. Flushes the batch and resets local state.
    pub fn endFrame(self: *TriangleBatcher) void {
        self.flush();
        self.vert_index = 0;
        self.vert_count = 0;
        self.buffer_offset = 0;
    }

    pub fn flush(self: *TriangleBatcher) void {
        if (self.vert_count == 0) return;

        self.mesh.appendVertSlice(self.buffer_offset, self.vert_count);
        self.mesh.bindings.fs_images[0] = self.white_tex.img;

        // run through all our accumulated draw calls
        for (self.draw_calls.items) |draw_call| {
            self.mesh.drawPartialBuffer(self.buffer_offset, draw_call);
            self.buffer_offset += draw_call;
        }

        self.vert_count = 0;
        self.draw_calls.items.len = 0;
    }

    /// ensures the vert buffer has enough space
    fn ensureCapacity(self: *TriangleBatcher, count: usize) !void {
        // if we run out of buffer we have to flush the batch and possibly discard the whole buffer
        if (self.vert_index + count > self.mesh.verts.len) {
            self.flush();

            // we have to discard two frames for metal else we lose draws for some reason...
            self.vert_index = 0;
            self.vert_count = 0;
            self.buffer_offset = 0;
            @panic("dead");
        }

        // start a new draw call if we dont already have one going
        if (self.draw_calls.items.len == 0) {
            try self.draw_calls.append(0);
        }
    }

    pub fn drawTriangle(self: *TriangleBatcher, pt1: math.Vec2, pt2: math.Vec2, pt3: math.Vec2, color: math.Color) void {
        self.ensureCapacity(3) catch |err| {
            std.debug.warn("TriangleBatcher.draw failed to append a draw call with error: {}\n", .{err});
            return;
        };

        // copy the quad positions, uvs and color into vertex array transforming them with the matrix after we do it
        self.mesh.verts[self.vert_index].pos = pt1;
        self.mesh.verts[self.vert_index].col = color.value;
        self.mesh.verts[self.vert_index + 1].pos = pt2;
        self.mesh.verts[self.vert_index + 1].col = color.value;
        self.mesh.verts[self.vert_index + 2].pos = pt3;
        self.mesh.verts[self.vert_index + 2].col = color.value;

        const mat = math.Mat32.identity;
        mat.transformVertexSlice(self.mesh.verts[self.vert_index .. self.vert_index + 3]);

        self.draw_calls.items[self.draw_calls.items.len - 1] += 3;
        self.vert_count += 3;
        self.vert_index += 3;
    }
};

test "test triangle batcher" {
    var batcher = try TriangleBatcher.init(null, 10);
    _ = try batcher.ensureCapacity(null);
    batcher.flush(false);
    batcher.deinit();
}
