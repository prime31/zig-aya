const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;

const Vertex = aya.render.Vertex;
const DynamicMesh = @import("mesh.zig").DynamicMesh;

const Vec2 = aya.math.Vec2;
const Color = aya.math.Color;
const Quad = aya.math.Quad;
const Mat32 = aya.math.Mat32;

pub const Batcher = struct {
    mesh: DynamicMesh(u16, Vertex),
    draw_calls: std.ArrayList(DrawCall),

    frame: u32 = 0, // tracks when a batch is started in a new frame so that state can be reset
    vert_index: usize = 0, // current index into the vertex array
    quad_count: usize = 0, // total quads that we have not yet rendered
    buffer_offset: i32 = 0, // offset into the vertex buffer of the first non-rendered vert
    pass: ?wgpu.RenderPassEncoder = null,

    const DrawCall = struct {
        image: aya.render.TextureHandle,
        quad_count: i32,
    };

    fn _createDynamicMesh(max_sprites: u16) DynamicMesh(u16, Vertex) {
        var indices = aya.mem.tmp_allocator.alloc(u16, max_sprites * 6) catch unreachable;
        var i: usize = 0;
        while (i < max_sprites) : (i += 1) {
            indices[i * 3 * 2 + 0] = @as(u16, @intCast(i)) * 4 + 0;
            indices[i * 3 * 2 + 1] = @as(u16, @intCast(i)) * 4 + 1;
            indices[i * 3 * 2 + 2] = @as(u16, @intCast(i)) * 4 + 2;
            indices[i * 3 * 2 + 3] = @as(u16, @intCast(i)) * 4 + 0;
            indices[i * 3 * 2 + 4] = @as(u16, @intCast(i)) * 4 + 2;
            indices[i * 3 * 2 + 5] = @as(u16, @intCast(i)) * 4 + 3;
        }

        return DynamicMesh(u16, Vertex).init(max_sprites * 4, indices);
    }

    pub fn init(max_sprites: u16) Batcher {
        if (max_sprites * 6 > std.math.maxInt(u16)) @panic("max_sprites exceeds u16 index buffer size");

        return .{
            .mesh = _createDynamicMesh(max_sprites),
            .draw_calls = std.ArrayList(DrawCall).initCapacity(aya.mem.allocator, 10) catch unreachable,
        };
    }

    pub fn deinit(self: *Batcher) void {
        self.mesh.deinit();
        self.draw_calls.deinit();
    }

    pub fn begin(self: *Batcher, pass: wgpu.RenderPassEncoder) void {
        std.debug.assert(self.pass == null);

        self.pass = pass;

        // reset all state for new frame
        if (self.frame != aya.time.frames()) {
            self.frame = aya.time.frames();
            self.vert_index = 0;
            self.buffer_offset = 0;
            self.mesh.buffer_offset = 0;
        }
    }

    pub fn end(self: *Batcher) void {
        std.debug.assert(self.pass != null);
        self.flush();
        self.pass = null;
    }

    /// should be called when any graphics state change will occur such as setting a new shader or RenderState
    pub fn flush(self: *Batcher) void {
        if (self.quad_count == 0) return;
        const pass = self.pass orelse return;

        const vbuff = aya.gctx.lookupResourceInfo(self.mesh.vbuff) orelse return;
        const ibuff = aya.gctx.lookupResourceInfo(self.mesh.ibuff) orelse return;

        pass.setVertexBuffer(0, vbuff.gpuobj.?, self.mesh.buffer_offset, vbuff.size);
        pass.setIndexBuffer(ibuff.gpuobj.?, .uint16, 0, ibuff.size);

        self.mesh.appendVertSlice(@as(usize, @intCast(self.buffer_offset)), @as(usize, @intCast(self.quad_count * 4)));

        // run through all our accumulated draw calls
        var base_element: i32 = 0;
        for (self.draw_calls.items) |*draw_call| {
            const tex_view = aya.gctx.createTextureView(draw_call.image, &.{});
            defer aya.gctx.releaseResource(tex_view);

            const sampler = aya.gctx.createSampler(&.{});
            defer aya.gctx.releaseResource(sampler);

            const bind_group_layout = aya.gctx.createBindGroupLayout(&.{
                .entries = &.{
                    .{ .visibility = .{ .fragment = true }, .texture = .{} },
                    .{ .visibility = .{ .fragment = true }, .sampler = .{} },
                },
            });
            defer aya.gctx.releaseResource(bind_group_layout);

            // creating bind groups every time is not great
            const bind_group = aya.gctx.createBindGroup(bind_group_layout, &.{
                .{ .texture_view_handle = tex_view },
                .{ .sampler_handle = sampler },
            });
            aya.gctx.releaseResourceDelayed(bind_group);

            const bg = aya.gctx.lookupResource(bind_group) orelse return;

            pass.setBindGroup(1, bg, null);
            pass.drawIndexed(@intCast(draw_call.quad_count * 6), 1, @intCast(base_element), 0, 0);

            self.buffer_offset += draw_call.quad_count * 4;
            draw_call.image = aya.render.TextureHandle.nil;
            base_element += draw_call.quad_count * 6;
        }

        self.quad_count = 0;
        self.draw_calls.items.len = 0;
    }

    /// ensures the vert buffer has enough space and manages the draw call command buffer when textures change
    fn ensureCapacity(self: *Batcher, texture: aya.render.TextureHandle) !void {
        // if we run out of buffer we have to flush the batch and possibly discard and resize the whole buffer
        if (self.vert_index + 4 > self.mesh.verts.len - 1) {
            self.flush();

            self.vert_index = 0;
            self.buffer_offset = 0;

            self.mesh.updateAllVerts();
        }

        // start a new draw call if we dont already have one going or whenever the texture changes
        if (self.draw_calls.items.len == 0 or self.draw_calls.items[self.draw_calls.items.len - 1].image.id != texture.id) {
            try self.draw_calls.append(.{ .image = texture, .quad_count = 0 });
        }
    }

    pub fn drawTex(self: *Batcher, pos: Vec2, col: u32, texture: aya.render.TextureHandle) void {
        self.ensureCapacity(texture) catch |err| {
            std.debug.print("Batcher.draw failed to append a draw call with error: {}\n", .{err});
            return;
        };

        const tex_info = aya.gctx.lookupResourceInfo(texture).?;
        const size = tex_info.size;
        const tex_width: f32 = @floatFromInt(size.width);
        const tex_height: f32 = @floatFromInt(size.height);

        var verts = self.mesh.verts[self.vert_index .. self.vert_index + 4];
        verts[0].pos = pos; // tl
        verts[0].uv = .{ .x = 0, .y = 0 };
        verts[0].col = col;

        verts[1].pos = .{ .x = pos.x + tex_width, .y = pos.y }; // tr
        verts[1].uv = .{ .x = 1, .y = 0 };
        verts[1].col = col;

        verts[2].pos = .{ .x = pos.x + tex_width, .y = pos.y + tex_height }; // br
        verts[2].uv = .{ .x = 1, .y = 1 };
        verts[2].col = col;

        verts[3].pos = .{ .x = pos.x, .y = pos.y + tex_height }; // bl
        verts[3].uv = .{ .x = 0, .y = 1 };
        verts[3].col = col;

        self.draw_calls.items[self.draw_calls.items.len - 1].quad_count += 1;
        self.quad_count += 1;
        self.vert_index += 4;
    }

    pub fn draw(self: *Batcher, texture: aya.render.TextureHandle, quad: Quad, mat: Mat32, color: Color) void {
        self.ensureCapacity(texture) catch |err| {
            std.debug.print("Batcher.draw failed to append a draw call with error: {}\n", .{err});
            return;
        };

        // copy the quad positions, uvs and color into vertex array transforming them with the matrix as we do it
        var verts = self.mesh.verts[self.vert_index .. self.vert_index + 4];
        mat.transformQuad(verts, quad, color);

        self.draw_calls.items[self.draw_calls.items.len - 1].quad_count += 1;
        self.quad_count += 1;
        self.vert_index += 4;
    }
};
