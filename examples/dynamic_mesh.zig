const std = @import("std");
const aya = @import("aya");

var mesh: aya.gfx.DynamicMesh(aya.gfx.Vertex) = undefined;
var tex: aya.gfx.Texture = undefined;
var rng = std.rand.DefaultPrng.init(0);

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

fn init() void {
    var indices = [_]u16{
        0, 1, 2, 2, 3, 0,
    }; //0, 1, 2, 0, 2, 3,
    mesh = aya.gfx.DynamicMesh(aya.gfx.Vertex).init(null, 4, indices[0..]) catch unreachable;

    mesh.verts[0] = .{ .pos = .{ .x = 220, .y = 20 }, .uv = .{ .x = 1, .y = 0 }, .col = 0xFFFF0FFF };
    mesh.verts[1] = .{ .pos = .{ .x = 20, .y = 20 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF };
    mesh.verts[2] = .{ .pos = .{ .x = 20, .y = 220 }, .uv = .{ .x = 0, .y = 1 }, .col = 0xFFFFFFFF };
    mesh.verts[3] = .{ .pos = .{ .x = 220, .y = 220 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF };
    mesh.updateAllVerts();

    tex = aya.gfx.Texture.initFromFile("assets/sword_dude.png", .nearest) catch unreachable;
    mesh.bindings.fs_images[0] = tex.img;
}

fn shutdown() void {
    mesh.deinit();
    tex.deinit();
}

fn update() void {
    const rx = aya.math.rand.range(f32, -2, 2);
    const ry = aya.math.rand.range(f32, -2, 2);

    var i: usize = 0;
    while (i < 4) : (i += 1) {
        mesh.verts[i].pos.x += rx;
        mesh.verts[i].pos.y += ry;
    }
    mesh.updateAllVerts();
}

fn render() void {
    aya.gfx.beginNullPass();
    aya.gfx.beginPass(.{ .color = aya.math.Color.gold });
    mesh.draw();
    aya.draw.tex(tex, 400, 400);
    aya.gfx.endPass();
}