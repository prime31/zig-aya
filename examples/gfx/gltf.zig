const std = @import("std");
const aya = @import("aya");
const zmesh = aya.zmesh;
const zm = aya.zm;
const wgpu = aya.wgpu;

const gltf_mesh = @import("gltf_mesh.zig");

const Vec = aya.utils.Vec;
const Mat = zm.Mat;

const CameraUniform = struct {
    world_to_clip: Mat,
    position: [3]f32 = [_]f32{ 0.0, 4.0, -4.0 },
    time: f32 = 0,
};

const ObjectUniform = struct {
    object_to_world: zm.Mat,
};

var gltf_loader: gltf_mesh.GltfLoader = undefined;
var frame_bind_group: aya.render.BindGroupHandle = undefined;
var object_bind_group: aya.render.BindGroupHandle = undefined;
var gltf_pipeline: aya.render.RenderPipelineHandle = undefined;
var vertex_buf: aya.render.BufferHandle = undefined;
var index_buf: aya.render.BufferHandle = undefined;
var depth_texv: aya.render.TextureViewHandle = undefined;
var texture: aya.render.TextureHandle = undefined;
var tex_view: aya.render.TextureViewHandle = undefined;
var sampler: aya.render.SamplerHandle = undefined;

var camera: struct {
    position: [3]f32 = .{ 0.0, 3.0, -6.0 },
    forward: [3]f32 = .{ 0.0, 0.0, 1.0 },
    pitch: f32 = 0.15 * std.math.pi,
    yaw: f32 = 0.0,
    cam_world_to_clip: Mat = zm.identity(),
} = .{};
var mouse: struct {
    cursor_pos: [2]f64 = .{ 0, 0 },
} = .{};

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    var gctx = aya.gctx;

    gltf_loader = gltf_mesh.GltfLoader.init();
    gltf_loader.appendGltf("examples/assets/models/DamagedHelmet.glb");
    gltf_loader.appendGltf("examples/assets/models/cube.glb");

    vertex_buf, index_buf = gltf_loader.generateBuffers();

    texture = gltf_loader.gltfs.slice()[0].textures[0].texture;
    tex_view = gltf_loader.gltfs.slice()[0].textures[0].texture_view;

    sampler = gctx.createSampler(&.{});

    const frame_bind_group_layout = gctx.createBindGroupLayout(&.{
        .label = "Frame BindGroupLayout", // Camera/Frame uniforms
        .entries = &.{
            .{ .visibility = .{ .vertex = true, .fragment = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = .true } },
        },
    });
    defer gctx.releaseResource(frame_bind_group_layout); // TODO: do we have to hold onto these?

    frame_bind_group = gctx.createBindGroup(frame_bind_group_layout, &.{
        .{ .buffer_handle = gctx.uniforms.buffer, .size = 256 },
    });

    const object_bind_group_layout = gctx.createBindGroupLayout(&.{
        .label = "Texture Bind Group",
        .entries = &.{
            .{ .visibility = .{ .vertex = true, .fragment = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = .true } },
            .{ .visibility = .{ .fragment = true }, .texture = .{} },
            .{ .visibility = .{ .fragment = true }, .sampler = .{} },
        },
    });
    defer gctx.releaseResource(object_bind_group_layout);

    object_bind_group = gctx.createBindGroup(object_bind_group_layout, &.{
        .{ .buffer_handle = gctx.uniforms.buffer, .size = 256 },
        .{ .texture_view_handle = tex_view },
        .{ .sampler_handle = sampler },
    });

    depth_texv = createDepthTexture();

    // pipeline
    gltf_pipeline = gctx.createPipelineSimple(
        &.{ gctx.lookupResource(frame_bind_group_layout).?, gctx.lookupResource(object_bind_group_layout).? },
        aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/gltf.wgsl") catch unreachable,
        @sizeOf(gltf_mesh.GltfVertex),
        &aya.gpu.vertexAttributesForType(gltf_mesh.GltfVertex).attributes,
        .{ .front_face = .cw, .cull_mode = .none },
        aya.render.GraphicsContext.swapchain_format,
        &.{
            .format = .depth32_float,
            .depth_write_enabled = .true,
            .depth_compare = .less,
        },
    );
}

fn shutdown() !void {
    gltf_loader.deinit();
}

