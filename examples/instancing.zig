const std = @import("std");
const aya = @import("aya");
const rand = aya.math.rand;
const shaders = @import("shaders3d");
const Pipeline = aya.gfx.Pipeline;
const Color = aya.math.Color;
const Mat4 = aya.math.Mat4;
const Vec3 = aya.math.Vec3;
const Vec2 = aya.math.Vec2;
usingnamespace @import("sokol");

const NumParticlesEmittedPerFrame = 1000;
const MaxParticles: u32 = 512 * 2014;

pub const VertPosCol = extern struct {
    pos: Vec3,
    col: u32,
};

const InstanceParams = struct {
    mvp: Mat4,
};

const State = struct {
    pipeline: sg_pipeline,
    bindings: sg_bindings,
    texture: aya.gfx.Texture,
};

var ry: f32 = 0.0;
var state: State = undefined;
var cur_num_particles: u32 = 0;
var pos: [MaxParticles]Vec3 = undefined;
var vel: [MaxParticles]Vec3 = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .sample_count = 4,
    });
}

fn init() void {
    const r = 0.05;
    const verts = [_]VertPosCol{
        .{ .pos = Vec3.init(0.0, -r, 0.0), .col = Color.red.value },
        .{ .pos = Vec3.init(r, 0.0, r), .col = Color.green.value },
        .{ .pos = Vec3.init(r, 0.0, -r), .col = Color.blue.value },
        .{ .pos = Vec3.init(-r, 0.0, -r), .col = Color.yellow.value },
        .{ .pos = Vec3.init(-r, 0.0, r), .col = Color.fromRgb(0, 1, 1).value },
        .{ .pos = Vec3.init(0.0, r, 0.0), .col = Color.fromRgb(1, 0, 1).value },
    };

    const indices = [_]u16{
        0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1,
        5, 1, 2, 5, 2, 3, 5, 3, 4, 5, 4, 1,
    };

    state.bindings.vertex_buffers[0] = sg_make_buffer(&std.mem.zeroInit(sg_buffer_desc, .{
        .size = verts.len * @sizeOf(VertPosCol),
        .content = &verts[0],
    }));

    state.bindings.index_buffer = sg_make_buffer(&std.mem.zeroInit(sg_buffer_desc, .{
        .type = .SG_BUFFERTYPE_INDEXBUFFER,
        .size = indices.len * @sizeOf(u16),
        .content = &indices[0],
    }));

    state.bindings.vertex_buffers[1] = sg_make_buffer(&std.mem.zeroInit(sg_buffer_desc, .{
        .size = MaxParticles * @sizeOf(Vec3),
        .usage = .SG_USAGE_STREAM,
    }));

    var pipeline_desc = std.mem.zeroes(sg_pipeline_desc);
    pipeline_desc.layout.attrs[0].format = .SG_VERTEXFORMAT_FLOAT3;
    pipeline_desc.layout.attrs[1].format = .SG_VERTEXFORMAT_UBYTE4N;
    pipeline_desc.layout.attrs[2].format = .SG_VERTEXFORMAT_FLOAT3;
    pipeline_desc.layout.attrs[2].buffer_index = 1;
    pipeline_desc.layout.buffers[1].step_func = .SG_VERTEXSTEP_PER_INSTANCE;
    pipeline_desc.shader = sg_make_shader(shaders.instancing_shader_desc());
    pipeline_desc.index_type = .SG_INDEXTYPE_UINT16;
    pipeline_desc.depth_stencil.depth_compare_func = .SG_COMPAREFUNC_LESS_EQUAL;
    pipeline_desc.depth_stencil.depth_write_enabled = true;
    pipeline_desc.rasterizer.cull_mode = .SG_CULLMODE_BACK;
    pipeline_desc.rasterizer.sample_count = 4;
    state.pipeline = sg_make_pipeline(&pipeline_desc);
}

fn update() void {
    aya.debug.drawText("instancing", .{ .x = 10, .y = 20 }, null);
    aya.debug.drawTextFmt("cur particles: {}", .{cur_num_particles}, .{ .x = 10, .y = 40 }, null);

    const frame_time = 1.0 / 60.0;
    // emit new particles
    var i: u32 = 0;
    while (i < NumParticlesEmittedPerFrame) : (i += 1) {
        if (cur_num_particles < MaxParticles) {
            pos[cur_num_particles] = Vec3.init(0, 0, 0);
            vel[cur_num_particles] = Vec3.init(rand.float(f32) - 0.5, rand.float(f32) * 0.5 + 2.0, rand.float(f32) - 0.5);
            cur_num_particles += 1;
        } else {
            break;
        }
    }

    i = 0;
    // update particle positions
    while (i < cur_num_particles) : (i += 1) {
        vel[i].y -= 1.0 * frame_time;
        pos[i].x += vel[i].x * frame_time;
        pos[i].y += vel[i].y * frame_time;
        pos[i].z += vel[i].z * frame_time;
        // bounce back from 'ground'
        if (pos[i].y < -2.0) {
            pos[i].y = -1.8;
            vel[i].y = -vel[i].y;
            vel[i].x *= 0.8;
            vel[i].y *= 0.8;
            vel[i].z *= 0.8;
        }
    }

    // update instance data
    sg_update_buffer(state.bindings.vertex_buffers[1], &pos[0], @intCast(c_int, cur_num_particles * @sizeOf(Vec3)));
}

fn render() void {
    const width = sapp_width();
    const height = sapp_height();
    const w: f32 = @intToFloat(f32, width);
    const h: f32 = @intToFloat(f32, height);
    const radians = aya.math.toRadians(60.0);

    var proj = Mat4.createPerspective(radians, w / h, 0.01, 100.0);
    var view = Mat4.createLookAt(Vec3.init(0, 1.5, 8), Vec3.init(0, 0, 0), Vec3.init(0, 1, 0));
    var view_proj = Mat4.mul(proj, view);

    ry += 5.0 / 400.0;
    var params = InstanceParams{
        .mvp = Mat4.mul(view_proj, Mat4.createAngleAxis(Vec3.init(0, 1, 0), ry)),
    };

    aya.gfx.beginPass(.{});
    sg_apply_pipeline(state.pipeline);
    sg_apply_bindings(&state.bindings);
    sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &params, @sizeOf(InstanceParams));
    sg_draw(0, 24, @intCast(c_int, cur_num_particles));
    aya.gfx.endPass();
}
