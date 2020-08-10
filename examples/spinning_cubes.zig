const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders3d");
const Pipeline = aya.gfx.Pipeline;
const Color = aya.math.Color;
const Mat4 = aya.math.Mat4;
const Vec3 = aya.math.Vec3;
const Vec2 = aya.math.Vec2;
usingnamespace @import("sokol");
usingnamespace @import("imgui");

pub const imgui = true;

pub const VertPosColTex = extern struct {
    pos: Vec3,
    col: u32,
    uv: aya.math.Vec2,
};

const CubeParams = struct {
    mvp: Mat4,
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

const Camera = struct {
    pub const inspect = .{ .fov = .{ .min = 5, .max = 100 } };

    pos: Vec3 = Vec3.init(0, 0, -10),
    dir: Vec3 = Vec3.init(0, 0, -1),
    up: Vec3 = Vec3.up,
    fov: f32 = 60,
    yaw: f32 = 10,
    pitch: f32 = 10,
    sensitivity: f32 = 0.2,
    constrain_pitch: bool = true,

    radius: f32 = 10,
    auto_move: bool = false,

    pub fn update(self: *Camera) void {
        const x = std.math.sin(aya.time.seconds()) * self.radius;
        const z = std.math.cos(aya.time.seconds()) * self.radius;
        self.pos.x = x;
        self.pos.z = z;
    }

    pub fn updateInput(self: *Camera) void {
        const speed = 0.4;
        if (aya.input.keyDown(.SAPP_KEYCODE_W)) {
            self.pos = self.pos.add(self.dir.scale(speed));
        }
        if (aya.input.keyDown(.SAPP_KEYCODE_S)) {
            self.pos = self.pos.sub(self.dir.scale(speed));
        }
        if (aya.input.keyDown(.SAPP_KEYCODE_A)) {
            self.pos = self.pos.sub(self.dir.cross(self.up).normalize().scale(speed));
        }
        if (aya.input.keyDown(.SAPP_KEYCODE_D)) {
            self.pos = self.pos.add(self.dir.cross(self.up).normalize().scale(speed));
        }
        if (aya.input.keyDown(.SAPP_KEYCODE_E)) {
            self.pos = self.pos.add(self.up.normalize().scale(speed));
        }
        if (aya.input.keyDown(.SAPP_KEYCODE_Q)) {
            self.pos = self.pos.sub(self.up.normalize().scale(speed));
        }

        var mouse = aya.input.mouseRelMotion();
        mouse.scale(self.sensitivity);
        self.yaw += mouse.x;
        self.pitch += mouse.y;

        if (self.constrain_pitch) {
            self.pitch = std.math.clamp(self.pitch, -89.0, 89.0);
        }

        self.dir.x = std.math.cos(aya.math.toRadians(self.yaw)) * std.math.cos(aya.math.toRadians(self.pitch));
        self.dir.y = std.math.sin(aya.math.toRadians(self.pitch));
        self.dir.z = std.math.sin(aya.math.toRadians(self.yaw)) * std.math.cos(aya.math.toRadians(self.pitch));
        self.dir = self.dir.normalize();
    }

    pub fn view(self: *Camera) Mat4 {
        if (self.auto_move) {
            self.update();
        }
        return Mat4.createLookAt(self.pos, self.pos.add(self.dir), self.up);
    }

    pub fn proj(self: Camera) Mat4 {
        const aspect = @intToFloat(f32, sapp_width()) / @intToFloat(f32, sapp_height());
        return Mat4.createPerspective(aya.math.toRadians(self.fov), aspect, 0.01, 1000.0);
    }
};

const State = struct {
    pipeline: sg_pipeline,
    bindings: sg_bindings,
    texture: aya.gfx.Texture,
    cam: Camera,
};

var cube_rot: f32 = 0;
var state: State = undefined;

var cubes = [_]Cube{
    Cube.init(Vec3.init(0.0, 2.0, 5.0), 15),
    Cube.init(Vec3.init(2.0, 5.0, -5.0), 20),
    Cube.init(Vec3.init(-1.5, -2.2, -2.5), 25),
    Cube.init(Vec3.init(-3.8, -2.0, -12.3), 35),
    Cube.init(Vec3.init(2.4, -0.4, -3.5), 20),
    Cube.init(Vec3.init(-10.7, 3.0, -7.5), 25),
    Cube.init(Vec3.init(10.3, -2.0, -2.5), 35),
    Cube.init(Vec3.init(10.5, 2.0, -2.5), 20),
    Cube.init(Vec3.init(10.5, 0.2, -1.5), 25),
    Cube.init(Vec3.init(-10.3, 1.0, -1.5), 35),
};

pub fn main() !void {
    state.cam = .{};

    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .window = .{
            .width = 1024,
            .height = 768,
        },
    });
}

