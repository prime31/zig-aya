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
const TriangleBatcher = aya.render.TriangleBatcher;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

var ground_tex: Texture = undefined;
var ball_tex: Texture = undefined;
var ball_n_tex: Texture = undefined;

var normals_shader: Shader = undefined;
var alpha_test_shader: Shader = undefined;
var light_shader: shaders.DeferredPointShader = undefined;
var light_pos = Vec2.init(40, 20);

var diffuse_pass: OffscreenPass = undefined;
var normal_pass: OffscreenPass = undefined;
var light_pass: OffscreenPass = undefined;

var mesh: DynamicMesh(u16, Vertex) = undefined;
var tri_batch: TriangleBatcher = undefined;

var stencil_write_incr: aya.rk.RenderState = .{
    .stencil = .{
        .pass_op = .incr_clamp,
        .ref = 1,
    },
    .blend = .{ .color_write_mask = .none },
};
var stencil_write_decr: aya.rk.RenderState = .{
    .stencil = .{
        .pass_op = .decr_clamp,
        .ref = 1,
    },
    .blend = .{ .color_write_mask = .none },
};
var stencil_read: aya.rk.RenderState = .{
    .depth = .{ .enabled = false },
    .stencil = .{
        .write_mask = 0x00,
        .compare_func = .greater_equal,
        .ref = 0,
    },
};

fn init() !void {
    ground_tex = Texture.initFromFile("examples/assets/ground.png", .nearest);
    ball_tex = Texture.initFromFile("examples/assets/ball.png", .nearest);
    ball_n_tex = Texture.initFromFile("examples/assets/ball_n.png", .nearest);

    normals_shader = shaders.createDeferredShader();
    normals_shader.onSetTransformMatrix = struct {
        fn set(mat: *Mat32) void {
            var params = shaders.DeferredVertexParams{};
            std.mem.copy(f32, &params.transform_matrix, &mat.data);
            normals_shader.setVertUniform(shaders.DeferredVertexParams, &params);
        }
    }.set;

    alpha_test_shader = shaders.createAlphaTestShader();

    light_shader = shaders.createDeferredPointShader();
    light_shader.frag_uniform.color[0] = 1.0;
    light_shader.frag_uniform.color[3] = 1.0;
    light_shader.frag_uniform.falloff_angle = 15;
    light_shader.frag_uniform.min_angle = -25;
    light_shader.frag_uniform.max_angle = 25;
    light_shader.frag_uniform.volumetric_intensity = 1.0;
    light_shader.frag_uniform.intensity = 1.0;
    light_shader.frag_uniform.color = Color.light_gray.asArray();
    light_shader.frag_uniform.resolution = Vec2.init(100, 50);

    diffuse_pass = OffscreenPass.init(100, 50);
    normal_pass = OffscreenPass.init(100, 50);
    light_pass = OffscreenPass.initWithStencil(100, 50, .nearest, .clamp);
    mesh = createDynamicMesh(1);
    tri_batch = TriangleBatcher.init(64);
}

fn update() !void {
    _ = ig.igSliderFloat("min angle", &light_shader.frag_uniform.min_angle, -180, 360, null, ig.ImGuiSliderFlags_None);
    _ = ig.igSliderFloat("max angle", &light_shader.frag_uniform.max_angle, -180, 360, null, ig.ImGuiSliderFlags_None);
    _ = ig.igSliderFloat("falloff angle", &light_shader.frag_uniform.falloff_angle, 0, 45, null, ig.ImGuiSliderFlags_None);
    _ = ig.igSliderFloat("volumetric intensity", &light_shader.frag_uniform.volumetric_intensity, 0, 1, null, ig.ImGuiSliderFlags_None);
    _ = ig.igSliderFloat("intensity", &light_shader.frag_uniform.intensity, 0, 3, null, ig.ImGuiSliderFlags_None);
    _ = ig.igColorEdit3("light color", &light_shader.frag_uniform.color[0], ig.ImGuiColorEditFlags_DisplayRGB);
    _ = ig.igDragFloat2("light pos", &light_pos.x, 1, 0, 150, null, ig.ImGuiSliderFlags_None);

    if (ig.igButton("Make into point light", .{})) {
        light_shader.frag_uniform.min_angle = -180;
        light_shader.frag_uniform.max_angle = 360;
        light_shader.frag_uniform.falloff_angle = 0;
    }
}

