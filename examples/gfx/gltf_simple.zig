const std = @import("std");
const zmesh = @import("zmesh");
const zm = @import("zmath");
const aya = @import("aya");
const wgpu = aya.wgpu;

const Vec = aya.utils.Vec;
const PrimitiveMap = std.AutoHashMap(Primitive, Vec(aya.render.BindGroupHandle));

const Vec2 = aya.math.Vec2;
const Vec3 = aya.math.Vec3;
const Mat = zm.Mat;
const Quad = aya.math.Quad;
const Rect = aya.math.Rect;
const RectI = aya.math.RectI;
const Color = aya.math.Color;

const CameraUniform = struct {
    world_to_clip: Mat,
    position: [3]f32 = [_]f32{ 0.0, 4.0, -4.0 },
    time: f32 = 0,
};

const ObjectUniform = struct {
    object_to_world: zm.Mat,
};

const GltfVertex = struct {
    position: [3]f32,
    normal: [3]f32,
    texcoords0: [2]f32,
    tangent: [4]f32,
};

const GltfMesh = struct {
    vertex_offset: u32,
    num_lods: u32,
    lods: [8]MeshLod,
};

const MeshLod = struct {
    index_offset: u32,
    num_indices: u32,
};

var all_meshes: std.ArrayList(GltfMesh) = undefined;
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

    // load the gltf model and texture
    loadGltf();

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
    const pos_norm_attribs = [_]wgpu.VertexAttribute{
        .{ .format = .float32x3, .offset = 0, .shader_location = 0 },
        .{ .format = .float32x3, .offset = @offsetOf(GltfVertex, "normal"), .shader_location = 1 },
        .{ .format = .float32x2, .offset = @offsetOf(GltfVertex, "texcoords0"), .shader_location = 2 },
    };

    gltf_pipeline = gctx.createPipelineSimple(
        &.{ gctx.lookupResource(frame_bind_group_layout).?, gctx.lookupResource(object_bind_group_layout).? },
        aya.fs.readZ(aya.mem.tmp_allocator, "examples/assets/shaders/gltf.wgsl") catch unreachable,
        @sizeOf(GltfVertex),
        pos_norm_attribs[0..],
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
    all_meshes.deinit();
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

    pass.setVertexBuffer(0, vb_info.gpuobj.?, 0, vb_info.size);
    pass.setIndexBuffer(ib_info.gpuobj.?, .uint32, 0, ib_info.size);
    pass.setPipeline(pipline);

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

    for (all_meshes.items) |mesh| {
        const object_to_world = zm.scaling(10, 10, 10);

        const mem = aya.gctx.uniforms.allocate(ObjectUniform, 1);
        mem.slice[0].object_to_world = zm.transpose(object_to_world);
        pass.setBindGroup(1, object_bg, &.{mem.offset});

        pass.drawIndexed(mesh.lods[0].num_indices, 1, mesh.lods[0].index_offset, @as(i32, @intCast(mesh.vertex_offset)), 0);
    }

    pass.end();
    pass.release();
}

const Node = zmesh.io.zcgltf.Node;
const Mesh = zmesh.io.zcgltf.Mesh;
const Primitive = zmesh.io.zcgltf.Primitive;
const BufferView = zmesh.io.zcgltf.BufferView;
const Accessor = zmesh.io.zcgltf.Accessor;

fn loadGltf() void {
    var arena_allocator_state = std.heap.ArenaAllocator.init(aya.mem.allocator);
    defer arena_allocator_state.deinit();
    const arena_allocator = arena_allocator_state.allocator();

    zmesh.init(arena_allocator);
    defer zmesh.deinit();

    all_meshes = std.ArrayList(GltfMesh).init(aya.mem.allocator);
    var all_vertices = std.ArrayList(GltfVertex).init(arena_allocator);
    var all_indices = std.ArrayList(u32).init(arena_allocator);

    loadMesh(arena_allocator, "examples/assets/models/avocado.glb", &all_vertices, &all_indices, 0) catch unreachable;

    // Create a vertex buffer.
    {
        var vertex_data = std.ArrayList(GltfVertex).init(arena_allocator);
        defer vertex_data.deinit();
        vertex_data.resize(all_vertices.items.len) catch unreachable;

        for (all_vertices.items, 0..) |_, i| {
            vertex_data.items[i].position = all_vertices.items[i].position;
            vertex_data.items[i].normal = all_vertices.items[i].normal;
            vertex_data.items[i].texcoords0 = all_vertices.items[i].texcoords0;
        }

        vertex_buf = aya.gctx.createBufferInit(null, .{ .copy_dst = true, .vertex = true }, GltfVertex, vertex_data.items);
    }

    // Create an index buffer.
    index_buf = aya.gctx.createBufferInit(null, .{ .copy_dst = true, .index = true }, u32, all_indices.items);
}

