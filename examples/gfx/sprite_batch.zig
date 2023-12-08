const std = @import("std");
const sdl = @import("sdl");
const aya = @import("aya");
const wgpu = aya.wgpu;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Quad = aya.math.Quad;
const Rect = aya.math.Rect;
const RectI = aya.math.RectI;
const Color = aya.math.Color;

const Batcher = aya.render.Batcher;

var state: struct {
    batcher: Batcher = undefined,
    texture: aya.render.TextureHandle,
    check_texture: aya.render.TextureHandle,
    tex_view: aya.render.TextureViewHandle,
    check_tex_view: aya.render.TextureViewHandle,
    sampler: aya.render.SamplerHandle,
    pipeline: aya.render.RenderPipelineHandle,
    view_bind_group: aya.render.BindGroupHandle,
} = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    var gctx = aya.gctx;
    state.batcher = Batcher.init(128);

    // textures
    state.texture = gctx.createTextureFromFile("examples/assets/tree0.png");
    state.check_texture = gctx.createTextureFromFile("examples/assets/checkbox.png");

    // texture view
    state.tex_view = gctx.createTextureView(state.texture, &.{});
    state.check_tex_view = gctx.createTextureView(state.check_texture, &.{});

    // sampler
    state.sampler = gctx.createSampler(&.{});

    const bind_group_layout0 = gctx.createBindGroupLayout(&.{
        .label = "View Uniform Bind Group",
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = true } },
        },
    });
    defer gctx.releaseResource(bind_group_layout0);

    const bind_group_layout1 = gctx.createBindGroupLayout(&.{
        .label = "Bind Group",
        .entries = &.{
            .{ .visibility = .{ .fragment = true }, .texture = .{} },
            .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(bind_group_layout1);

    state.view_bind_group = gctx.createBindGroup(bind_group_layout0, &.{
        .{ .buffer_handle = gctx.uniforms.buffer, .size = 256 },
    });

    state.pipeline = gctx.createPipeline(&.{
        .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/quad.wgsl") catch unreachable,
        .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
        .bgls = &.{ gctx.lookupResource(bind_group_layout0).?, gctx.lookupResource(bind_group_layout1).? },
    });
}

fn shutdown() !void {
    state.batcher.deinit();
    aya.gctx.releaseResource(state.view_bind_group);
}

fn render(ctx: *aya.render.RenderContext) !void {
    const pip = aya.gctx.lookupResource(state.pipeline) orelse return;
    const bg = aya.gctx.lookupResource(state.view_bind_group) orelse return;

    // begin the render pass
    var pass = ctx.beginRenderPass(&.{
        .label = "Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = ctx.swapchain_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
    });

    pass.setPipeline(pip);

    // projection matrix uniform
    {
        const win_size = aya.window.sizeInPixels();

        const mem = aya.gctx.uniforms.allocate(Mat32, 1);
        mem.slice[0] = Mat32.initOrtho(@as(f32, @floatFromInt(win_size.w)), @as(f32, @floatFromInt(win_size.h)));
        pass.setBindGroup(0, bg, &.{mem.offset});
    }

    state.batcher.begin(pass);
    state.batcher.drawTex(.{ .x = 50 }, Color.blue.value, state.check_texture);
    state.batcher.drawTex(.{}, Color.red.value, state.texture);
    state.batcher.drawTex(.{ .x = 150 }, Color.white.value, state.check_texture);
    state.batcher.drawTex(.{ .x = 200 }, Color.white.value, state.check_texture);
    state.batcher.drawTex(.{ .x = 250 }, Color.white.value, state.check_texture);
    state.batcher.drawTex(.{ .y = 100 }, Color.white.value, state.texture);
    state.batcher.end();

    pass.end();
    pass.release();
}
