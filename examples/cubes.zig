const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders3d");
const Pipeline = aya.gfx.Pipeline;
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
        return Mat4.createPerspective(aya.math.toRadians(self.fov), aspect, 0.01, 100.0);
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

const cube_positions = [_]Vec3{
    Vec3.init(0.0, 0.0, 0.0),
    Vec3.init(2.0, 5.0, -15.0),
    Vec3.init(-1.5, -2.2, -2.5),
    Vec3.init(-3.8, -2.0, -12.3),
    Vec3.init(2.4, -0.4, -3.5),
    Vec3.init(-1.7, 3.0, -7.5),
    Vec3.init(1.3, -2.0, -2.5),
    Vec3.init(1.5, 2.0, -2.5),
    Vec3.init(1.5, 0.2, -1.5),
    Vec3.init(-1.3, 1.0, -1.5),
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
        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFF0000F, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFF0000F, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFF0000F, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFF0000F, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFFFF0000, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFFFF0000, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFFFF0000, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFFFF0000, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFFFF007, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFFFF007, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFFFF007, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFFFF007, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFFFF7F00, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFFFF7F00, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFFFF7F00, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFFFF7F00, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFF007FF, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFF007FF, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFF007FF, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFF007FF, .uv = Vec2.init(0, 1) },
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

    for (cube_positions) |pos, i| {
        const angle = 20.0 * @intToFloat(f32, i);
        const rot = Mat4.createAngleAxis(Vec3.init(0, 0, 1), aya.math.toRadians(angle));
        var m = Mat4.createTranslation(pos);
        m = m.mul(rot);

        var params = CubeParams{ .mvp = Mat4.mul(view_proj, m) };
        sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &params, @sizeOf(CubeParams));
        sg_draw(0, 36, 1);
    }

    aya.gfx.endPass();
}