fn render() !void {
    // diffuse
    aya.gfx.beginPass(.{ .pass = diffuse_pass, .color = Color.black });
    aya.gfx.draw.tex(ground_tex, 0, 0);
    aya.gfx.draw.tex(ball_tex, 50, 15);
    aya.gfx.endPass();

    // normals
    aya.gfx.beginPass(.{ .pass = normal_pass, .shader = &normals_shader, .color = Color.fromRgb(0.5, 0.5, 0) });
    drawTex(ground_tex, .{});
    drawTex(ball_tex, .{ .x = 50, .y = 15 });
    aya.gfx.endPass();

    // lights
    light_shader.textures[0] = normal_pass.color_texture;
    light_shader.textures[1] = diffuse_pass.color_texture;
    aya.gfx.beginPass(.{ .pass = light_pass, .shader = &alpha_test_shader, .color = Color.black, .clear_stencil = true });
    // write 1+ in stencil where we have shadows
    {
        aya.gfx.setRenderState(stencil_write_incr);
        tri_batch.begin();
        var ball_verts = buildSymmetricalPolygon(12, 23 * 0.5);
        renderShadowVerts(Vec2.init(50 + ball_tex.width * 0.5, 15 + ball_tex.height * 0.5), light_pos, ball_verts);
        tri_batch.end();

        // decrement stencil where our occluders are so they are still rendered
        aya.gfx.setRenderState(stencil_write_decr);
        drawTex(ball_tex, .{ .x = 50, .y = 15 });
        aya.gfx.flush();
    }

    // write lights only where stencil is 0 (ie not in shadow)
    {
        aya.gfx.setShader(&light_shader.shader);
        aya.gfx.setRenderState(stencil_read);
        aya.gfx.draw.point(light_pos, 150, Color.white);
    }
    aya.gfx.endPass();
    aya.gfx.setRenderState(.{});

    // debug render polygon
    // aya.gfx.beginPass(.{ .pass = light_pass, .color = Color.black, .clear_stencil = true });
    // tri_batch.begin();
    // var ball_verts = buildSymmetricalPolygon(12, 23 * 0.5);
    // renderShadowVerts(Vec2.init(50 + ball_tex.width * 0.5, 15 + ball_tex.height * 0.5), light_pos, ball_verts);
    // tri_batch.flush();
    // tri_batch.end();

    // drawTex(ball_tex, .{ .x = 50, .y = 15 });
    // aya.gfx.flush();
    // aya.gfx.endPass();

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
    ball_n_tex.deinit();
    normals_shader.deinit();
    alpha_test_shader.deinit();
    light_shader.deinit();
    diffuse_pass.deinit();
    normal_pass.deinit();
    light_pass.deinit();
    mesh.deinit();
    tri_batch.deinit();
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

fn buildSymmetricalPolygon(vert_count: usize, radius: f32) []Vec2 {
    var verts = aya.mem.tmp_allocator.alloc(Vec2, vert_count) catch unreachable;

    for (0..vert_count) |i| {
        var a = 2.0 * std.math.pi * (@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(vert_count)));
        verts[i] = Vec2.init(@cos(a), @sin(a)).mul(Vec2.init(radius, radius));
    }

    return verts;
}

fn renderShadowVerts(position: Vec2, light_position: Vec2, verts: []Vec2) void {
    for (verts, 0..) |v, i| {
        var vert = v.add(position);
        var next_vert = verts[@mod(i + 1, verts.len)].add(position);
        var start_to_end = next_vert.subtract(vert);
        var normal = Vec2.init(start_to_end.y, -start_to_end.x).normalize();
        var light_to_start = light_position.subtract(vert);

        var ndl = normal.dot(light_to_start);
        if (ndl > 0) {
            // var midpoint = next_vert.add(vert).scale(0.5);
            // aya.debug.drawLine(vert, next_vert, 1, Color.green);
            // aya.debug.drawLine(midpoint, midpoint.add(normal.scale(10)), 1, Color.green);

            var pt1 = next_vert.add(next_vert.subtract(light_position).scale(150));
            var pt2 = next_vert.add(vert.subtract(light_position).scale(150));

            var poly = [_]Vec2{ next_vert, pt1, pt2, vert };
            tri_batch.drawPolygon(&poly, Color.green);
        }
    }
}
