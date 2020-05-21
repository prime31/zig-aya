const std = @import("std");
const aya = @import("../aya.zig");
const fna = @import("../deps/fna/fna.zig");
const Vertex = @import("buffers.zig").Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;

// TODO: dont return errors for adds and just dynamically expand the vertex/index buffers
pub const AtlasBatch = struct {
    mesh: DynamicMesh(Vertex),
    max_sprites: i32,
    sprite_count: usize = 0,
    texture: aya.gfx.Texture,
    buffer_dirty: bool = false,

    /// AtlasBatch does not take ownership of the texture passed in
    pub fn init(allocator: ?*std.mem.Allocator, texture: aya.gfx.Texture, max_sprites: i32) !AtlasBatch {
        const alloc = allocator orelse aya.mem.allocator;

        var batch = AtlasBatch{
            .mesh = try DynamicMesh(Vertex).init(alloc, max_sprites * 4, max_sprites * 6, false),
            .max_sprites = max_sprites,
            .texture = texture,
        };

        var indices = try aya.mem.tmp_allocator.alloc(i16, @intCast(usize, max_sprites * 6));
        var i: usize = 0;
        while (i < max_sprites) : (i += 1) {
            indices[i * 3 * 2 + 0] = @intCast(i16, i) * 4 + 0;
            indices[i * 3 * 2 + 1] = @intCast(i16, i) * 4 + 1;
            indices[i * 3 * 2 + 2] = @intCast(i16, i) * 4 + 2;
            indices[i * 3 * 2 + 3] = @intCast(i16, i) * 4 + 0;
            indices[i * 3 * 2 + 4] = @intCast(i16, i) * 4 + 2;
            indices[i * 3 * 2 + 5] = @intCast(i16, i) * 4 + 3;
        }
        batch.mesh.index_buffer.setData(i16, indices, 0, .none);

        return batch;
    }

    pub fn deinit(self: AtlasBatch) void {
        self.mesh.deinit();
    }

    fn ensureCapacity(self: *AtlasBatch) bool {
        return self.sprite_count < self.max_sprites;
    }

    pub fn set(self: *AtlasBatch, index: usize, quad: aya.math.Quad, mat: ?aya.math.Mat32, color: aya.math.Color) void {
        // copy the quad positions, uvs and color into vertex array transforming them with the matrix as we do it
        var vert_index = index * 4;

        const matrix = mat orelse aya.math.Mat32.identity;

        matrix.transformQuad(self.mesh.verts[vert_index .. vert_index + 4], quad, color);
        self.buffer_dirty = true;
    }

    pub fn setViewport(self: *AtlasBatch, index: usize, viewport: aya.math.Rect, mat: ?aya.math.Mat32, color: aya.math.Color) void {
        var quad = aya.math.Quad.init(viewport.x, viewport.y, viewport.w, viewport.h, self.texture.width, self.texture.height);
        self.set(index, quad, mat, color);
    }

    pub fn add(self: *AtlasBatch, quad: aya.math.Quad, mat: ?aya.math.Mat32, color: aya.math.Color) !usize {
        if (!self.ensureCapacity()) return error.OutOfSpace;
        self.set(self.sprite_count, quad, mat, color);

        self.sprite_count += 1;
        return self.sprite_count - 1;
    }

    pub fn addViewport(self: *AtlasBatch, viewport: aya.math.Rect, mat: ?aya.math.Mat32, color: aya.math.Color) !usize {
        var quad = aya.math.Quad.init(viewport.x, viewport.y, viewport.w, viewport.h, self.texture.width, self.texture.height);
        return self.add(quad, mat, color);
    }

    pub fn draw(self: *AtlasBatch) void {
        if (self.buffer_dirty) {
            self.mesh.appendVertSlice(0, @intCast(i32, self.sprite_count * 4), .no_overwrite);
            self.buffer_dirty = false;
        }

        aya.gfx.Texture.bindTexture(self.texture.tex, 0);
        self.mesh.draw(0, @intCast(i32, self.sprite_count * 4));
    }
};

test "test atlas batch" {
    // var tex = aya.gfx.Texture.init(4, 4);
    // var quad = aya.math.Quad.init(0, 0, 4, 4, 4, 4);
    // var batch = try AtlasBatch.init(null, tex, 10);
    // batch.set(0, &quad, null, aya.math.Color.white);
    // batch.deinit();
}
