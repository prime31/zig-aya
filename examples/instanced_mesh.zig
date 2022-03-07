const std = @import("std");
const aya = @import("aya");
const shaders = @import("assets/shaders/shaders.zig");

var tex: aya.gfx.Texture = undefined;
var instanced_mesh: aya.gfx.InstancedMesh(u16, aya.gfx.Vertex, InstancedVert) = undefined;
var shader: aya.gfx.Shader = undefined;

const InstancedVert = struct {
    pos: aya.math.Vec2,
};

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
    tex = aya.gfx.Texture.initCheckerTexture(1);

    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = 10, .y = 110 }, .uv = .{ .x = 1, .y = 0 }, .col = 0xFFFFFFFF }, // bl
        .{ .pos = .{ .x = 110, .y = 110 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF0000FF }, // br
        .{ .pos = .{ .x = 110, .y = 10 }, .uv = .{ .x = 0, .y = 1 }, .col = 0xFFFF0000 }, // tr
        .{ .pos = .{ .x = 10, .y = 10 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFF000000 }, // tl
    };
    var indices = [_]u16{ 0, 1, 2, 0, 2, 3 };

    vertices[0].pos = .{ .x = 0, .y = 16 }; // bl
    vertices[0].col = 0xFFFFFFFF;
    vertices[1].pos = .{ .x = 16, .y = 16 }; // br
    vertices[1].col = 0xFFFFFFFF;
    vertices[2].pos = .{ .x = 16, .y = 0 }; // tr
    vertices[2].col = 0xFFFFFFFF;
    vertices[3].pos = .{ .x = 0, .y = 0 }; // tl
    vertices[3].col = 0xFFFFFFFF;
    instanced_mesh = try aya.gfx.InstancedMesh(u16, aya.gfx.Vertex, InstancedVert).init(null, 100, indices[0..], vertices[0..]);

    // const instances_per_row = @divTrunc(aya.window.width(), @as(i32, 40));
    var i: usize = 0;
    var y: i32 = 200;
    blk: while (y < aya.window.height() - 50) : (y += 24) {
        var x: i32 = 18;
        while (x < aya.window.width() - 50) : (x += 50) {
            instanced_mesh.instance_data[i].pos = .{ .x = @intToFloat(f32, x), .y = @intToFloat(f32, y) };
            i += 1;
            if (i == 100) break :blk;
        }
    }
    instanced_mesh.updateInstanceData();
    instanced_mesh.bindImage(tex.img, 0);

    shader = try shaders.createInstancedShader();
}

fn shutdown() !void {
    instanced_mesh.deinit();
    tex.deinit();
}

fn update() !void {}

fn render() !void {
    aya.gfx.beginNullPass();
    aya.gfx.beginPass(.{ .color = aya.math.Color.gold });

    aya.gfx.setShader(&shader);
    instanced_mesh.drawAll();

    aya.gfx.endPass();
}
