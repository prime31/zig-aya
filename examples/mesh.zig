const std = @import("std");
const aya = @import("aya");

var mesh: aya.gfx.Mesh = undefined;
var tex: aya.gfx.Texture = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .gfx = .{
            .resolution_policy = .none,
        },
    });
}

fn init() !void {
    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = 10, .y = 100 }, .uv = .{ .x = 1, .y = 0 }, .col = 0xFFFFFFFF }, // bl
        .{ .pos = .{ .x = 100, .y = 100 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF0000FF }, // br
        .{ .pos = .{ .x = 100, .y = 10 }, .uv = .{ .x = 0, .y = 1 }, .col = 0xFFFF0000 }, // tr
        .{ .pos = .{ .x = 10, .y = 10 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFF000000 }, // tl
    };
    var indices = [_]u16{
        0, 1, 2, 0, 2, 3,
    };

    mesh = aya.gfx.Mesh.init(u16, indices[0..], aya.gfx.Vertex, vertices[0..]);

    tex = aya.gfx.Texture.initCheckerTexture();
    mesh.bindImage(tex.img, 0);
}

fn shutdown() !void {
    mesh.deinit();
    tex.deinit();
}

fn update() !void {}

fn render() !void {
    aya.gfx.beginNullPass();
    aya.gfx.beginPass(.{ .color = aya.math.Color.gold });
    mesh.draw();
    aya.gfx.endPass();
}
