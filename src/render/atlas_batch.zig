const std = @import("std");
const aya = @import("../aya.zig");

const Vertex = aya.gfx.Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;
const RectI = aya.math.RectI;
const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Color = aya.math.Color;
const Quad = aya.math.Quad;

// TODO: who should own and deinit the Texture?
// TODO: dont return errors for adds and just dynamically expand the vertex/index buffers
pub const AtlasBatch = struct {
    mesh: DynamicMesh(u16, Vertex),
    max_sprites: usize,
    sprite_count: usize = 0,
    texture: aya.gfx.Texture,
    buffer_dirty: bool = false,
    dirty_range: struct { start: i32, end: i32 },

    /// AtlasBatch does not take ownership of the texture passed in
    pub fn init(allocator: ?std.mem.Allocator, texture: aya.gfx.Texture, max_sprites: usize) !AtlasBatch {
        const alloc = allocator orelse aya.allocator;

        return AtlasBatch{
            .mesh = try DynamicMesh(u16, Vertex).init(alloc, max_sprites * 4, try getIndexBufferData(max_sprites)),
            .max_sprites = max_sprites,
            .texture = texture,
            .dirty_range = .{ .start = 0, .end = 0 },
        };
    }

    pub fn deinit(self: AtlasBatch) void {
        self.mesh.deinit();
    }

    fn getIndexBufferData(max_sprites: usize) ![]u16 {
        var indices = try aya.mem.tmp_allocator.alloc(u16, max_sprites * 6);
        var i: usize = 0;
        while (i < max_sprites) : (i += 1) {
            indices[i * 3 * 2 + 0] = @as(u16, @intCast(i)) * 4 + 0;
            indices[i * 3 * 2 + 1] = @as(u16, @intCast(i)) * 4 + 1;
            indices[i * 3 * 2 + 2] = @as(u16, @intCast(i)) * 4 + 2;
            indices[i * 3 * 2 + 3] = @as(u16, @intCast(i)) * 4 + 0;
            indices[i * 3 * 2 + 4] = @as(u16, @intCast(i)) * 4 + 2;
            indices[i * 3 * 2 + 5] = @as(u16, @intCast(i)) * 4 + 3;
        }
        return indices;
    }

    /// TODO: fills in the IndexBuffer and uploads it to the GPU
    fn setIndexBufferData(_: *AtlasBatch, max_sprites: usize) !void {
        _ = getIndexBufferData(max_sprites);
        // self.mesh.index_buffer.setData(i16, indices, 0, .none);
        @panic("oh no");
    }

    /// makes sure the mesh buffers are large enough. Expands them by 50% if they are not. Can fail horribly.
    fn ensureCapacity(self: *AtlasBatch) !void {
        if (self.sprite_count < self.max_sprites) return;
        @panic("mesh.expandBuffers not implemented");

        // we dont update the max_sprites value unless all allocations succeed. If they dont, we bail.
        // const new_max_sprites = self.max_sprites + @floatToInt(usize, @intToFloat(f32, self.max_sprites) * 0.5);
        // try self.mesh.expandBuffers(new_max_sprites * 4, new_max_sprites * 6);
        // try self.setIndexBufferData(new_max_sprites);
        // self.max_sprites = new_max_sprites;
    }

    /// the workhorse. Sets the actual verts in the mesh and keeps track of if the mesh is dirty.
    pub fn set(self: *AtlasBatch, index: usize, quad: Quad, mat: ?Mat32, color: Color) void {
        var vert_index = index * 4;

        const matrix = mat orelse Mat32.identity;

        // copy the quad positions, uvs and color into vertex array transforming them with the matrix as we do it
        matrix.transformQuad(self.mesh.verts[vert_index .. vert_index + 4], quad, color);
        self.buffer_dirty = true;
    }

    pub fn setViewport(self: *AtlasBatch, index: usize, viewport: RectI, mat: ?Mat32, color: Color) void {
        var quad = Quad.init(@as(f32, @floatFromInt(viewport.x)), @as(f32, @floatFromInt(viewport.y)), @as(f32, @floatFromInt(viewport.w)), @as(f32, @floatFromInt(viewport.h)), self.texture.width, self.texture.height);
        self.set(index, quad, mat, color);
    }

    /// adds a new quad to the batch returning the index so that it can be updated with set* later
    pub fn add(self: *AtlasBatch, quad: Quad, mat: ?Mat32, color: Color) usize {
        self.ensureCapacity() catch |err| {
            std.debug.print("failed to ensureCapacity with error: {}\n", .{err});
            return 0;
        };
        self.set(self.sprite_count, quad, mat, color);

        self.sprite_count += 1;
        return self.sprite_count - 1;
    }

    /// adds a new quad to the batch returning the index so that it can be updated with set* later
    pub fn addViewport(self: *AtlasBatch, viewport: RectI, mat: ?Mat32, color: Color) usize {
        var quad = Quad.init(@as(f32, @floatFromInt(viewport.x)), @as(f32, @floatFromInt(viewport.y)), @as(f32, @floatFromInt(viewport.w)), @as(f32, @floatFromInt(viewport.h)), self.texture.width, self.texture.height);
        return self.add(quad, mat, color);
    }

    pub fn draw(self: *AtlasBatch) void {
        if (self.buffer_dirty) {
            self.mesh.updateVertSlice(self.sprite_count * 4);
            self.buffer_dirty = false;
        }

        self.mesh.bindImage(self.texture.img, 0);
        self.mesh.draw(0, @as(i32, @intCast(self.sprite_count * 6)));
    }
};