fn loadMesh(
    arena: std.mem.Allocator,
    path: [:0]const u8,
    all_vertices: *std.ArrayList(GltfVertex),
    all_indices: *std.ArrayList(u32),
    generate_lods: u32,
) !void {
    var indices = std.ArrayList(u32).init(arena);
    var positions = std.ArrayList([3]f32).init(arena);
    var normals = std.ArrayList([3]f32).init(arena);
    var texcoords0 = std.ArrayList([2]f32).init(arena);
    var tangents = std.ArrayList([4]f32).init(arena);

    const pre_indices_len = all_indices.items.len;
    const pre_positions_len = all_vertices.items.len;

    const data = try zmesh.io.parseAndLoadFile(path);
    defer zmesh.io.freeData(data);

    loadGltfTexture(data.textures.?[0]);

    try zmesh.io.appendMeshPrimitive(data, 0, 0, &indices, &positions, &normals, &texcoords0, &tangents, null);

    var mesh = GltfMesh{
        .vertex_offset = @as(u32, @intCast(pre_positions_len)),
        .num_lods = 1,
        .lods = undefined,
    };

    mesh.lods[0] = .{
        .index_offset = @as(u32, @intCast(pre_indices_len)),
        .num_indices = @as(u32, @intCast(indices.items.len)),
    };

    if (generate_lods > 0) {
        var all_lods_indices = std.ArrayList(u32).init(arena);

        var lod_index: u32 = 1;
        while (lod_index < generate_lods) : (lod_index += 1) {
            mesh.num_lods += 1;

            const threshold: f32 = 1.0 - @as(f32, @floatFromInt(lod_index)) / @as(f32, @floatFromInt(4));
            const target_index_count: usize = @as(usize, @intFromFloat(@as(f32, @floatFromInt(indices.items.len)) * threshold));
            const target_error: f32 = 1e-2;

            var lod_indices = std.ArrayList(u32).init(arena);
            lod_indices.resize(indices.items.len) catch unreachable;
            var lod_error: f32 = 0.0;
            const lod_indices_count = zmesh.opt.simplifySloppy(
                [3]f32,
                lod_indices.items,
                indices.items,
                indices.items.len,
                positions.items,
                positions.items.len,
                target_index_count,
                target_error,
                &lod_error,
            );
            lod_indices.resize(lod_indices_count) catch unreachable;

            mesh.lods[lod_index] = .{
                .index_offset = mesh.lods[lod_index - 1].index_offset + mesh.lods[lod_index - 1].num_indices,
                .num_indices = @as(u32, @intCast(lod_indices_count)),
            };

            all_lods_indices.appendSlice(lod_indices.items) catch unreachable;
        }

        indices.appendSlice(all_lods_indices.items) catch unreachable;
    }

    all_meshes.append(mesh) catch unreachable;

    try all_indices.ensureTotalCapacity(indices.items.len);
    for (indices.items) |mesh_index| {
        all_indices.appendAssumeCapacity(mesh_index);
    }

    try all_vertices.ensureTotalCapacity(positions.items.len);
    for (positions.items, 0..) |_, index| {
        all_vertices.appendAssumeCapacity(.{
            .position = positions.items[index],
            .normal = normals.items[index],
            .texcoords0 = texcoords0.items[index],
            .tangent = tangents.items[index],
        });
    }
}

fn loadGltfTexture(gltf_texture: zmesh.io.zcgltf.Texture) void {
    const image = gltf_texture.image orelse return;
    const buffer_view = image.buffer_view orelse return;
    const data = buffer_view.buffer.data orelse return;

    var x: c_int = undefined;
    var y: c_int = undefined;
    const buffer_bytes = @as([*]const u8, @ptrCast(data))[buffer_view.offset .. buffer_view.offset + buffer_view.size];
    const stb_image = aya.stb.stbi_load_from_memory(buffer_bytes.ptr, @intCast(buffer_bytes.len), &x, &y, null, 4);
    defer aya.stb.stbi_image_free(stb_image);

    texture = aya.gctx.createTexture(@intCast(x), @intCast(y), .rgba8_unorm);
    const image_data = stb_image[0..@as(usize, @intCast(x * y * 4))];
    aya.gctx.writeTexture(texture, u8, image_data);
    tex_view = aya.gctx.createTextureView(texture, &.{});
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
