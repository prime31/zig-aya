const std = @import("std");
const aya = @import("aya");

var mesh: aya.gfx.Mesh = undefined;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    mesh.deinit();
}

fn init() void {
    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = 0.5, .y = -0.5 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF },
        .{ .pos = .{ .x = -0.5, .y = -0.5 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = -0.5, .y = 0.5 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF },
        .{ .pos = .{ .x = 0.5, .y = 0.5 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
    };
    var indices = [_]u16{
        0, 1, 2, 2, 3, 0,
    };
    mesh = aya.gfx.Mesh.init(aya.gfx.Vertex, 4, 6, false, false);
    mesh.index_buffer.setData(u16, indices[0..], 0, .none);
    mesh.vert_buffer.setData(aya.gfx.Vertex, vertices[0..], 0, .none);

    var shader = aya.gfx.Shader.initFromFile("assets/VertexColor.fxb") catch unreachable;
    shader.apply();
}

fn update() void {}

fn render() void {
    mesh.draw(4);
}
