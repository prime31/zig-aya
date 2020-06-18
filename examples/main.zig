const std = @import("std");
const fna = @import("fna");
const mojo = fna.mojo;
const aya = @import("aya");

const png = @embedFile("../assets/font.png");
const Allocator = std.mem.Allocator;

var mesh: aya.gfx.Mesh = undefined;
var vertDecl: fna.VertexDeclaration = undefined;
var vertBindings: fna.VertexBufferBinding = undefined;
var vertBuffer: ?*fna.Buffer = undefined;

// defunct example. eventually make this a simple template
pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    mesh.deinit();
}

fn init() void {
    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = 200 + 250, .y = -200 + 250 }, .uv = .{ .x = 1, .y = 0 }, .col = 0x00FF0FFF },
        .{ .pos = .{ .x = -200 + 250, .y = -200 + 250 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF00FFFF },
        .{ .pos = .{ .x = -200 + 250, .y = 200 + 250 }, .uv = .{ .x = 0, .y = 1 }, .col = 0x00FFFFFF },
        .{ .pos = .{ .x = 200 + 250, .y = 200 + 250 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFFFFFFFF },
    };
    var indices = [_]u16{
        0, 1, 2, 2, 3, 0,
    };
    mesh = aya.gfx.Mesh.init(aya.gfx.Vertex, 4, 6, false, false);
    mesh.index_buffer.setData(u16, indices[0..], 0, .none);
    mesh.vert_buffer.setData(aya.gfx.Vertex, vertices[0..], 0, .none);

    const shader = createShader();
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{});
    mesh.draw(4);
    aya.gfx.endPass();
}

fn createShader() !aya.gfx.Shader {
    var shader = try aya.gfx.Shader.initFromFile("assets/VertexColor.fxb");
    var mat = aya.math.Mat32.initOrthoOffCenter(2, 2);
    shader.setParam(aya.math.Mat32, "TransformMatrix", mat);
    shader.apply();

    return shader;
}
