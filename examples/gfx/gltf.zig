const std = @import("std");
const zmesh = @import("zmesh");
const aya = @import("aya");
const wgpu = aya.wgpu;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Quad = aya.math.Quad;
const Rect = aya.math.Rect;
const RectI = aya.math.RectI;
const Color = aya.math.Color;

const Uniform = extern struct {
    transform_matrix: Mat32,
};

var state: struct {
    pipeline: aya.render.RenderPipelineHandle,
    frame_bind_group: aya.render.BindGroupHandle,
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

    loadGltf();

    const bind_group_layout0 = gctx.createBindGroupLayout(&.{
        .label = "Frame BindGroupLayout", // Camera/Frame uniforms
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = true } },
        },
    });
    defer gctx.releaseResource(bind_group_layout0); // TODO: do we have to hold onto these?

    state.frame_bind_group = gctx.createBindGroup(bind_group_layout0, &.{
        .{ .buffer_handle = gctx.uniforms.buffer, .size = 256 },
    });

    const bind_group_layout1 = gctx.createBindGroupLayout(&.{
        .label = "Node BindGroupLayout", // Node uniforms
        .entries = &.{
            .{ .visibility = .{ .vertex = true }, .buffer = .{ .type = .uniform } },
            // .{ .visibility = .{ .fragment = true }, .texture = .{} },
            // .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(bind_group_layout1); // TODO: do we have to hold onto these?

    state.pipeline = gctx.createPipeline(&.{
        .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/gltf.wgsl") catch unreachable,
        .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
        .bgls = &.{ gctx.lookupResource(bind_group_layout0).?, gctx.lookupResource(bind_group_layout1).? },
    });
}

fn shutdown() !void {}

fn render(ctx: *aya.render.RenderContext) !void {
    const pip = aya.gctx.lookupResource(state.pipeline) orelse return;
    const bg = aya.gctx.lookupResource(state.frame_bind_group) orelse return;

    // begin the render pass
    var pass = ctx.beginRenderPass(&.{
        .label = "Ding Render Pass Encoder",
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

        const mem = aya.gctx.uniforms.allocate(Uniform, 1);
        mem.slice[0] = .{
            .transform_matrix = Mat32.initOrtho(@as(f32, @floatFromInt(win_size.w)), @as(f32, @floatFromInt(win_size.h))),
        };
        pass.setBindGroup(0, bg, &.{mem.offset});
    }

    pass.end();
    pass.release();
}

const Node = zmesh.io.zcgltf.Node;
const Mesh = zmesh.io.zcgltf.Mesh;

fn loadGltf() void {
    zmesh.init(aya.mem.allocator);
    defer zmesh.deinit();

    const data = zmesh.io.parseAndLoadFile("examples/assets/models/avocado.glb") catch unreachable;
    defer zmesh.io.freeData(data);

    for (0..data.nodes_count) |i| {
        const node: Node = data.nodes.?[i];
        if (node.mesh) |mesh| setupMeshNode(mesh);
    }

    // var mesh_indices = std.ArrayList(u32).init(aya.mem.allocator);
    // var mesh_positions = std.ArrayList([3]f32).init(aya.mem.allocator);
    // var mesh_normals = std.ArrayList([3]f32).init(aya.mem.allocator);

    // zmesh.io.appendMeshPrimitive(
    //     data, // *zmesh.io.cgltf.Data
    //     0, // mesh index
    //     0, // gltf primitive index (submesh index)
    //     &mesh_indices,
    //     &mesh_positions,
    //     &mesh_normals, // normals (optional)
    //     null, // texcoords (optional)
    //     null, // tangents (optional)
    //     null, // colors (optional)
    // ) catch unreachable;
}

fn setupMeshNode(mesh: *Mesh) void {
    std.debug.print("mesh: {?s}\n", .{mesh.name});
}
