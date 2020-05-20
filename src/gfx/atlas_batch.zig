const std = @import("std");
const aya = @import("../aya.zig");
const fna = @import("../deps/fna/fna.zig");
const Vertex = @import("buffers.zig").Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;

pub const AtlasBatch = struct {
    mesh: DynamicMesh(Vertex),
    max_sprites: i32,
    sprite_count: usize = 0,
    texture: aya.gfx.Texture,
    buffer_dirty: bool = false,

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
};

test "test atlas batch" {
    var tex = aya.gfx.Texture.init(4, 4);
    var batch = try AtlasBatch.init(null, tex, 10);
    batch.deinit();
}
