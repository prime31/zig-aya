const std = @import("std");
const aya = @import("../aya.zig");
const Vertex = @import("buffers.zig").Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;
usingnamespace aya.sokol;

pub const Batcher = struct {
    mesh: DynamicMesh(Vertex),
    draw_calls: std.ArrayList(DrawCall),

    vert_index: usize = 0, // current index into the vertex array
    vert_count: i32 = 0, // total verts that we have not yet rendered
    buffer_offset: i32 = 0, // offset into the vertex buffer of the first non-rendered vert
    discard_next: bool = false, // flag for dealing with the Metal issue where we have to discard our buffer 2 times

    const DrawCall = struct {
        texture: ?sg_image,
        vert_count: i32,
    };

    pub fn init(allocator: ?*std.mem.Allocator, max_sprites: usize) !Batcher {
        const alloc = allocator orelse aya.mem.allocator;

        var indices = try aya.mem.tmp_allocator.alloc(u16, @intCast(usize, max_sprites * 6));
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
            .mesh = try DynamicMesh(Vertex).init(alloc, max_sprites * 4, indices),
            .draw_calls = try std.ArrayList(DrawCall).initCapacity(alloc, 10),
        };
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
        self.discard_next = false;

        self.mesh.appendVertSlice(self.buffer_offset, self.vert_count);

        // run through all our accumulated draw calls
        for (self.draw_calls.items) |*draw_call| {
            // aya.gfx.Texture.bindTexture(draw_call.texture.?, 0);
            self.mesh.drawPartialBuffer(self.buffer_offset, draw_call.vert_count);

            self.buffer_offset += draw_call.vert_count;
            draw_call.texture = null;
        }

        self.vert_count = 0;
        self.draw_calls.items.len = 0;
    }

    /// ensures the vert buffer has enough space and manages the draw call command buffer when textures change
    fn ensureCapacity(self: *Batcher, texture: ?sg_image) !void {
        // if we run out of buffer we have to flush the batch and possibly discard the whole buffer
        if (self.vert_index + 4 > self.mesh.verts.len) {
            // TODO: is this hack here for Metal discard hack?
            if (self.draw_calls.items.len == 0) {
                // self.mesh.appendVertSlice(0, 1, .discard);
            } else {
                self.flush(true);
            }

            self.vert_index = 0;
            self.vert_count = 0;
            self.buffer_offset = 0;
        }

        // start a new draw call if we dont already have one going or whenever the texture changes
        if (self.draw_calls.items.len == 0 or self.draw_calls.items[self.draw_calls.items.len - 1].texture.?.id != texture.?.id) {
            try self.draw_calls.append(.{ .texture = texture.?, .vert_count = 0 });
        }
    }

    pub fn draw(self: *Batcher, texture: aya.gfx.Texture, quad: aya.math.Quad, mat: aya.math.Mat32, color: aya.math.Color) void {
        self.ensureCapacity(texture.img) catch |err| {
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