fn init() void {
    const verts = [_]VertPosColTex{
        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = Color.red.value, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = Color.red.value, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = Color.red.value, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = Color.red.value, .uv = Vec2.init(0, 1) },

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

    const indices = [_]u16{
        0,  1,  2,  0,  2,  3,
        6,  5,  4,  7,  6,  4,
        8,  9,  10, 8,  10, 11,
        14, 13, 12, 15, 14, 12,
        16, 17, 18, 16, 18, 19,
        22, 21, 20, 23, 22, 20,
    };

    state.texture = aya.gfx.Texture.initCheckerboard();
    state.bindings.fs_images[0] = state.texture.img;

    state.bindings.vertex_buffers[0] = sg_make_buffer(&std.mem.zeroInit(sg_buffer_desc, .{
        .size = verts.len * @sizeOf(VertPosColTex),
        .content = &verts[0],
    }));

    state.bindings.index_buffer = sg_make_buffer(&std.mem.zeroInit(sg_buffer_desc, .{
        .type = .SG_BUFFERTYPE_INDEXBUFFER,
        .size = indices.len * @sizeOf(u16),
        .content = &indices[0],
    }));

    var pipeline_desc = std.mem.zeroes(sg_pipeline_desc);
    pipeline_desc.layout.attrs[0].format = .SG_VERTEXFORMAT_FLOAT3;
    pipeline_desc.layout.attrs[1].format = .SG_VERTEXFORMAT_UBYTE4N;
    pipeline_desc.layout.attrs[2].format = .SG_VERTEXFORMAT_FLOAT2;
    pipeline_desc.shader = sg_make_shader(shaders.cube_shader_desc());
    pipeline_desc.index_type = .SG_INDEXTYPE_UINT16;
    pipeline_desc.depth_stencil.depth_compare_func = .SG_COMPAREFUNC_LESS_EQUAL;
    pipeline_desc.depth_stencil.depth_write_enabled = true;
    pipeline_desc.rasterizer.cull_mode = .SG_CULLMODE_BACK;
    state.pipeline = sg_make_pipeline(&pipeline_desc);
}

fn update() void {
    state.cam.updateInput();
    _ = aya.utils.inspect("Camera", &state.cam);
    _ = igDragFloat("cube_rot", &cube_rot, 0.5, 0, 360, null, 1);
}

fn render() void {
    const model = Mat4.createAngleAxis(Vec3.init(1, 0, 0), aya.math.toRadians(cube_rot));
    var view_proj = Mat4.mul(state.cam.proj(), state.cam.view());
    // var mvp = Mat4.mul(view_proj, model);

    aya.gfx.beginPass(.{});
    sg_apply_pipeline(state.pipeline);
    sg_apply_bindings(&state.bindings);

    var params = CubeParams{ .mvp = view_proj };
    sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &params, @sizeOf(CubeParams));
    sg_draw(0, 36, 1);

    for (cubes) |*cube, i| {
        cube.update();

        params = CubeParams{ .mvp = Mat4.mul(view_proj, cube.model) };
        sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &params, @sizeOf(CubeParams));
        sg_draw(0, 36, 1);
    }

    aya.gfx.endPass();
}
