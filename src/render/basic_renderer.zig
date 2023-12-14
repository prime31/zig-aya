const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Quad = aya.math.Quad;
const Rect = aya.math.Rect;
const RectI = aya.math.RectI;
const Color = aya.math.Color;

const Draw = aya.render.Draw;
const Debug = @import("debug.zig").Debug;

const Uniform = extern struct {
    transform_matrix: Mat32,
};

pub const BasicRenderer = struct {
    draw: Draw,
    debug: Debug,
    pipeline: aya.render.RenderPipelineHandle,
    view_bind_group: aya.render.BindGroupHandle,
    pass: ?wgpu.RenderPassEncoder = null,

    pub fn init() BasicRenderer {
        const bind_group_layout0 = aya.gctx.createBindGroupLayout(&.{
            .label = "View Uniform Bind Group",
            .entries = &.{
                .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = .true } },
            },
        });
        defer aya.gctx.releaseResource(bind_group_layout0);

        const bind_group_layout1 = aya.gctx.createBindGroupLayout(&.{
            .label = "Bind Group",
            .entries = &.{
                .{ .visibility = .{ .fragment = true }, .texture = .{} },
                .{ .visibility = .{ .fragment = true }, .sampler = .{} },
            },
        });
        defer aya.gctx.releaseResource(bind_group_layout1);

        const view_bind_group = aya.gctx.createBindGroup(bind_group_layout0, &.{
            .{ .buffer_handle = aya.gctx.uniforms.buffer, .size = 256 },
        });

        const pipeline = aya.gctx.createPipeline(&.{
            .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/quad.wgsl") catch unreachable,
            .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
            .bgls = &.{ aya.gctx.lookupResource(bind_group_layout0).?, aya.gctx.lookupResource(bind_group_layout1).? },
        });

        return .{
            .draw = Draw.init(),
            .debug = Debug.init(),
            .pipeline = pipeline,
            .view_bind_group = view_bind_group,
        };
    }

    pub fn deinit(self: *BasicRenderer) void {
        self.draw.deinit();
        self.debug.deinit();
        aya.gctx.releaseResource(self.pipeline);
        aya.gctx.releaseResource(self.view_bind_group);
    }

    pub fn beginPass(self: *BasicRenderer, ctx: *aya.render.RenderContext, clear_color: ?Color, trans_mat: ?Mat32) void {
        const clear_value = if (clear_color) |cc| cc.asWgpuColor() else wgpu.Color{};
        const load_op: wgpu.LoadOp = if (clear_color != null) .clear else .load;

        self.pass = ctx.beginRenderPass(&.{
            .label = "BasicRenderer Pass",
            .color_attachment_count = 1,
            .color_attachments = &.{
                .view = ctx.swapchain_view,
                .load_op = load_op,
                .store_op = .store,
                .clear_value = clear_value,
            },
        });

        const pipeline = aya.gctx.lookupResource(self.pipeline) orelse return;
        const bg = aya.gctx.lookupResource(self.view_bind_group) orelse return;

        // set view uniform
        const win_size = aya.window.sizeInPixels();
        const mem = aya.gctx.uniforms.allocate(Uniform, 1);
        mem.slice[0] = .{
            .transform_matrix = Mat32.initOrtho(@as(f32, @floatFromInt(win_size.w)), @as(f32, @floatFromInt(win_size.h))),
        };
        // if we were given a transform matrix multiply it here
        if (trans_mat) |mat| {
            mem.slice[0].transform_matrix = mem.slice[0].transform_matrix.mul(mat);
        }

        self.pass.?.setBindGroup(0, bg, &.{mem.offset});
        self.pass.?.setPipeline(pipeline);

        self.draw.batcher.begin(self.pass.?);
    }

    pub fn endPass(self: *BasicRenderer) void {
        self.draw.batcher.end();

        const pass = self.pass orelse return;
        pass.end();
        pass.release();

        self.pass = null;
    }

    pub fn endFrame(self: *BasicRenderer) void {
        if (self.debug.debug_items.items.len == 0) return;
        const pass = self.pass orelse return;

        self.draw.batcher.begin(pass);
        _ = self.debug.render(&self.draw, true);
        self.draw.batcher.end();
    }
};
