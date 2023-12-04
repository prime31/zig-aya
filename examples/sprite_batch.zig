const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya");
const wgpu = aya.wgpu;

const Vertex = extern struct {
    pos: [2]f32,
    uv: [2]f32,
};

var state: struct {
    mesh: DynamicMesh(u16, Vertex) = undefined,
    batcher: Batcher = undefined,
    texture: aya.TextureHandle,
    check_texture: aya.TextureHandle,
    tex_view: aya.TextureViewHandle,
    check_tex_view: aya.TextureViewHandle,
    sampler: aya.SamplerHandle,
    bind_group: aya.BindGroupHandle,
    pipeline: aya.RenderPipelineHandle,
} = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    var gctx = aya.gctx;
    state.mesh = createDynamicMesh(128);
    state.batcher = Batcher.init(128);

    // texture
    const image = @import("stb").Image.init(aya.mem.allocator, "examples/tree0.png") catch unreachable;
    defer image.deinit();

    const check_image = @import("stb").Image.init(aya.mem.allocator, "examples/checkbox.png") catch unreachable;
    defer check_image.deinit();

    state.texture = gctx.createTexture(image.w, image.h, aya.GraphicsContext.swapchain_format);
    state.check_texture = gctx.createTexture(check_image.w, check_image.h, aya.GraphicsContext.swapchain_format);

    gctx.writeTexture(state.texture, u8, image.getImageData());
    gctx.writeTexture(state.check_texture, u8, check_image.getImageData());

    // texture view
    state.tex_view = gctx.createTextureView(state.texture, &.{});
    state.check_tex_view = gctx.createTextureView(state.check_texture, &.{});

    // sampler
    state.sampler = gctx.createSampler(&.{});

    const bind_group_layout = gctx.createBindGroupLayout(&.{
        .label = "Bind Group",
        .entries = &.{
            .{ .visibility = .{ .fragment = true }, .texture = .{} },
            .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(bind_group_layout); // TODO: do we have to hold onto these?

    state.bind_group = gctx.createBindGroup(bind_group_layout, &.{
        .{ .texture_view_handle = state.tex_view },
        .{ .sampler_handle = state.sampler },
    });

    state.pipeline = gctx.createPipeline(&.{
        .source = @embedFile("quad.wgsl"),
        .vbuffers = &aya.gpu.vertexAttributesForType(Vertex).vertexBufferLayouts(),
    });
}

fn shutdown() !void {
    state.mesh.deinit();
    state.batcher.deinit();
}

fn update() !void {
    // const ticks = @as(f32, @floatFromInt(aya.sdl.SDL_GetTicks()));
    // const x = @sin(ticks / 1000);
    // drawTex(state.texture, x, -0.9);
}

fn render() !void {
    const vb_info = aya.gctx.lookupResourceInfo(state.mesh.vbuff) orelse return;
    const ib_info = aya.gctx.lookupResourceInfo(state.mesh.ibuff) orelse return;
    const bg = aya.gctx.lookupResource(state.bind_group) orelse return;
    const pip = aya.gctx.lookupResource(state.pipeline) orelse return;

    // get the current texture view for the swap chain
    var surface_texture: wgpu.SurfaceTexture = undefined;
    aya.gctx.surface.getCurrentTexture(&surface_texture);
    defer if (surface_texture.texture) |t| t.release();

    switch (surface_texture.status) {
        .success => {},
        .timeout, .outdated, .lost => {
            const size = aya.window.sizeInPixels();
            aya.gctx.resize(size.w, size.h);
            return;
        },
        .out_of_memory, .device_lost => {
            std.debug.print("shits gone down: {}\n", .{surface_texture.status});
            @panic("unhandled surface texture status!");
        },
    }

    const texture_view = surface_texture.texture.?.createView(null);
    defer texture_view.release();

    var command_encoder = aya.gctx.device.createCommandEncoder(&.{ .label = "Command Encoder" });

    // begin the render pass
    var pass = command_encoder.beginRenderPass(&.{
        .label = "Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = texture_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
    });

    pass.setVertexBuffer(0, vb_info.gpuobj.?, 0, vb_info.size);
    pass.setIndexBuffer(ib_info.gpuobj.?, .uint16, 0, ib_info.size);
    pass.setPipeline(pip);
    pass.setBindGroup(0, bg, 0, null);
    pass.drawIndexed(6, 1, 0, 0, 0);

    state.batcher.begin(pass);
    state.batcher.drawTex(.{ .x = 50 }, 0, state.check_texture);
    state.batcher.drawTex(.{}, 0, state.texture);
    state.batcher.drawTex(.{ .x = 150 }, 0, state.check_texture);
    state.batcher.drawTex(.{ .y = 100 }, 0, state.texture);
    state.batcher.end();

    pass.end();
    pass.release();

    var command_buffer = command_encoder.finish(&.{ .label = "Command buffer" });
    aya.gctx.submit(&.{command_buffer});
    aya.gctx.surface.present();
}

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
            var ibuff = aya.gctx.createBufferInit(null, .{ .copy_dst = true, .index = true }, IndexT, indices);
            var vbuff = aya.gctx.createBuffer(&.{
                .usage = .{ .copy_dst = true, .vertex = true },
                .size = vertex_count * @sizeOf(VertT),
            });
            aya.gctx.lookupResource(vbuff).?.unmap();

            return Self{
                .ibuff = ibuff,
                .vbuff = vbuff, //aya.BufferHandle.nil,
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
            // std.debug.print("--- --- writeBuffer. start: {}, self.buffer_offset: {}\n", .{ start_index, self.buffer_offset });
            self.buffer_offset += @intCast(vert_slice.len * @sizeOf(VertT));
        }
    };
}

