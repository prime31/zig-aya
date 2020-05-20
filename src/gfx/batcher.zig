const std = @import("std");
const aya = @import("../aya.zig");
const fna = @import("../deps/fna/fna.zig");
const Vertex = @import("buffers.zig").Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;

pub const Batcher = struct {
    mesh: DynamicMesh(Vertex),
    draw_calls: std.ArrayList(DrawCall),

    vert_index: usize = 0, // current index into the vertex array
    vert_count: i32 = 0, // total verts that we have not yet rendered
    buffer_offset: i32 = 0, // offset into the vertex buffer of the first non-rendered vert
    discard_next: bool = false, // flag for dealing with the Metal issue where we have to discard our buffer 2 times

    const DrawCall = struct {
        texture: ?*fna.Texture,
        vert_count: i32,
    };

    pub fn init(allocator: ?*std.mem.Allocator, max_sprites: i32) !Batcher {
        const alloc = allocator orelse aya.mem.allocator;

        var batcher = Batcher{
            .mesh = try DynamicMesh(Vertex).init(alloc, max_sprites * 4, max_sprites * 6, false),
            .draw_calls = try std.ArrayList(DrawCall).initCapacity(alloc, 10),
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
        batcher.mesh.index_buffer.setData(i16, indices, 0, .none);

        return batcher;
    }

    pub fn deinit(self: Batcher) void {
        self.mesh.deinit();
        self.draw_calls.deinit();
    }

    /// called at the end of the frame when all drawing is complete. Flushes the batch and resets local state.
    pub fn endFrame(self: *Batcher) void {
        self.flush(false);
        self.vert_index = 0;
        self.vert_count = 0;
        self.buffer_offset = 0;
    }

    pub fn flush(self: *Batcher, discard_buffer: bool) void {
        if (self.vert_count == 0) return;

        // if we ran out of space and dont support no_overwrite we have to discard the buffer
        // TODO: we can lose data on Metal with no_overwrite. FNA3D bug or our bug?
        const options: fna.SetDataOptions = if (discard_buffer or self.discard_next or !aya.gfx.device.supportsNoOverwrite()) .discard else .no_overwrite;
        self.discard_next = false;

        self.mesh.appendVertSlice(self.buffer_offset, self.vert_count, options);

        // run through all our accumulated draw calls
        for (self.draw_calls.items) |*draw_call| {
            aya.gfx.Texture.bindTexture(draw_call.texture.?, 0);
            self.mesh.draw(self.buffer_offset, draw_call.vert_count);

            self.buffer_offset += draw_call.vert_count;
            draw_call.texture = null;
        }

        self.vert_count = 0;
        self.draw_calls.items.len = 0;
    }

    /// ensures the vert buffer has enough space and manages the draw call command buffer when textures change
    fn ensureCapacity(self: *Batcher, texture: ?*fna.Texture) !void {
        // if we run out of buffer we have to flush the batch and possibly discard the whole buffer
        if (self.vert_index + 4 > self.mesh.verts.len) {
            // TODO: is this hack here for Metal discard hack?
            if (self.draw_calls.items.len == 0) {
                self.mesh.appendVertSlice(0, 1, .discard);
            } else {
                self.flush(true);
            }

            // we have to discard two frames for metal else we lose draws for some reason...
            if (aya.gfx.device.supportsNoOverwrite()) self.discard_next = true;
            self.vert_index = 0;
            self.vert_count = 0;
            self.buffer_offset = 0;
        }

        // start a new draw call if we dont already have one going or whenever the texture changes
        if (self.draw_calls.items.len == 0 or self.draw_calls.items[self.draw_calls.items.len - 1].texture != texture) {
            try self.draw_calls.append(.{ .texture = texture, .vert_count = 0 });
        }
    }

    pub fn draw(self: *Batcher, texture: *fna.Texture, quad: aya.math.Quad, mat: aya.math.Mat32, color: aya.math.Color) void {
        self.ensureCapacity(texture) catch |err| {
            std.debug.warn("Batcher.draw failed to append a draw call with error: {}\n", .{err});
            return;
        };

        // copy the quad positions, uvs and color into vertex array transforming them with the matrix as we do it
        mat.transformQuad(self.mesh.verts[self.vert_index .. self.vert_index + 4], quad, color);

        self.draw_calls.items[self.draw_calls.items.len - 1].vert_count += 4;
        self.vert_count += 4;
        self.vert_index += 4;
    }
};

test "test batcher" {
    var batcher = try Batcher.init(null, 10);
    _ = try batcher.ensureCapacity(null);
    batcher.flush(false);
    batcher.deinit();
}
