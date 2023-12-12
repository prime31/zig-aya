const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya");
const wgpu = aya.wgpu;
const gpu = aya.gpu;

const Mat32 = aya.math.Mat32;

const Vertex = extern struct {
    position: [2]f32,
    uv: [2]f32,
    color: u32 = 0xFFFFFFFF,
};

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

var state: struct {
    vbuff: aya.render.BufferHandle,
    ibuff: aya.render.BufferHandle,
    texture: aya.render.TextureHandle,
    tex_view: aya.render.TextureViewHandle,
    sampler: aya.render.SamplerHandle,
    frame_bind_group: aya.render.BindGroupHandle,
    textures_bind_group: aya.render.BindGroupHandle,
    pipeline: aya.render.RenderPipelineHandle,
} = undefined;

pub fn init() !void {
    var gctx = aya.gctx;

    // vertex buffer
    const vertex_data = [_]Vertex{
        .{ .position = .{ 0, 0 }, .uv = .{ 0.0, 0.0 } }, // tl
        .{ .position = .{ 256, 0 }, .uv = .{ 1.0, 0.0 } }, // tr
        .{ .position = .{ 256, 256 }, .uv = .{ 1.0, 1.0 } }, // br
        .{ .position = .{ 0, 256 }, .uv = .{ 0.0, 1.0 } }, // bl
    };
    state.vbuff = gctx.createBufferInit(null, .{ .copy_dst = true, .vertex = true }, Vertex, &vertex_data);

    // index buffer
    const index_data = [_]u16{ 0, 1, 3, 1, 2, 3 };
    state.ibuff = gctx.createBufferInit(null, .{ .copy_dst = true, .index = true }, u16, &index_data);

    // texture
    state.texture = gctx.createTextureFromFile("examples/assets/burned.png");

    // texture view
    state.tex_view = gctx.createTextureView(state.texture, &.{});

    // sampler
    state.sampler = gctx.createSampler(&.{});

    // bind groups
    const bind_group_layout0 = gctx.createBindGroupLayout(&.{
        .label = "Uniform Bind Group",
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = true } },
        },
    });
    defer gctx.releaseResource(bind_group_layout0);

    const bind_group_layout1 = gctx.createBindGroupLayout(&.{
        .label = "Texture Bind Group",
        .entries = &.{
            .{ .visibility = .{ .fragment = true }, .texture = .{} },
            .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(bind_group_layout1);

    state.frame_bind_group = gctx.createBindGroup(bind_group_layout0, &.{
        .{ .buffer_handle = gctx.uniforms.buffer, .size = 256 },
    });

    state.textures_bind_group = gctx.createBindGroup(bind_group_layout1, &.{
        .{ .texture_view_handle = state.tex_view },
        .{ .sampler_handle = state.sampler },
    });

    state.pipeline = gctx.createPipeline(&.{
        .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/quad.wgsl") catch unreachable,
        .vbuffers = &gpu.vertexAttributesForType(Vertex).vertexBufferLayouts(),
        .bgls = &.{ gctx.lookupResource(bind_group_layout0).?, gctx.lookupResource(bind_group_layout1).? },
    });
}

pub fn render(ctx: *aya.render.RenderContext) !void {
    var gctx = aya.gctx;

    // begin the render pass
    const vb_info = gctx.lookupResourceInfo(state.vbuff) orelse return;
    const ib_info = gctx.lookupResourceInfo(state.ibuff) orelse return;
    const frame_bg = gctx.lookupResource(state.frame_bind_group) orelse return;
    const textures_bg = gctx.lookupResource(state.textures_bind_group) orelse return;
    const pip = gctx.lookupResource(state.pipeline) orelse return;

    var pass = ctx.beginRenderPass(&.{
        .label = "Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = ctx.swapchain_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.4, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
    });

    defer {
        pass.end();
        pass.release();
    }

    pass.setVertexBuffer(0, vb_info.gpuobj.?, 0, vb_info.size);
    pass.setIndexBuffer(ib_info.gpuobj.?, .uint16, 0, ib_info.size);
    pass.setPipeline(pip);

    // projection matrix uniform
    {
        const win_size = aya.window.sizeInPixels();

        const mem = aya.gctx.uniforms.allocate(Mat32, 1);
        mem.slice[0] = Mat32.initOrtho(@as(f32, @floatFromInt(win_size.w)), @as(f32, @floatFromInt(win_size.h)));
        pass.setBindGroup(0, frame_bg, &.{mem.offset});
    }

    pass.setBindGroup(1, textures_bg, null);
    pass.drawIndexed(6, 1, 0, 0, 0);
}

pub fn shutdown() !void {
    aya.gctx.destroyResource(state.vbuff);
    aya.gctx.destroyResource(state.ibuff);
    aya.gctx.destroyResource(state.texture);
    // aya.gctx.releaseResource(state.tex_view); // TODO: why does this crash with "Cannot remove a vacant resource"
    aya.gctx.releaseResource(state.sampler);
    aya.gctx.releaseResource(state.textures_bind_group);
    aya.gctx.releaseResource(state.pipeline);
}
