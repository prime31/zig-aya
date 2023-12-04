const std = @import("std");
const aya = @import("aya");

var mesh: aya.render.Mesh = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    var gctx = aya.gctx;

    var texture = gctx.createTextureFromFile("examples/assets/tree0.png");

    // texture view
    var tex_view = gctx.createTextureView(texture, &.{});

    // sampler
    var sampler = gctx.createSampler(&.{});

    const bind_group_layout = gctx.createBindGroupLayout(&.{
        .label = "Bind Group",
        .entries = &.{
            .{ .visibility = .{ .fragment = true }, .texture = .{} },
            .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(bind_group_layout); // TODO: do we have to hold onto these?

    var bind_group = gctx.createBindGroup(bind_group_layout, &.{
        .{ .texture_view_handle = tex_view },
        .{ .sampler_handle = sampler },
    });
    _ = bind_group;

    var pipeline = gctx.createPipeline(&.{
        .source = @embedFile("assets/shaders/quad.wgsl"),
        .vbuffers = &aya.gpu.vertexAttributesForType(aya.render.Vertex).vertexBufferLayouts(),
    });
    _ = pipeline;

    var vertices = [_]aya.render.Vertex{
        .{ .pos = .{ .x = 10, .y = 100 }, .uv = .{ .x = 1, .y = 0 }, .col = 0xFFFFFFFF }, // bl
        .{ .pos = .{ .x = 100, .y = 100 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF0000FF }, // br
        .{ .pos = .{ .x = 100, .y = 10 }, .uv = .{ .x = 0, .y = 1 }, .col = 0xFFFF0000 }, // tr
        .{ .pos = .{ .x = 10, .y = 10 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFF000000 }, // tl
    };
    var indices = [_]u16{
        0, 1, 2, 0, 2, 3,
    };

    mesh = aya.render.Mesh.init(u16, indices[0..], aya.render.Vertex, vertices[0..]);
}

fn shutdown() !void {
    mesh.deinit();
}

fn render() !void {}
