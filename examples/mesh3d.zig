const std = @import("std");
const aya = @import("aya");
const shaders = @import("assets/shaders/shaders.zig");

const Color = aya.math.Color;
const Vec2 = aya.math.Vec2;
const Vec3 = aya.math.Vec3;
const Mat4 = aya.math.Mat4;

pub const Vertex = extern struct {
    pos: Vec3 = .{},
    col: u32 = 0xFFFFFFFF,
    uv: Vec2 = .{},
};

const Cube = struct {
    pos: Vec3,
    radius: f32,
    speed: f32,
    model: Mat4 = undefined,

    pub fn init(pos: Vec3, radius: f32) Cube {
        return .{ .pos = pos, .radius = radius, .speed = pos.y };
    }

    pub fn update(self: *Cube) void {
        const x = std.math.sin(aya.time.seconds() * self.speed) * self.radius;
        const z = std.math.cos(aya.time.seconds() * self.speed) * self.radius;
        self.pos.x = x;
        self.pos.z = z;
        self.pos.y = std.math.sin(aya.time.seconds() / self.speed) * 10;

        const axis = Vec3.zero.sub(self.pos).normalize();
        const rot = Mat4.createAngleAxis(axis, 0);
        var m = Mat4.createTranslation(self.pos);
        self.model = m.mul(rot);

        const world = Mat4.createWorld(self.pos, Vec3.zero.sub(self.pos), Vec3.up);
        self.model = world;
    }
};

pub const enable_imgui = true;

var cube_rot_x: f32 = 0;
var cube_rot_y: f32 = 0;
var mesh: aya.gfx.Mesh = undefined;
var tex: aya.gfx.Texture = undefined;
var shader: aya.gfx.Shader = undefined;
var depth_shader: shaders.DepthShader = undefined;

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
    var verts = [_]Vertex{
        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = Color.yellow.value, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = Color.yellow.value, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = Color.yellow.value, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = Color.yellow.value, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFFFF7F00, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFFFF7F00, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFFFF7F00, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFFFF7F00, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFFFFFFFF, .uv = Vec2.init(0, 1) },
    };

    var indices = [_]u16{
        0,  1,  2,  0,  2,  3,
        6,  5,  4,  7,  6,  4,
        8,  9,  10, 8,  10, 11,
        14, 13, 12, 15, 14, 12,
        16, 17, 18, 16, 18, 19,
        22, 21, 20, 23, 22, 20,
    };

    mesh = aya.gfx.Mesh.init(u16, indices[0..], Vertex, verts[0..]);

    tex = aya.gfx.Texture.initCheckerTexture(2);
    mesh.bindImage(tex.img, 0);

    shader = shaders.createCubeShader() catch unreachable;
    depth_shader = shaders.createDepthShader();

    aya.gfx.setRenderState(.{
        .depth = .{
            .enabled = true,
            .compare_func = .less_equal,
        },
        .cull_mode = .back,
    });
}

fn shutdown() !void {
    mesh.deinit();
    tex.deinit();
    shader.deinit();
    depth_shader.deinit();
}

fn update() !void {
    _ = aya.imgui.igDragFloat("cube_rot_x", &cube_rot_x, 0.5, 0, 360, null, 1);
    _ = aya.imgui.igDragFloat("cube_rot_y", &cube_rot_y, 0.5, 0, 360, null, 1);
}

fn render() !void {
    cube_rot_x += aya.time.dt();
    cube_rot_y += aya.time.dt() * 2;

    const proj = Mat4.createPerspective(58, aya.window.aspectRatio(), 0.1, 10);
    const view = Mat4.createLookAt(Vec3.init(0, 1.5, 3), Vec3.init(0.0, 0.0, 0.0), Vec3.init(0.0, 1.0, 0.0));
    const view_proj = Mat4.mul(proj, view);

    const rxm = Mat4.createRotate(cube_rot_x, Vec3.init(1, 0, 0));
    const rym = Mat4.createRotate(cube_rot_y, Vec3.init(0, 1, 0));
    const model = Mat4.mul(rxm, rym);
    const mvp = Mat4.mul(view_proj, model);

    aya.gfx.beginNullPass();
    aya.gfx.beginPass(.{ .color = aya.math.Color.gold, .clear_depth = true, .shader = &shader });

    var params = shaders.CubeParamsVS{ .mvp = mvp };
    shader.setVertUniform(shaders.CubeParamsVS, &params);

    mesh.draw();
    aya.gfx.endPass();



    // depth_shader.frag_uniform.near = 0.1;
    // depth_shader.frag_uniform.far = 10;

    // aya.gfx.beginPass(.{ .clear_depth = false, .clear_color = false, .shader = &depth_shader.shader });
    // aya.draw.rect(.{}, aya.window.widthf(), aya.window.heightf(), aya.math.Color.white);
    // aya.gfx.endPass();
}
