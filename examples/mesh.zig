const std = @import("std");
const aya = @import("aya");

var mesh: aya.gfx.Mesh = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .gfx = .{
            .resolution_policy = .none,
        }
    });

    mesh.deinit();
}

fn init() void {
    // var vertices = [_]aya.gfx.Vertex{
    //     .{ .pos = .{ .x = 125, .y = -125 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF },
    //     .{ .pos = .{ .x = -125, .y = -125 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
    //     .{ .pos = .{ .x = -125, .y = 125 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF },
    //     .{ .pos = .{ .x = 125, .y = 125 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
    // };
    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = -1, .y = -1 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF },
        .{ .pos = .{ .x = 1, .y = -1 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = 1, .y = 1 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF },
        .{ .pos = .{ .x = -1, .y = 1 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
    };
    var indices = [_]u16{
        0, 1, 2, 2, 3, 0,
    };

    mesh = aya.gfx.Mesh.init(aya.gfx.Vertex, vertices[0..], indices[0..]);
}

fn shutdown() void {
    mesh.deinit();
}

fn update() void {}

fn render() void {
    aya.gfx.beginNullPass();
    aya.gfx.beginPass(.{});
    mesh.draw();
    aya.gfx.endPass();
}
