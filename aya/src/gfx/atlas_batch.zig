const std = @import("std");
const aya = @import("../aya.zig");
const fna = @import("fna");
const Vertex = @import("buffers.zig").Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;

// TODO: who should own and deinit the Texture?
// TODO: dont return errors for adds and just dynamically expand the vertex/index buffers
pub const AtlasBatch = struct {
    mesh: DynamicMesh(Vertex),
    max_sprites: i32,
    sprite_count: usize = 0,
    texture: aya.gfx.Texture,
    buffer_dirty: bool = false,
    dirty_range: struct { start: i32, end: i32 },

    /// AtlasBatch does not take ownership of the texture passed in
    pub fn init(allocator: ?*std.mem.Allocator, texture: aya.gfx.Texture, max_sprites: i32) !AtlasBatch {
        const alloc = allocator orelse aya.mem.allocator;

        var batch = AtlasBatch{
            .mesh = try DynamicMesh(Vertex).init(alloc, max_sprites * 4, max_sprites * 6, false),
            .max_sprites = max_sprites,
            .texture = texture,
            .dirty_range = .{ .start = 0, .end = 0 },
        };

        try batch.setIndexBufferData(max_sprites);

        return batch;
    }

    pub fn deinit(self: AtlasBatch) void {
        self.mesh.deinit();
    }

    /// fills in the IndexBuffer and uploads it to the GPU
    fn setIndexBufferData(self: *AtlasBatch, max_sprites: i32) !void {
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
        self.mesh.index_buffer.setData(i16, indices, 0, .none);
    }

    /// makes sure the mesh buffers are large enough. Expands them by 50% if they are not. Can fail horribly.
    fn ensureCapacity(self: *AtlasBatch) !void {
        if (self.sprite_count < self.max_sprites) return;

        // we dont update the max_sprites value unless all allocations succeed. If they dont, we bail.
        const new_max_sprites = self.max_sprites + @floatToInt(i32, @intToFloat(f32, self.max_sprites) * 0.5);
        try self.mesh.expandBuffers(new_max_sprites * 4, new_max_sprites * 6);
        try self.setIndexBufferData(new_max_sprites);
        self.max_sprites = new_max_sprites;
    }

    /// the workhorse. Sets the actual verts in the mesh and keeps track of if the mesh is dirty.
    pub fn set(self: *AtlasBatch, index: usize, quad: aya.math.Quad, mat: ?aya.math.Mat32, color: aya.math.Color) void {
        var vert_index = index * 4;

        const matrix = mat orelse aya.math.Mat32.identity;

        // copy the quad positions, uvs and color into vertex array transforming them with the matrix as we do it
        matrix.transformQuad(self.mesh.verts[vert_index .. vert_index + 4], quad, color);
        self.buffer_dirty = true;
    }

    pub fn setViewport(self: *AtlasBatch, index: usize, viewport: aya.math.RectI, mat: ?aya.math.Mat32, color: aya.math.Color) void {
        var quad = aya.math.Quad.init(viewport.x, viewport.y, viewport.w, viewport.h, self.texture.width, self.texture.height);
        self.set(index, quad, mat, color);
    }

    /// adds a new quad to the batch returning the index so that it can be updated with set* later
    pub fn add(self: *AtlasBatch, quad: aya.math.Quad, mat: ?aya.math.Mat32, color: aya.math.Color) usize {
        self.ensureCapacity() catch |err| {
            std.debug.warn("failed to ensureCapacity with error: {}\n", .{err});
            return 0;
        };
        self.set(self.sprite_count, quad, mat, color);

        self.sprite_count += 1;
        return self.sprite_count - 1;
    }

    /// adds a new quad to the batch returning the index so that it can be updated with set* later
    pub fn addViewport(self: *AtlasBatch, viewport: aya.math.RectI, mat: ?aya.math.Mat32, color: aya.math.Color) usize {
        var quad = aya.math.Quad.init(@intToFloat(f32, viewport.x), @intToFloat(f32, viewport.y), @intToFloat(f32, viewport.w), @intToFloat(f32, viewport.h), self.texture.width, self.texture.height);
        return self.add(quad, mat, color);
    }

    pub fn draw(self: *AtlasBatch) void {
        if (self.buffer_dirty) {
            self.mesh.appendVertSlice(0, @intCast(i32, self.sprite_count * 4), .no_overwrite);
            self.buffer_dirty = false;
        }

        aya.gfx.Texture.bindTexture(self.texture.tex, 0);
        self.mesh.drawQuads(0, @intCast(i32, self.sprite_count * 4));
    }
};

test "test atlas batch" {
    // var tex = aya.gfx.Texture.init(4, 4);
    // var quad = aya.math.Quad.init(0, 0, 4, 4, 4, 4);
    // var batch = try AtlasBatch.init(null, tex, 10);
    // batch.set(0, &quad, null, aya.math.Color.white);
    // batch.deinit();
}
