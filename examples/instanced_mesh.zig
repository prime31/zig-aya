const std = @import("std");
const aya = @import("aya");

pub const renderer: aya.renderkit.Renderer = .opengl;

var mesh: aya.gfx.Mesh = undefined;
var tex: aya.gfx.Texture = undefined;
var instanced_mesh: aya.gfx.InstancedMesh(u16, aya.gfx.Vertex, InstancedVert) = undefined;
var shader: aya.gfx.Shader = undefined;

const InstancedVert = struct {
    pos: aya.math.Vec2,
};

const instanced_vert: [:0]const u8 =
    \\#version 330
    \\uniform vec4 VertexParams[2];
    \\
    \\layout (location=0) in vec2 VertPosition;
    \\layout (location=1) in vec2 VertTexCoord;
    \\layout (location=2) in vec4 VertColor;
    \\layout (location=3) in vec2 InstancePos;
    \\
    \\out vec2 VaryingTexCoord;
    \\out vec4 VaryingColor;
    \\
    \\vec4 position(mat3x2 transMat, vec2 localPosition);
    \\
    \\void main() {
    \\	VaryingTexCoord = VertTexCoord;
    \\	VaryingColor = VertColor;
    \\	gl_Position = position(mat3x2(vec2(VertexParams[0].x, VertexParams[0].y), vec2(VertexParams[0].z, VertexParams[0].w), vec2(VertexParams[1].x, VertexParams[1].y)), VertPosition + InstancePos);
    \\}
    \\
    \\vec4 position(mat3x2 transMat, vec2 localPosition) {
    \\	return vec4(transMat * vec3(localPosition, 1), 0, 1);
    \\}
;

const instanced_frag: [:0]const u8 =
    \\#version 330
    \\uniform sampler2D main_tex;
    \\
    \\in vec2 VaryingTexCoord;
    \\in vec4 VaryingColor;
    \\
    \\vec4 effect(sampler2D tex, vec2 texcoord, vec4 vcolor);
    \\
    \\layout (location = 0) out vec4 frag_color;
    \\
    \\void main() {
    \\	frag_color = texture(main_tex, VaryingTexCoord.st) * VaryingColor;
    \\}
;

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
    tex = aya.gfx.Texture.initCheckerTexture();

    var vertices = [_]aya.gfx.Vertex{
        .{ .pos = .{ .x = 10, .y = 110 }, .uv = .{ .x = 1, .y = 0 }, .col = 0xFFFFFFFF }, // bl
        .{ .pos = .{ .x = 110, .y = 110 }, .uv = .{ .x = 0, .y = 0 }, .col = 0xFF0000FF }, // br
        .{ .pos = .{ .x = 110, .y = 10 }, .uv = .{ .x = 0, .y = 1 }, .col = 0xFFFF0000 }, // tr
        .{ .pos = .{ .x = 10, .y = 10 }, .uv = .{ .x = 1, .y = 1 }, .col = 0xFF000000 }, // tl
    };
    var indices = [_]u16{ 0, 1, 2, 0, 2, 3 };

    mesh = aya.gfx.Mesh.init(u16, indices[0..], aya.gfx.Vertex, vertices[0..]);
    mesh.bindImage(tex.img, 0);

    // instanced
    vertices[0].pos = .{ .x = 0, .y = 16 }; // bl
    vertices[0].col = 0xFFFFFFFF;
    vertices[1].pos = .{ .x = 16, .y = 16 }; // br
    vertices[1].col = 0xFFFFFFFF;
    vertices[2].pos = .{ .x = 16, .y = 0 }; // tr
    vertices[2].col = 0xFFFFFFFF;
    vertices[3].pos = .{ .x = 0, .y = 0 }; // tl
    vertices[3].col = 0xFFFFFFFF;
    instanced_mesh = try aya.gfx.InstancedMesh(u16, aya.gfx.Vertex, InstancedVert).init(null, 100, indices[0..], vertices[0..]);

    const instances_per_row = @divTrunc(aya.window.width(), @as(i32, 40));
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

    shader = try aya.gfx.Shader.init(.{ .vert = instanced_vert, .frag = instanced_frag });
}

fn shutdown() !void {
    mesh.deinit();
    instanced_mesh.deinit();
    tex.deinit();
}

fn update() !void {}

fn render() !void {
    aya.gfx.beginNullPass();
    aya.gfx.beginPass(.{ .color = aya.math.Color.gold });
    mesh.draw();

    aya.gfx.setShader(&shader);
    instanced_mesh.drawAll();
    aya.gfx.endPass();
}