fn createDynamicMesh(max_sprites: u16) DynamicMesh(u16, Vertex) {
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

pub fn drawTex(texture: aya.TextureHandle, x: f32, y: f32) void {
    _ = texture;

    var verts = state.mesh.verts[0..4];
    verts[0] = .{ .pos = .{ x, 0.9 }, .uv = .{ 0.0, 0.0 } }; // tl
    verts[1] = .{ .pos = .{ x + 1.8, 0.9 }, .uv = .{ 1.0, 0.0 } }; // tr
    verts[2] = .{ .pos = .{ x + 1.8, y }, .uv = .{ 1.0, 1.0 } }; // br
    verts[3] = .{ .pos = .{ x, y }, .uv = .{ 0.0, 1.0 } }; // bl
    state.mesh.updateAllVerts();
}

const Vec2 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
};

const Vertex2 = extern struct {
    pos: Vec2,
    uv: Vec2,
};

pub const Batcher = struct {
    mesh: DynamicMesh(u16, Vertex2),
    draw_calls: std.ArrayList(DrawCall),

    begin_called: bool = false,
    frame: u32 = 0, // tracks when a batch is started in a new frame so that state can be reset
    vert_index: usize = 0, // current index into the vertex array
    quad_count: usize = 0, // total quads that we have not yet rendered
    buffer_offset: i32 = 0, // offset into the vertex buffer of the first non-rendered vert
    pass: ?wgpu.RenderPassEncoder = null,

    const DrawCall = struct {
        image: aya.TextureHandle,
        quad_count: i32,
    };

    fn _createDynamicMesh(max_sprites: u16) DynamicMesh(u16, Vertex2) {
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

        return DynamicMesh(u16, Vertex2).init(max_sprites * 4, indices);
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
        std.debug.assert(!self.begin_called);

        self.pass = pass;

        // reset all state for new frame
        // if (self.frame != aya.time.frames()) {
        //     self.frame = aya.time.frames();
        //     self.vert_index = 0;
        //     self.buffer_offset = 0;
        // }
        if (true) {
            self.vert_index = 0;
            self.buffer_offset = 0;
            self.mesh.buffer_offset = 0;
        }

        self.begin_called = true;
    }

    pub fn end(self: *Batcher) void {
        std.debug.assert(self.begin_called);
        self.flush();
        self.begin_called = false;
        self.pass = null;
    }

    /// should be called when any graphics state change will occur such as setting a new shader or RenderState
    pub fn flush(self: *Batcher) void {
        if (self.quad_count == 0) return;
        const pass = self.pass orelse return;

        const vbuff = aya.gctx.lookupResourceInfo(self.mesh.vbuff) orelse return;
        const ibuff = aya.gctx.lookupResourceInfo(self.mesh.ibuff) orelse return;
        const bg = aya.gctx.lookupResource(state.bind_group) orelse return;
        _ = bg;

        pass.setVertexBuffer(0, vbuff.gpuobj.?, self.mesh.buffer_offset, vbuff.size);
        pass.setIndexBuffer(ibuff.gpuobj.?, .uint16, 0, ibuff.size);
        // pass.setPipeline(pip);

        self.mesh.appendVertSlice(@as(usize, @intCast(self.buffer_offset)), @as(usize, @intCast(self.quad_count * 4)));

        // run through all our accumulated draw calls
        var base_element: i32 = 0;
        for (self.draw_calls.items) |*draw_call| {
            const tex_view = aya.gctx.createTextureView(draw_call.image, &.{});
            defer aya.gctx.releaseResource(tex_view);

            const bind_group_layout = aya.gctx.createBindGroupLayout(&.{
                .entries = &.{
                    .{ .visibility = .{ .fragment = true }, .texture = .{} },
                    .{ .visibility = .{ .fragment = true }, .sampler = .{} },
                },
            });
            defer aya.gctx.releaseResource(bind_group_layout);

            const bgg = aya.gctx.createBindGroup(bind_group_layout, &.{
                .{ .texture_view_handle = tex_view },
                .{ .sampler_handle = aya.gctx.createSampler(&.{}) },
            });
            // defer aya.gctx.releaseResource(bgg);

            const bggg = aya.gctx.lookupResource(bgg) orelse return;

            pass.setBindGroup(0, bggg, 0, null);
            pass.drawIndexed(@intCast(draw_call.quad_count * 6), 1, @intCast(base_element), 0, 0);

            // pass_encoder.drawIndexed(6, 1, 0, 0, 0);
            // drawIndexed(index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32)
            // self.mesh.draw(base_element, draw_call.quad_count * 6);
            // renderkit.draw(base_element, element_count, 1);

            self.buffer_offset += draw_call.quad_count * 4;
            draw_call.image = aya.TextureHandle.nil;
            base_element += draw_call.quad_count * 6;
        }

        self.quad_count = 0;
        self.draw_calls.items.len = 0;
    }

    /// ensures the vert buffer has enough space and manages the draw call command buffer when textures change
    fn ensureCapacity(self: *Batcher, texture: aya.TextureHandle) !void {
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

    pub fn drawTex(self: *Batcher, pos: Vec2, col: u32, texture: aya.TextureHandle) void {
        _ = col;
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
        // verts[0].col = col;

        verts[1].pos = .{ .x = pos.x + tex_width, .y = pos.y }; // tr
        verts[1].uv = .{ .x = 1, .y = 0 };
        // verts[1].col = col;

        verts[2].pos = .{ .x = pos.x + tex_width, .y = pos.y + tex_height }; // br
        verts[2].uv = .{ .x = 1, .y = 1 };
        // verts[2].col = col;

        verts[3].pos = .{ .x = pos.x, .y = pos.y + tex_height }; // bl
        verts[3].uv = .{ .x = 0, .y = 1 };
        // verts[3].col = col;

        self.draw_calls.items[self.draw_calls.items.len - 1].quad_count += 1;
        self.quad_count += 1;
        self.vert_index += 4;

        // TODO: lol
        const win_size = aya.window.sizeInPixels();
        var proj_mat = Mat32.initOrtho(@as(f32, @floatFromInt(win_size.w)), @as(f32, @floatFromInt(win_size.h)));
        proj_mat.transformVertex2Slice(verts);

        // const x = -0.9;
        // const y = -0.9;
        // verts[0] = .{ .pos = .{ .x = x, .y = 0.9 }, .uv = .{ .x = 0.0, .y = 0.0 } }; // tl
        // verts[1] = .{ .pos = .{ .x = x + 1.8, .y = 0.9 }, .uv = .{ .x = 1.0, .y = 0.0 } }; // tr
        // verts[2] = .{ .pos = .{ .x = x + 1.8, .y = y }, .uv = .{ .x = 1.0, .y = 1.0 } }; // br
        // verts[3] = .{ .pos = .{ .x = x, .y = y }, .uv = .{ .x = 0.0, .y = 1.0 } }; // bl
    }

    pub fn draw(self: *Batcher, texture: aya.TextureHandle, quad: Quad, mat: Mat32, color: Color) void {
        self.ensureCapacity(texture) catch |err| {
            std.debug.print("Batcher.draw failed to append a draw call with error: {}\n", .{err});
            return;
        };

        // copy the quad positions, uvs and color into vertex array transforming them with the matrix as we do it
        mat.transformQuad(self.mesh.verts[self.vert_index .. self.vert_index + 4], quad, color);

        self.draw_calls.items[self.draw_calls.items.len - 1].quad_count += 1;
        self.quad_count += 1;
        self.vert_index += 4;
    }
};

pub const Quad = struct {
    img_w: f32,
    img_h: f32,
    positions: [4]Vec2 = undefined,
    uvs: [4]Vec2 = undefined,

    pub fn init(x: f32, y: f32, width: f32, height: f32, img_w: f32, img_h: f32) Quad {
        var q = Quad{
            .img_w = img_w,
            .img_h = img_h,
        };
        q.setViewport(x, y, width, height);

        return q;
    }

    pub fn setViewportRect(self: *Quad, viewport: Rect) void {
        self.setViewport(viewport.x, viewport.y, viewport.w, viewport.h);
    }

    pub fn setViewportRectI(self: *Quad, viewport: RectI) void {
        self.setViewport(@as(f32, @floatFromInt(viewport.x)), @as(f32, @floatFromInt(viewport.y)), @as(f32, @floatFromInt(viewport.w)), @as(f32, @floatFromInt(viewport.h)));
    }

    pub fn setViewport(self: *Quad, x: f32, y: f32, width: f32, height: f32) void {
        self.positions[0] = Vec2{ .x = 0, .y = 0 }; // tl
        self.positions[1] = Vec2{ .x = width, .y = 0 }; // tr
        self.positions[2] = Vec2{ .x = width, .y = height }; // br
        self.positions[3] = Vec2{ .x = 0, .y = height }; // bl

        // squeeze texcoords in by 128th of a pixel to avoid bleed
        const w_tol = (1.0 / self.img_w) / 128.0;
        const h_tol = (1.0 / self.img_h) / 128.0;

        const inv_w = 1.0 / self.img_w;
        const inv_h = 1.0 / self.img_h;

        self.uvs[0] = Vec2{ .x = x * inv_w + w_tol, .y = y * inv_h + h_tol };
        self.uvs[1] = Vec2{ .x = (x + width) * inv_w - w_tol, .y = y * inv_h + h_tol };
        self.uvs[2] = Vec2{ .x = (x + width) * inv_w - w_tol, .y = (y + height) * inv_h - h_tol };
        self.uvs[3] = Vec2{ .x = x * inv_w + w_tol, .y = (y + height) * inv_h - h_tol };
    }

    /// sets the Quad to be the full size of the texture
    pub fn setFill(self: *Quad, img_w: f32, img_h: f32) void {
        self.setImageDimensions(img_w, img_h);
        self.setViewport(0, 0, img_w, img_h);
    }

    pub fn setImageDimensions(self: *Quad, w: f32, h: f32) void {
        self.img_w = w;
        self.img_h = h;
    }
};

pub const Rect = struct {
    x: f32 = 0,
    y: f32 = 0,
    w: f32 = 0,
    h: f32 = 0,

    pub fn right(self: Rect) f32 {
        return self.x + self.w;
    }

    pub fn left(self: Rect) f32 {
        return self.x;
    }

    pub fn top(self: Rect) f32 {
        return self.y;
    }

    pub fn bottom(self: Rect) f32 {
        return self.y + self.h;
    }

    pub fn center(self: Rect) Vec2 {
        return .{ .x = self.x + self.w / 2, .y = self.y + self.h / 2 };
    }

    pub fn contains(self: Rect, x: f32, y: f32) bool {
        return self.x <= x and x < self.right() and self.y <= y and y < self.bottom();
    }

    pub fn intersects(self: Rect, other: Rect) bool {
        return other.left() < self.right() and self.left() < other.right() and
            other.top() < self.bottom() and self.top() < other.bottom();
    }

    pub fn contract(self: Rect, horiz: f32, vert: f32) Rect {
        var rect = self;
        rect.x += horiz;
        rect.y += vert;
        rect.w -= horiz * 2;
        rect.h -= vert * 2;
        return rect;
    }

    pub fn expand(self: Rect, horiz: f32, vert: f32) Rect {
        return self.contract(-horiz, -vert);
    }

    pub fn unionRect(self: Rect, r2: Rect) Rect {
        var res = Rect{};
        res.x = @min(self.x, r2.x);
        res.y = @min(self.y, r2.y);
        res.w = @max(self.right(), r2.right()) - res.x;
        res.h = @max(self.bottom(), r2.bottom()) - res.y;
        return res;
    }
};

pub const RectI = struct {
    x: i32 = 0,
    y: i32 = 0,
    w: i32 = 0,
    h: i32 = 0,

    pub fn init(x: i32, y: i32, w: i32, h: i32) RectI {
        return .{ .x = x, .y = y, .w = w, .h = h };
    }

    pub fn right(self: RectI) i32 {
        return self.x + self.w;
    }

    pub fn left(self: RectI) i32 {
        return self.x;
    }

    pub fn top(self: RectI) i32 {
        return self.y;
    }

    pub fn bottom(self: RectI) i32 {
        return self.y + self.h;
    }

    pub fn centerX(self: RectI) i32 {
        return self.x + @divTrunc(self.w, 2);
    }

    pub fn centerY(self: RectI) i32 {
        return self.y + @divTrunc(self.h, 2);
    }

    pub fn contract(self: *RectI, horiz: i32, vert: i32) void {
        self.x += horiz;
        self.y += vert;
        self.w -= horiz * 2;
        self.h -= vert * 2;
    }

    pub fn contains(self: RectI, x: i32, y: i32) bool {
        return self.x <= x and x < self.right() and self.y <= y and y < self.bottom();
    }

    pub fn unionRect(self: RectI, r2: RectI) RectI {
        var res = RectI{};
        res.x = @min(self.x, r2.x);
        res.y = @min(self.y, r2.y);
        res.w = @max(self.right(), r2.right()) - res.x;
        res.h = @max(self.bottom(), r2.bottom()) - res.y;
        return res;
    }

    pub fn unionPoint(self: RectI, x: i32, y: i32) RectI {
        return self.unionRect(.{ .x = x, .y = y });
    }
};

pub const Mat32 = struct {
    data: [6]f32 = undefined,

    pub const TransformParams = struct { x: f32 = 0, y: f32 = 0, angle: f32 = 0, sx: f32 = 1, sy: f32 = 1, ox: f32 = 0, oy: f32 = 0 };

    pub const identity = Mat32{ .data = .{ 1, 0, 0, 1, 0, 0 } };
    pub const zero = Mat32{ .data = .{ 0, 0, 0, 0, 0, 0 } };

    pub fn format(self: Mat32, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        return writer.print("{d:0.6}, {d:0.6}, {d:0.6}, {d:0.6}, {d:0.6}, {d:0.6}", .{ self.data[0], self.data[1], self.data[2], self.data[3], self.data[4], self.data[5] });
    }

    pub fn init() Mat32 {
        return identity;
    }

    pub fn initTransform(vals: TransformParams) Mat32 {
        var mat = Mat32{};
        mat.setTransform(vals);
        return mat;
    }

    pub fn initOrthoInverted(width: f32, height: f32) Mat32 {
        var result = zero;
        result.data[0] = 2 / width;
        result.data[3] = 2 / height;
        result.data[4] = -1;
        result.data[5] = -1;
        return result;
    }

    pub fn initOrtho(width: f32, height: f32) Mat32 {
        var result = zero;
        result.data[0] = 2 / width;
        result.data[3] = -2 / height;
        result.data[4] = -1;
        result.data[5] = 1;
        return result;
    }

    pub fn initOrthoOffCenter(width: f32, height: f32) Mat32 {
        const half_w = @ceil(width / 2);
        const half_h = @ceil(height / 2);

        var result = identity;
        result.data[0] = 2.0 / (half_w + half_w);
        result.data[3] = 2.0 / (-half_h - half_h);
        result.data[4] = (-half_w + half_w) / (-half_w - half_w);
        result.data[5] = (half_h - half_h) / (half_h + half_h);
        return result;
    }

    pub fn setTransform(self: *Mat32, vals: TransformParams) void {
        const c = @cos(vals.angle);
        const s = @sin(vals.angle);

        // matrix multiplication carried out on paper:
        // |1    x| |c -s  | |sx     | |1   -ox|
        // |  1  y| |s  c  | |   sy  | |  1 -oy|
        //   move    rotate    scale     origin
        self.data[0] = c * vals.sx;
        self.data[1] = s * vals.sx;
        self.data[2] = -s * vals.sy;
        self.data[3] = c * vals.sy;
        self.data[4] = vals.x - vals.ox * self.data[0] - vals.oy * self.data[2];
        self.data[5] = vals.y - vals.ox * self.data[1] - vals.oy * self.data[3];
    }

    pub fn invert(self: Mat32) Mat32 {
        var res = Mat32{};
        var det = 1 / (self.data[0] * self.data[3] - self.data[1] * self.data[2]);

        res.data[0] = self.data[3] * det;
        res.data[1] = -self.data[1] * det;

        res.data[2] = -self.data[2] * det;
        res.data[3] = self.data[0] * det;

        res.data[4] = (self.data[5] * self.data[2] - self.data[4] * self.data[3]) * det;
        res.data[5] = -(self.data[5] * self.data[0] - self.data[4] * self.data[1]) * det;

        return res;
    }

    pub fn mul(self: Mat32, r: Mat32) Mat32 {
        var result = Mat32{};
        result.data[0] = self.data[0] * r.data[0] + self.data[2] * r.data[1];
        result.data[1] = self.data[1] * r.data[0] + self.data[3] * r.data[1];
        result.data[2] = self.data[0] * r.data[2] + self.data[2] * r.data[3];
        result.data[3] = self.data[1] * r.data[2] + self.data[3] * r.data[3];
        result.data[4] = self.data[0] * r.data[4] + self.data[2] * r.data[5] + self.data[4];
        result.data[5] = self.data[1] * r.data[4] + self.data[3] * r.data[5] + self.data[5];
        return result;
    }

    pub fn translate(self: *Mat32, x: f32, y: f32) void {
        self.data[4] = self.data[0] * x + self.data[2] * y + self.data[4];
        self.data[5] = self.data[1] * x + self.data[3] * y + self.data[5];
    }

    pub fn rotate(self: *Mat32, rads: f32) void {
        const cos = @cos(rads);
        const sin = @sin(rads);

        const nm0 = self.data[0] * cos + self.data[2] * sin;
        const nm1 = self.data[1] * cos + self.data[3] * sin;

        self.data[2] = self.data[0] * -sin + self.data[2] * cos;
        self.data[3] = self.data[1] * -sin + self.data[3] * cos;
        self.data[0] = nm0;
        self.data[1] = nm1;
    }

    pub fn scale(self: *Mat32, x: f32, y: f32) void {
        self.data[0] *= x;
        self.data[1] *= x;
        self.data[2] *= y;
        self.data[3] *= y;
    }

    pub fn transformVec2(self: Mat32, pos: Vec2) Vec2 {
        return .{
            .x = pos.x * self.data[0] + pos.y * self.data[2] + self.data[4],
            .y = pos.x * self.data[1] + pos.y * self.data[3] + self.data[5],
        };
    }

    pub fn transformVec2Slice(self: Mat32, comptime T: type, dst: []T, src: []Vec2) void {
        for (src, 0..) |_, i| {
            const x = src[i].x * self.data[0] + src[i].y * self.data[2] + self.data[4];
            const y = src[i].x * self.data[1] + src[i].y * self.data[3] + self.data[5];
            dst[i].x = x;
            dst[i].y = y;
        }
    }

    /// transforms the positions in Quad and copies them to dst along with the uvs and color. This could be made generic
    /// if we have other common Vertex types
    pub fn transformQuad(self: Mat32, dst: []Vertex, quad: Quad, color: Color) void {
        for (dst, 0..) |*item, i| {
            item.*.pos.x = quad.positions[i].x * self.data[0] + quad.positions[i].y * self.data[2] + self.data[4];
            item.*.pos.y = quad.positions[i].x * self.data[1] + quad.positions[i].y * self.data[3] + self.data[5];
            item.*.uv = quad.uvs[i];
            item.*.col = color.value;
        }
    }

    pub fn transformVertexSlice(self: Mat32, dst: []Vertex) void {
        for (dst, 0..) |_, i| {
            const x = dst[i].pos.x * self.data[0] + dst[i].pos.y * self.data[2] + self.data[4];
            const y = dst[i].pos.x * self.data[1] + dst[i].pos.y * self.data[3] + self.data[5];

            // we defer setting because src and dst are the same
            dst[i].pos.x = x;
            dst[i].pos.y = y;
        }
    }

    pub fn transformVertex2Slice(self: Mat32, dst: []Vertex2) void {
        for (dst, 0..) |_, i| {
            const x = dst[i].pos.x * self.data[0] + dst[i].pos.y * self.data[2] + self.data[4];
            const y = dst[i].pos.x * self.data[1] + dst[i].pos.y * self.data[3] + self.data[5];

            // we defer setting because src and dst are the same
            dst[i].pos.x = x;
            dst[i].pos.y = y;
        }
    }
};

pub const Color = extern union {
    value: u32,
    comps: extern struct {
        r: u8,
        g: u8,
        b: u8,
        a: u8,
    },

    /// parses a hex string color literal.
    /// allowed formats are:
    /// - `RGB`
    /// - `RGBA`
    /// - `#RGB`
    /// - `#RGBA`
    /// - `RRGGBB`
    /// - `#RRGGBB`
    /// - `RRGGBBAA`
    /// - `#RRGGBBAA`
    pub fn parse(comptime str: []const u8) !Color {
        switch (str.len) {
            // RGB
            3 => {
                const r = try std.fmt.parseInt(u8, str[0..1], 16);
                const g = try std.fmt.parseInt(u8, str[1..2], 16);
                const b = try std.fmt.parseInt(u8, str[2..3], 16);

                return fromBytes(
                    r | (r << 4),
                    g | (g << 4),
                    b | (b << 4),
                );
            },

            // #RGB, RGBA
            4 => {
                if (str[0] == '#')
                    return parse(str[1..]);

                const r = try std.fmt.parseInt(u8, str[0..1], 16);
                const g = try std.fmt.parseInt(u8, str[1..2], 16);
                const b = try std.fmt.parseInt(u8, str[2..3], 16);
                const a = try std.fmt.parseInt(u8, str[3..4], 16);

                // bit-expand the patters to a uniform range
                return fromBytes(
                    r | (r << 4),
                    g | (g << 4),
                    b | (b << 4),
                    a | (a << 4),
                );
            },

            // #RGBA
            5 => return parse(str[1..]),

            // RRGGBB
            6 => {
                const r = try std.fmt.parseInt(u8, str[0..2], 16);
                const g = try std.fmt.parseInt(u8, str[2..4], 16);
                const b = try std.fmt.parseInt(u8, str[4..6], 16);

                return fromBytes(r, g, b, 255);
            },

            // #RRGGBB
            7 => return parse(str[1..]),

            // RRGGBBAA
            8 => {
                const r = try std.fmt.parseInt(u8, str[0..2], 16);
                const g = try std.fmt.parseInt(u8, str[2..4], 16);
                const b = try std.fmt.parseInt(u8, str[4..6], 16);
                const a = try std.fmt.parseInt(u8, str[6..8], 16);

                return fromBytes(r, g, b, a);
            },

            // #RRGGBBAA
            9 => return parse(str[1..]),

            else => return error.UnknownFormat,
        }
    }

    pub fn fromBytes(r: u8, g: u8, b: u8, a: u8) Color {
        return .{ .value = (r) | (@as(u32, g) << 8) | (@as(u32, b) << 16) | (@as(u32, a) << 24) };
    }

    pub fn fromRgbBytes(r: u8, g: u8, b: u8) Color {
        return fromBytes(r, g, b, 255);
    }

    pub fn fromRgb(r: f32, g: f32, b: f32) Color {
        return fromBytes(@as(u8, @intFromFloat(@round(r * 255))), @as(u8, @intFromFloat(@round(g * 255))), @as(u8, @intFromFloat(@round(b * 255))), @as(u8, 255));
    }

    pub fn fromRgba(r: f32, g: f32, b: f32, a: f32) Color {
        return fromBytes(@as(u8, @intFromFloat(@round(r * 255))), @as(u8, @intFromFloat(@round(g * 255))), @as(u8, @intFromFloat(@round(b * 255))), @as(u8, @intFromFloat(@round(a * 255))));
    }

    pub fn fromI32(r: i32, g: i32, b: i32, a: i32) Color {
        return fromBytes(@as(u8, @truncate(@as(u32, @intCast(r)))), @as(u8, @truncate(@as(u32, @intCast(g)))), @as(u8, @truncate(@as(u32, @intCast(b)))), @as(u8, @truncate(@as(u32, @intCast(a)))));
    }

    pub fn r_val(self: Color) u8 {
        return @as(u8, @truncate(self.value));
    }

    pub fn g_val(self: Color) u8 {
        return @as(u8, @truncate(self.value >> 8));
    }

    pub fn b_val(self: Color) u8 {
        return @as(u8, @truncate(self.value >> 16));
    }

    pub fn a_val(self: Color) u8 {
        return @as(u8, @truncate(self.value >> 24));
    }

    pub fn set_r(self: *Color, r: u8) void {
        self.value = (self.value & 0xffffff00) | r;
    }

    pub fn set_g(self: *Color, g: u8) void {
        self.value = (self.value & 0xffff00ff) | g;
    }

    pub fn set_b(self: *Color, b: u8) void {
        self.value = (self.value & 0xff00ffff) | b;
    }

    pub fn set_a(self: *Color, a: u8) void {
        self.value = (self.value & 0x00ffffff) | a;
    }

    pub fn asArray(self: Color) [4]f32 {
        return [_]f32{
            @as(f32, @floatFromInt(self.comps.r)) / 255,
            @as(f32, @floatFromInt(self.comps.g)) / 255,
            @as(f32, @floatFromInt(self.comps.b)) / 255,
            @as(f32, @floatFromInt(self.comps.a)) / 255,
        };
    }

    pub fn scale(self: Color, s: f32) Color {
        const r = @as(i32, @intFromFloat(@as(f32, @floatFromInt(self.r_val())) * s));
        const g = @as(i32, @intFromFloat(@as(f32, @floatFromInt(self.g_val())) * s));
        const b = @as(i32, @intFromFloat(@as(f32, @floatFromInt(self.b_val())) * s));
        const a = @as(i32, @intFromFloat(@as(f32, @floatFromInt(self.a_val())) * s));
        return fromI32(r, g, b, a);
    }

    pub const white = Color{ .value = 0xFFFFFFFF };
    pub const black = Color{ .value = 0xFF000000 };
    pub const transparent = Color{ .comps = .{ .r = 0, .g = 0, .b = 0, .a = 0 } };
    pub const aya = Color{ .comps = .{ .r = 204, .g = 51, .b = 77, .a = 255 } };
    pub const light_gray = Color{ .comps = .{ .r = 200, .g = 200, .b = 200, .a = 255 } };
    pub const gray = Color{ .comps = .{ .r = 130, .g = 130, .b = 130, .a = 255 } };
    pub const dark_gray = Color{ .comps = .{ .r = 80, .g = 80, .b = 80, .a = 255 } };
    pub const yellow = Color{ .comps = .{ .r = 253, .g = 249, .b = 0, .a = 255 } };
    pub const gold = Color{ .comps = .{ .r = 255, .g = 203, .b = 0, .a = 255 } };
    pub const orange = Color{ .comps = .{ .r = 255, .g = 161, .b = 0, .a = 255 } };
    pub const pink = Color{ .comps = .{ .r = 255, .g = 109, .b = 194, .a = 255 } };
    pub const red = Color{ .comps = .{ .r = 230, .g = 41, .b = 55, .a = 255 } };
    pub const maroon = Color{ .comps = .{ .r = 190, .g = 33, .b = 55, .a = 255 } };
    pub const green = Color{ .comps = .{ .r = 0, .g = 228, .b = 48, .a = 255 } };
    pub const lime = Color{ .comps = .{ .r = 0, .g = 158, .b = 47, .a = 255 } };
    pub const dark_green = Color{ .comps = .{ .r = 0, .g = 117, .b = 44, .a = 255 } };
    pub const sky_blue = Color{ .comps = .{ .r = 102, .g = 191, .b = 255, .a = 255 } };
    pub const blue = Color{ .comps = .{ .r = 0, .g = 121, .b = 241, .a = 255 } };
    pub const dark_blue = Color{ .comps = .{ .r = 0, .g = 82, .b = 172, .a = 255 } };
    pub const purple = Color{ .comps = .{ .r = 200, .g = 122, .b = 255, .a = 255 } };
    pub const voilet = Color{ .comps = .{ .r = 135, .g = 60, .b = 190, .a = 255 } };
    pub const dark_purple = Color{ .comps = .{ .r = 112, .g = 31, .b = 126, .a = 255 } };
    pub const beige = Color{ .comps = .{ .r = 211, .g = 176, .b = 131, .a = 255 } };
    pub const brown = Color{ .comps = .{ .r = 127, .g = 106, .b = 79, .a = 255 } };
    pub const dark_brown = Color{ .comps = .{ .r = 76, .g = 63, .b = 47, .a = 255 } };
    pub const magenta = Color{ .comps = .{ .r = 255, .g = 0, .b = 255, .a = 255 } };
};
