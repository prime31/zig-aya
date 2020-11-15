const std = @import("std");
const renderkit = @import("renderkit");
const aya = @import("../../aya.zig");
const gfx = aya.gfx;
const math = aya.math;

const IndexBuffer = renderkit.IndexBuffer;
const VertexBuffer = renderkit.VertexBuffer;
const Vertex = gfx.Vertex;
const Texture = gfx.Texture;

pub const Batcher = struct {
    mesh: gfx.DynamicMesh(u16, Vertex),
    vert_index: usize = 0, // current index into the vertex array
    current_image: renderkit.Image = std.math.maxInt(renderkit.Image),

    pub fn init(allocator: ?*std.mem.Allocator, max_sprites: usize) !Batcher {
        const alloc = allocator orelse aya.mem.allocator;
        if (max_sprites * 6 > std.math.maxInt(u16)) @panic("max_sprites exceeds u16 index buffer size");

        var indices = try aya.mem.tmp_allocator.alloc(u16, max_sprites * 6);
        var i: usize = 0;
        while (i < max_sprites) : (i += 1) {
            indices[i * 3 * 2 + 0] = @intCast(u16, i) * 4 + 0;
            indices[i * 3 * 2 + 1] = @intCast(u16, i) * 4 + 1;
            indices[i * 3 * 2 + 2] = @intCast(u16, i) * 4 + 2;
            indices[i * 3 * 2 + 3] = @intCast(u16, i) * 4 + 0;
            indices[i * 3 * 2 + 4] = @intCast(u16, i) * 4 + 2;
            indices[i * 3 * 2 + 5] = @intCast(u16, i) * 4 + 3;
        }

        return Batcher{
            .mesh = try gfx.DynamicMesh(u16, Vertex).init(alloc, max_sprites * 4, indices),
        };
    }

    pub fn deinit(self: *Batcher) void {
        self.mesh.deinit();
    }

    pub fn begin(self: *Batcher) void {
        self.vert_index = 0;
    }

    pub fn end(self: *Batcher) void {
        self.flush();
    }

    pub fn flush(self: *Batcher) void {
        if (self.vert_index == 0) return;

        // send data
        self.mesh.updateVertSlice(0, self.vert_index);

        // bind texture
        self.mesh.bindImage(self.current_image, 0);

        // draw
        const quads = @divExact(self.vert_index, 4);
        self.mesh.draw(@intCast(c_int, quads * 6));

        // reset
        self.vert_index = 0;
    }

    pub fn draw(self: *Batcher, texture: Texture, quad: math.Quad, mat: math.Mat32, color: math.Color) void {
        if (self.vert_index >= self.mesh.verts.len or self.current_image != texture.img) {
            self.flush();
        }

        self.current_image = texture.img;

        // copy the quad positions, uvs and color into vertex array transforming them with the matrix as we do it
        mat.transformQuad(self.mesh.verts[self.vert_index .. self.vert_index + 4], quad, color);

        self.vert_index += 4;
    }
};
