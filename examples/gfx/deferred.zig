const std = @import("std");
const shaders = @import("shaders");
const aya = @import("aya");
const ig = aya.ig;

const DynamicMesh = aya.render.DynamicMesh;
const Texture = aya.render.Texture;
const Color = aya.math.Color;
const Shader = aya.render.Shader;
const OffscreenPass = aya.render.OffscreenPass;
const ColorAttachmentAction = aya.render.PassConfig.ColorAttachmentAction;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

var ground_tex: Texture = undefined;
var ball_tex: Texture = undefined;

var shader: Shader = undefined;
var light_shader: Shader = undefined;

var diffuse_pass: OffscreenPass = undefined;
var normal_pass: OffscreenPass = undefined;
var light_pass: OffscreenPass = undefined;
var mesh: DynamicMesh(u16, Vertex) = undefined;

fn init() !void {
    ground_tex = Texture.initFromFile("examples/assets/ground.png", .nearest);
    ball_tex = Texture.initFromFile("examples/assets/ball.png", .nearest);

    shader = shaders.createDeferredShader();
    shader.onSetTransformMatrix = struct {
        fn set(mat: *Mat32) void {
            var params = shaders.DeferredVertexParams{};
            std.mem.copy(f32, &params.transform_matrix, &mat.data);
            shader.setVertUniform(shaders.DeferredVertexParams, &params);
        }
    }.set;

    light_shader = shaders.createDeferredPointShader();

    diffuse_pass = OffscreenPass.init(100, 50);
    normal_pass = OffscreenPass.init(100, 50);
    light_pass = OffscreenPass.init(100, 50);
    mesh = createDynamicMesh(1);
}

fn render() !void {
    aya.gfx.beginPass(.{ .pass = diffuse_pass, .color = Color.black });
    aya.gfx.draw.tex(ground_tex, 0, 0);
    aya.gfx.draw.tex(ball_tex, 50, 15);
    aya.gfx.endPass();

    // render diffuse and normals
    aya.gfx.beginPass(.{ .pass = normal_pass, .shader = &shader, .color = Color.fromRgb(0.5, 0.5, 0) });
    drawTex(ground_tex, .{});
    drawTex(ball_tex, .{ .x = 50, .y = 15 });
    aya.gfx.endPass();

    // lights
    aya.gfx.beginPass(.{ .pass = light_pass, .shader = &light_shader, .color = Color.black });
    aya.gfx.draw.point(.{ .x = 60, .y = 20 }, 50, Color.white);
    aya.gfx.endPass();

    aya.gfx.beginPass(.{ .color = Color.blue });
    const scale = 5.0;
    aya.gfx.draw.texScale(diffuse_pass.color_texture, 0, 0, scale);
    aya.gfx.draw.texScale(normal_pass.color_texture, diffuse_pass.color_texture.width * scale, diffuse_pass.color_texture.height * scale, scale);
    aya.gfx.draw.texScale(light_pass.color_texture, 0, diffuse_pass.color_texture.height * scale, scale);
    aya.gfx.endPass();
}

fn shutdown() !void {
    ground_tex.deinit();
    ball_tex.deinit();
    shader.deinit();
    light_shader.deinit();
    diffuse_pass.deinit();
    normal_pass.deinit();
    light_pass.deinit();
    mesh.deinit();
}

fn createDynamicMesh(max_sprites: u16) DynamicMesh(u16, Vertex) {
    var indices = aya.mem.tmp_allocator.alloc(u16, max_sprites * 6) catch unreachable;
    var i: usize = 0;
    while (i < max_sprites) : (i += 1) {
        indices[i * 3 * 2 + 0] = @as(u16, @intCast(i)) * 4 + 0;
        indices[i * 3 * 2 + 1] = @as(u16, @intCast(i)) * 4 + 1;
        indices[i * 3 * 2 + 2] = @as(u16, @intCast(i)) * 4 + 2;
        indices[i * 3 * 2 + 3] = @as(u16, @intCast(i)) * 4 + 0;
        indices[i * 3 * 2 + 4] = @as(u16, @intCast(i)) * 4 + 2;
        indices[i * 3 * 2 + 5] = @as(u16, @intCast(i)) * 4 + 3;
    }

    return DynamicMesh(u16, Vertex).init(max_sprites * 4, indices);
}

var vert_index: usize = 0;
pub fn drawTex(texture: Texture, pos: Vec2) void {
    var verts = mesh.verts[vert_index .. vert_index + 4];
    verts[0].pos = pos; // tl
    verts[0].uv = .{ .x = 0, .y = 0 };
    verts[0].normal = .{ .x = -0.5, .y = -0.5 };

    verts[1].pos = .{ .x = pos.x + texture.width, .y = pos.y }; // tr
    verts[1].uv = .{ .x = 1, .y = 0 };
    verts[1].normal = .{ .x = 0.5, .y = 0.5 };

    verts[2].pos = .{ .x = pos.x + texture.width, .y = pos.y + texture.height }; // br
    verts[2].uv = .{ .x = 1, .y = 1 };
    verts[2].normal = .{ .x = 0.5, .y = -0.5 };

    verts[3].pos = .{ .x = pos.x, .y = pos.y + texture.height }; // bl
    verts[3].uv = .{ .x = 0, .y = 1 };
    verts[3].normal = .{ .x = -0.5, .y = -0.5 };

    // vert_index += 4;
    mesh.bindImage(texture.img, 0);
    mesh.updateAllVerts();
    mesh.drawAllVerts();
}

pub const Vertex = extern struct {
    pos: Vec2 = .{ .x = 0, .y = 0 },
    uv: Vec2 = .{ .x = 0, .y = 0 },
    normal: Vec2 = .{ .x = 0, .y = 0 },
};
