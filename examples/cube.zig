const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders3d");
const Pipeline = aya.gfx.Pipeline;
const Mat4 = aya.math.Mat4;
const Vec3 = aya.math.Vec3;
const Vec2 = aya.math.Vec2;
usingnamespace @import("sokol");

const SampleCount = 1;

pub const VertPosColTex = extern struct {
    pos: Vec3,
    col: u32,
    uv: aya.math.Vec2,
};

const CubeParams = struct {
    mvp: Mat4,
};

const State = struct {
    pipeline: sg_pipeline,
    bindings: sg_bindings,
    texture: aya.gfx.Texture,
};

var rx: f32 = 0.0;
var ry: f32 = 0.0;
var state: State = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() void {
    const verts = [_]VertPosColTex{
        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFF0000FF, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFF0000FF, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFF0000FF, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFF0000FF, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFF00FF00, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFFFF0000, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFFFF0000, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFFFF0000, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFFFF0000, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFFFF007F, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFFFF007F, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFFFF007F, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFFFF007F, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, -1.0, -1.0), .col = 0xFFFF7F00, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, -1.0, 1.0), .col = 0xFFFF7F00, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, -1.0, 1.0), .col = 0xFFFF7F00, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, -1.0, -1.0), .col = 0xFFFF7F00, .uv = Vec2.init(0, 1) },

        .{ .pos = Vec3.init(-1.0, 1.0, -1.0), .col = 0xFF007FFF, .uv = Vec2.init(0, 0) },
        .{ .pos = Vec3.init(-1.0, 1.0, 1.0), .col = 0xFF007FFF, .uv = Vec2.init(1, 0) },
        .{ .pos = Vec3.init(1.0, 1.0, 1.0), .col = 0xFF007FFF, .uv = Vec2.init(1, 1) },
        .{ .pos = Vec3.init(1.0, 1.0, -1.0), .col = 0xFF007FFF, .uv = Vec2.init(0, 1) },
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
    pipeline_desc.rasterizer.sample_count = SampleCount;
    state.pipeline = sg_make_pipeline(&pipeline_desc);
}

fn update() void {
    aya.debug.drawText("spinning cube", .{ .x = 10, .y = 20 }, null);
}

fn render() void {
    const width = sapp_width();
    const height = sapp_height();
    const w: f32 = @intToFloat(f32, width);
    const h: f32 = @intToFloat(f32, height);
    const radians: f32 = 1.0472; //60 degrees
    var proj: Mat4 = Mat4.createPerspective(radians, w / h, 0.01, 100.0);
    var view: Mat4 = Mat4.createLookAt(.{ .x = 2.0, .y = 3.5, .z = 2.0 }, .{ .x = 0.0, .y = 0.0, .z = 0.0 }, .{ .x = 0.0, .y = 1.0, .z = 0.0 });
    var view_proj = Mat4.mul(proj, view);
    rx += 1.0 / 220.0;
    ry += 2.0 / 220.0;
    var rxm = Mat4.createAngleAxis(.{ .x = 1, .y = 0, .z = 0 }, rx);
    var rym = Mat4.createAngleAxis(.{ .x = 0, .y = 1, .z = 0 }, ry);

    var model = Mat4.mul(rxm, rym);
    var mvp = Mat4.mul(view_proj, model);

    var params = CubeParams{ .mvp = mvp };

    aya.gfx.beginPass(.{});
    sg_apply_pipeline(state.pipeline);
    sg_apply_bindings(&state.bindings);
    sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &params, @sizeOf(CubeParams));
    sg_draw(0, 36, 1);
    aya.gfx.endPass();
}