fn update() !void {
    // Handle camera rotation with mouse.
    if (aya.mouse.pressed(.left)) {
        for (aya.getEventReader(aya.mouse.MouseMotion).read()) |evt| {
            camera.pitch += 0.0045 * evt.yrel;
            camera.yaw += 0.0045 * evt.xrel;
            camera.pitch = @min(camera.pitch, 0.48 * std.math.pi);
            camera.pitch = @max(camera.pitch, -0.48 * std.math.pi);
            camera.yaw = zm.modAngle(camera.yaw);
        }
    }

    // Handle camera movement with 'WASD' keys.
    {
        const speed = if (aya.kb.pressed(.lshift)) zm.f32x4s(10.0) else zm.f32x4s(5.0);
        const delta_time = zm.f32x4s(aya.time.dt());
        const transform = zm.mul(zm.rotationX(camera.pitch), zm.rotationY(camera.yaw));
        var forward = zm.normalize3(zm.mul(zm.f32x4(0.0, 0.0, 1.0, 0.0), transform));

        zm.storeArr3(&camera.forward, forward);

        const right = speed * delta_time * zm.normalize3(zm.cross3(zm.f32x4(0.0, 1.0, 0.0, 0.0), forward));
        forward = speed * delta_time * forward;

        var cam_pos = zm.loadArr3(camera.position);
        if (aya.kb.pressed(.w)) {
            cam_pos += forward;
        } else if (aya.kb.pressed(.s)) {
            cam_pos -= forward;
        }
        if (aya.kb.pressed(.d)) {
            cam_pos += right;
        } else if (aya.kb.pressed(.a)) {
            cam_pos -= right;
        }
        if (aya.kb.pressed(.q)) {
            cam_pos[1] -= 5.0 * aya.time.dt();
        } else if (aya.kb.pressed(.e)) {
            cam_pos[1] += 5.0 * aya.time.dt();
        }

        zm.storeArr3(&camera.position, cam_pos);
    }

    const fb_width = aya.gctx.surface_config.width;
    const fb_height = aya.gctx.surface_config.height;

    const cam_world_to_view = zm.lookToLh(
        zm.loadArr3(camera.position),
        zm.loadArr3(camera.forward),
        zm.f32x4(0.0, 1.0, 0.0, 0.0),
    );
    const cam_view_to_clip = zm.perspectiveFovLh(
        0.25 * std.math.pi,
        @as(f32, @floatFromInt(fb_width)) / @as(f32, @floatFromInt(fb_height)),
        0.01,
        200.0,
    );
    camera.cam_world_to_clip = zm.mul(cam_world_to_view, cam_view_to_clip);
}

fn render(ctx: *aya.render.RenderContext) !void {
    const pipline = aya.gctx.lookupResource(gltf_pipeline) orelse return;
    const bg = aya.gctx.lookupResource(frame_bind_group) orelse return;
    const object_bg = aya.gctx.lookupResource(object_bind_group) orelse return;
    const depth_view = aya.gctx.lookupResource(depth_texv) orelse return;
    const vb_info = aya.gctx.lookupResourceInfo(vertex_buf) orelse return;
    const ib_info = aya.gctx.lookupResourceInfo(index_buf) orelse return;

    // begin the render pass
    var pass = ctx.beginRenderPass(&.{
        .label = "Gltf Render Pass Encoder",
        .color_attachment_count = 1,
        .color_attachments = &.{
            .view = ctx.swapchain_view,
            .load_op = .clear,
            .store_op = .store,
            .clear_value = .{ .r = 0.2, .g = 0.2, .b = 0.3, .a = 1.0 },
        },
        .depth_stencil_attachment = &.{
            .view = depth_view,
            .depth_load_op = .clear,
            .depth_store_op = .store,
            .depth_clear_value = 1.0,
        },
    });

    pass.setPipeline(pipline);
    pass.setVertexBuffer(0, vb_info.gpuobj.?, 0, vb_info.size);
    pass.setIndexBuffer(ib_info.gpuobj.?, .uint32, 0, ib_info.size);

    // projection matrix uniform
    {
        const mem = aya.gctx.uniforms.allocate(CameraUniform, 1);
        mem.slice[0] = .{
            .world_to_clip = zm.transpose(camera.cam_world_to_clip),
            .position = camera.position,
            .time = aya.time.sinTime(),
        };
        pass.setBindGroup(0, bg, &.{mem.offset});
    }

    for (gltf_loader.gltfs.slice(), 0..) |gltf_root, i| {
        for (gltf_root.meshes) |mesh_root| {
            for (mesh_root.meshes) |mesh| {
                const object_to_world = blk: {
                    if (i == 0)
                        break :blk zm.mul(zm.rotationX(std.math.degreesToRadians(f32, 90)), zm.rotationY(std.math.degreesToRadians(f32, 180)));
                    break :blk zm.translation(2, 1, 1);
                };

                const mem = aya.gctx.uniforms.allocate(ObjectUniform, 1);
                mem.slice[0].object_to_world = zm.transpose(object_to_world);
                pass.setBindGroup(1, object_bg, &.{mem.offset});

                pass.drawIndexed(mesh.num_indices, 1, mesh.index_offset, @as(i32, @intCast(mesh.vertex_offset)), 0);
            }
        }
    }

    pass.end();
    pass.release();
}

// TODO: leaks the Texture
fn createDepthTexture() aya.render.TextureViewHandle {
    const tex = aya.gctx.createTextureConfig(&.{
        .usage = .{ .render_attachment = true },
        .dimension = .dim_2d,
        .size = .{
            .width = aya.gctx.surface_config.width,
            .height = aya.gctx.surface_config.height,
            .depth_or_array_layers = 1,
        },
        .format = .depth32_float,
        .mip_level_count = 1,
        .sample_count = 1,
    });
    return aya.gctx.createTextureView(tex, &.{});
}
