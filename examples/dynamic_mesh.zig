const std = @import("std");
const aya = @import("aya");

var mesh: aya.gfx.DynamicMesh(aya.gfx.Vertex) = undefined;
var rng = std.rand.DefaultPrng.init(0);

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    mesh.deinit();
}

fn init() void {
    var indices = [_]u16{
        0, 1, 2, 2, 3, 0,
    };
    mesh = aya.gfx.DynamicMesh(aya.gfx.Vertex).init(null, 4, 6, false) catch unreachable;
    mesh.index_buffer.setData(u16, indices[0..], 0, .none);

    mesh.verts[0] = .{ .pos = .{ .x = 220, .y = 20 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF };
    mesh.verts[1] = .{ .pos = .{ .x = 20, .y = 20 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF };
    mesh.verts[2] = .{ .pos = .{ .x = 20, .y = 220 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF };
    mesh.verts[3] = .{ .pos = .{ .x = 220, .y = 220 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF };
    mesh.updateAllVerts(.none);

    var shader = aya.gfx.Shader.initFromFile("assets/SpriteEffect.fxb") catch unreachable;
    var mat = aya.math.Mat32.initOrtho(640, 480);
    shader.setParam(aya.math.Mat32, "TransformMatrix", mat);
    shader.apply();

    const texture = aya.gfx.Texture.initCheckerboard();
    texture.bind(0);
}

fn update() void {
    const rx = aya.math.rand.range(f32, -2, 2);
    const ry = aya.math.rand.range(f32, -2, 2);

    var i: usize = 0;
    while (i < 4) : (i += 1) {
        mesh.verts[i].pos.x += rx;
        mesh.verts[i].pos.y += ry;
    }
    mesh.updateAllVerts(.none);
}

fn render() void {
    mesh.draw(0, 4);
}
