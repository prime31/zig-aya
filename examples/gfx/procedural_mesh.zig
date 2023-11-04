const std = @import("std");
const aya = @import("aya");
const zm = @import("zmath");
const zmesh = @import("zmesh");
const ig = @import("imgui");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

pub const GPUInterface = wgpu.dawn.Interface;

const App = aya.App;
const ResMut = aya.ResMut;
const Res = aya.Res;
const EventReader = aya.EventReader;

const Input = aya.Input;
const MouseButton = aya.MouseButton;
const MouseMotion = aya.MouseMotion;
const Scancode = aya.Scancode;

const Vertex = struct {
    position: [3]f32,
    normal: [3]f32,
};

const FrameUniforms = struct {
    world_to_clip: zm.Mat,
    camera_position: [3]f32,
};

const DrawUniforms = struct {
    object_to_world: zm.Mat,
    basecolor_roughness: [4]f32,
};

const Mesh = struct {
    index_offset: u32,
    vertex_offset: i32,
    num_indices: u32,
    num_vertices: u32,
};

const Drawable = struct {
    mesh_index: u32,
    position: [3]f32,
    basecolor_roughness: [4]f32,
};

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Startup, StartupSystem)
    // .addSystems(aya.PreUpdate, ImguiSystem)
        .addSystems(aya.Update, UpdateSystem)
        .run();
}

var state: struct {
    pipeline: zgpu.RenderPipelineHandle = undefined,
    bind_group: zgpu.BindGroupHandle = undefined,

    vertex_buffer: zgpu.BufferHandle = undefined,
    index_buffer: zgpu.BufferHandle = undefined,

    depth_texture: zgpu.TextureHandle = undefined,
    depth_texture_view: zgpu.TextureViewHandle = undefined,

    meshes: std.ArrayList(Mesh) = undefined,
    drawables: std.ArrayList(Drawable) = undefined,

    camera: struct {
        position: [3]f32 = .{ 0.0, 4.0, -4.0 },
        forward: [3]f32 = .{ 0.0, 0.0, 1.0 },
        pitch: f32 = 0.15 * std.math.pi,
        yaw: f32 = 0.0,
    } = .{},
    mouse: struct {
        cursor_pos: [2]f64 = .{ 0, 0 },
    } = .{},
} = .{};

const StartupSystem = struct {
    pub fn run(gctx_res: ResMut(zgpu.GraphicsContext)) void {
        const gctx = gctx_res.getAssertExists();

        const bind_group_layout = gctx.createBindGroupLayout(&.{
            zgpu.bufferEntry(0, .{ .fragment = true, .vertex = true }, .uniform, .true, 0),
        });
        defer gctx.releaseResource(bind_group_layout);

        const pipeline_layout = gctx.createPipelineLayout(&.{
            bind_group_layout,
            bind_group_layout,
        });
        defer gctx.releaseResource(pipeline_layout);

        // (Async) Create a render pipeline.
        {
            const shader_module = zgpu.createWgslShaderModule(gctx.device, @embedFile("mesh.wgsl"), null);
            defer shader_module.release();

            const color_targets = [_]wgpu.ColorTargetState{.{
                .format = zgpu.GraphicsContext.swapchain_format,
            }};

            const vertex_attributes = [_]wgpu.VertexAttribute{
                .{ .format = .float32x3, .offset = 0, .shader_location = 0 },
                .{ .format = .float32x3, .offset = @offsetOf(Vertex, "normal"), .shader_location = 1 },
            };
            const vertex_buffers = [_]wgpu.VertexBufferLayout{.{
                .array_stride = @sizeOf(Vertex),
                .step_mode = .vertex,
                .attribute_count = vertex_attributes.len,
                .attributes = &vertex_attributes,
            }};

            // Create a render pipeline.
            const pipeline_descriptor = wgpu.RenderPipeline.Descriptor{
                .vertex = .{
                    .module = shader_module,
                    .entry_point = "main_vert",
                    .buffer_count = vertex_buffers.len,
                    .buffers = &vertex_buffers,
                },
                .fragment = &.{
                    .module = shader_module,
                    .entry_point = "main_frag",
                    .target_count = color_targets.len,
                    .targets = &color_targets,
                },
                .primitive = .{
                    .cull_mode = .back,
                    .front_face = .cw,
                },
                .depth_stencil = &.{
                    .format = .depth32_float,
                    .depth_write_enabled = .true,
                    .depth_compare = .less,
                },
            };
            gctx.createRenderPipelineAsync(pipeline_layout, pipeline_descriptor, &state.pipeline);
        }

        state.bind_group = gctx.createBindGroup(bind_group_layout, &[_]zgpu.BindGroupEntryInfo{.{
            .binding = 0,
            .buffer_handle = gctx.uniforms.buffer,
            .offset = 0,
            .size = @max(@sizeOf(FrameUniforms), @sizeOf(DrawUniforms)),
        }});

        state.drawables = std.ArrayList(Drawable).init(aya.allocator);
        state.meshes = std.ArrayList(Mesh).init(aya.allocator);
        var meshes_indices = std.ArrayList(zmesh.Shape.IndexType).init(aya.allocator);
        var meshes_positions = std.ArrayList([3]f32).init(aya.allocator);
        var meshes_normals = std.ArrayList([3]f32).init(aya.allocator);
        initScene(&state.drawables, &state.meshes, &meshes_indices, &meshes_positions, &meshes_normals);

        const total_num_vertices = @as(u32, @intCast(meshes_positions.items.len));
        const total_num_indices = @as(u32, @intCast(meshes_indices.items.len));

        // Create a vertex buffer.
        state.vertex_buffer = gctx.createBuffer(.{
            .usage = .{ .copy_dst = true, .vertex = true },
            .size = total_num_vertices * @sizeOf(Vertex),
        });
        {
            var vertex_data = aya.mem.alloc(Vertex, total_num_vertices);
            defer aya.mem.free(vertex_data);

            for (meshes_positions.items, 0..) |_, i| {
                vertex_data[i].position = meshes_positions.items[i];
                vertex_data[i].normal = meshes_normals.items[i];
            }
            gctx.queue.writeBuffer(gctx.lookupResource(state.vertex_buffer).?, 0, vertex_data);
        }

        // Create an index buffer.
        state.index_buffer = gctx.createBuffer(.{
            .usage = .{ .copy_dst = true, .index = true },
            .size = total_num_indices * @sizeOf(zmesh.Shape.IndexType),
        });
        gctx.queue.writeBuffer(gctx.lookupResource(state.index_buffer).?, 0, meshes_indices.items);

        // Create a depth texture and its 'view'.
        const depth = createDepthTexture(gctx);
        state.depth_texture = depth.texture;
        state.depth_texture_view = depth.view;
    }
};

const UpdateSystem = struct {
    pub fn run(
        gctx_res: ResMut(zgpu.GraphicsContext),
        clear_color_res: ResMut(aya.ClearColor),
        mouse_buttons_res: Res(Input(MouseButton)),
        mouse_motion_events: EventReader(MouseMotion),
        keys_res: Res(Input(Scancode)),
    ) void {
        const gctx = gctx_res.getAssertExists();
        const fb_width = gctx.swapchain_descriptor.width;
        const fb_height = gctx.swapchain_descriptor.height;
        const color = clear_color_res.getAssertExists();
        const mouse_buttons: *const Input(MouseButton) = mouse_buttons_res.getAssertExists();
        const keys: *const Input(Scancode) = keys_res.getAssertExists();

        // Handle camera rotation with mouse.
        if (mouse_buttons.pressed(.left)) {
            for (mouse_motion_events.read()) |evt| {
                state.camera.pitch += 0.0025 * evt.yrel;
                state.camera.yaw += 0.0025 * evt.xrel;
                state.camera.pitch = @min(state.camera.pitch, 0.48 * std.math.pi);
                state.camera.pitch = @max(state.camera.pitch, -0.48 * std.math.pi);
                state.camera.yaw = zm.modAngle(state.camera.yaw);
            }
        }

        // Handle camera movement with 'WASD' keys.
        {
            const speed = zm.f32x4s(2.0);
            const delta_time = zm.f32x4s(gctx.stats.delta_time);
            const transform = zm.mul(zm.rotationX(state.camera.pitch), zm.rotationY(state.camera.yaw));
            var forward = zm.normalize3(zm.mul(zm.f32x4(0.0, 0.0, 1.0, 0.0), transform));

            zm.storeArr3(&state.camera.forward, forward);

            const right = speed * delta_time * zm.normalize3(zm.cross3(zm.f32x4(0.0, 1.0, 0.0, 0.0), forward));
            forward = speed * delta_time * forward;

            var cam_pos = zm.loadArr3(state.camera.position);

            if (keys.pressed(.w)) {
                cam_pos += forward;
            } else if (keys.pressed(.s)) {
                cam_pos -= forward;
            }
            if (keys.pressed(.d)) {
                cam_pos += right;
            } else if (keys.pressed(.a)) {
                cam_pos -= right;
            }

            zm.storeArr3(&state.camera.position, cam_pos);
        }

        const cam_world_to_view = zm.lookToLh(
            zm.loadArr3(state.camera.position),
            zm.loadArr3(state.camera.forward),
            zm.f32x4(0.0, 1.0, 0.0, 0.0),
        );
        const cam_view_to_clip = zm.perspectiveFovLh(
            0.25 * std.math.pi,
            @as(f32, @floatFromInt(fb_width)) / @as(f32, @floatFromInt(fb_height)),
            0.01,
            200.0,
        );
        const cam_world_to_clip = zm.mul(cam_world_to_view, cam_view_to_clip);

        const back_buffer_view = gctx.swapchain.getCurrentTextureView() orelse return;
        defer back_buffer_view.release();

        const commands = commands: {
            const encoder = gctx.device.createCommandEncoder(null);
            defer encoder.release();

            pass: {
                const vb_info = gctx.lookupResourceInfo(state.vertex_buffer) orelse break :pass;
                const ib_info = gctx.lookupResourceInfo(state.index_buffer) orelse break :pass;
                const pipeline = gctx.lookupResource(state.pipeline) orelse break :pass;
                const bind_group = gctx.lookupResource(state.bind_group) orelse break :pass;
                const depth_view = gctx.lookupResource(state.depth_texture_view) orelse break :pass;

                const color_attachments = [_]wgpu.RenderPassColorAttachment{.{
                    .view = back_buffer_view,
                    .load_op = .clear,
                    .store_op = .store,
                    .clear_value = zgpu.wgpu.Color{ .r = @floatCast(color.r), .g = @floatCast(color.g), .b = @floatCast(color.b), .a = @floatCast(color.a) },
                }};
                const depth_attachment = wgpu.RenderPassDepthStencilAttachment{
                    .view = depth_view,
                    .depth_load_op = .clear,
                    .depth_store_op = .store,
                    .depth_clear_value = 1.0,
                };
                const render_pass_info = wgpu.RenderPassDescriptor{
                    .color_attachment_count = color_attachments.len,
                    .color_attachments = &color_attachments,
                    .depth_stencil_attachment = &depth_attachment,
                };
                const render_pass = encoder.beginRenderPass(&render_pass_info);
                defer zgpu.endReleasePass(render_pass);

                // Render using our pipeline
                render_pass.setVertexBuffer(0, vb_info.gpuobj.?, 0, vb_info.size);
                render_pass.setIndexBuffer(
                    ib_info.gpuobj.?,
                    if (zmesh.Shape.IndexType == u16) .uint16 else .uint32,
                    0,
                    ib_info.size,
                );

                render_pass.setPipeline(pipeline);

                // Update "world to clip" (camera) xform.
                {
                    const mem = gctx.uniformsAllocate(FrameUniforms, 1);
                    mem.slice[0].world_to_clip = zm.transpose(cam_world_to_clip);
                    mem.slice[0].camera_position = state.camera.position;

                    render_pass.setBindGroup(0, bind_group, &.{mem.offset});
                }

                for (state.drawables.items) |drawable| {
                    // Update "object to world" xform.
                    const object_to_world = zm.translationV(zm.loadArr3(drawable.position));

                    const mem = gctx.uniformsAllocate(DrawUniforms, 1);
                    mem.slice[0].object_to_world = zm.transpose(object_to_world);
                    mem.slice[0].basecolor_roughness = drawable.basecolor_roughness;

                    render_pass.setBindGroup(1, bind_group, &.{mem.offset});

                    // Draw.
                    render_pass.drawIndexed(
                        state.meshes.items[drawable.mesh_index].num_indices,
                        1,
                        state.meshes.items[drawable.mesh_index].index_offset,
                        state.meshes.items[drawable.mesh_index].vertex_offset,
                        0,
                    );
                }
            }

            break :commands encoder.finish(null);
        };
        defer commands.release();

        gctx.submit(&.{commands});
    }
};

const ImguiSystem = struct {
    pub fn run(gctx_res: ResMut(zgpu.GraphicsContext)) void {
        const gctx = gctx_res.getAssertExists();

        ig.igSetNextWindowPos(.{ .x = 20, .y = 20 }, ig.ImGuiCond_Always, .{ .x = 0, .y = 0 });
        if (ig.igBegin("Demo", null, ig.ImGuiWindowFlags_None)) {
            defer ig.igEnd();

            ig.igBulletText("Average: %f ms/frame\nFPS: %f\nDelta time: %f", gctx.stats.average_cpu_time, gctx.stats.fps, gctx.stats.delta_time);
            ig.igSpacing();
        }
    }
};

fn createDepthTexture(gctx: *zgpu.GraphicsContext) struct {
    texture: zgpu.TextureHandle,
    view: zgpu.TextureViewHandle,
} {
    const texture = gctx.createTexture(.{
        .usage = .{ .render_attachment = true },
        .dimension = .dimension_2d,
        .size = .{
            .width = gctx.swapchain_descriptor.width,
            .height = gctx.swapchain_descriptor.height,
            .depth_or_array_layers = 1,
        },
        .format = .depth32_float,
        .mip_level_count = 1,
        .sample_count = 1,
    });
    const view = gctx.createTextureView(texture, .{});
    return .{ .texture = texture, .view = view };
}

fn initScene(
    drawables: *std.ArrayList(Drawable),
    meshes: *std.ArrayList(Mesh),
    meshes_indices: *std.ArrayList(zmesh.Shape.IndexType),
    meshes_positions: *std.ArrayList([3]f32),
    meshes_normals: *std.ArrayList([3]f32),
) void {
    zmesh.init(aya.tmp_allocator);
    defer zmesh.deinit();

    // Trefoil knot.
    {
        var mesh = zmesh.Shape.initTrefoilKnot(10, 128, 0.8);
        defer mesh.deinit();
        mesh.rotate(std.math.pi * 0.5, 1.0, 0.0, 0.0);
        mesh.unweld();
        mesh.computeNormals();

        drawables.append(.{
            .mesh_index = @as(u32, @intCast(meshes.items.len)),
            .position = .{ 0, 1, 0 },
            .basecolor_roughness = .{ 0.0, 0.7, 0.0, 0.6 },
        }) catch unreachable;

        appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    }
    // Parametric sphere.
    {
        var mesh = zmesh.Shape.initParametricSphere(20, 20);
        defer mesh.deinit();
        mesh.rotate(std.math.pi * 0.5, 1.0, 0.0, 0.0);
        mesh.unweld();
        mesh.computeNormals();

        drawables.append(.{
            .mesh_index = @as(u32, @intCast(meshes.items.len)),
            .position = .{ 3, 1, 0 },
            .basecolor_roughness = .{ 0.7, 0.0, 0.0, 0.2 },
        }) catch unreachable;

        appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    }
    // Icosahedron.
    {
        var mesh = zmesh.Shape.initIcosahedron();
        defer mesh.deinit();
        mesh.unweld();
        mesh.computeNormals();

        drawables.append(.{
            .mesh_index = @as(u32, @intCast(meshes.items.len)),
            .position = .{ -3, 1, 0 },
            .basecolor_roughness = .{ 0.7, 0.6, 0.0, 0.4 },
        }) catch unreachable;

        appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    }
    // Dodecahedron.
    {
        var mesh = zmesh.Shape.initDodecahedron();
        defer mesh.deinit();
        mesh.unweld();
        mesh.computeNormals();

        drawables.append(.{
            .mesh_index = @as(u32, @intCast(meshes.items.len)),
            .position = .{ 0, 1, 3 },
            .basecolor_roughness = .{ 0.0, 0.1, 1.0, 0.2 },
        }) catch unreachable;

        appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    }
    // Cylinder with top and bottom caps.
    {
        var disk = zmesh.Shape.initParametricDisk(10, 2);
        defer disk.deinit();
        disk.invert(0, 0);

        var cylinder = zmesh.Shape.initCylinder(10, 4);
        defer cylinder.deinit();

        cylinder.merge(disk);
        cylinder.translate(0, 0, -1);
        disk.invert(0, 0);
        cylinder.merge(disk);

        cylinder.scale(0.5, 0.5, 2);
        cylinder.rotate(std.math.pi * 0.5, 1.0, 0.0, 0.0);

        cylinder.unweld();
        cylinder.computeNormals();

        drawables.append(.{
            .mesh_index = @as(u32, @intCast(meshes.items.len)),
            .position = .{ -3, 0, 3 },
            .basecolor_roughness = .{ 1.0, 0.0, 0.0, 0.3 },
        }) catch unreachable;

        appendMesh(cylinder, meshes, meshes_indices, meshes_positions, meshes_normals);
    }
    // Torus.
    {
        var mesh = zmesh.Shape.initTorus(10, 20, 0.2);
        defer mesh.deinit();

        drawables.append(.{
            .mesh_index = @as(u32, @intCast(meshes.items.len)),
            .position = .{ 3, 1.5, 3 },
            .basecolor_roughness = .{ 1.0, 0.5, 0.0, 0.2 },
        }) catch unreachable;

        appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    }
    // // Subdivided sphere.
    // {
    //     var mesh = zmesh.Shape.initSubdividedSphere(3);
    //     defer mesh.deinit();
    //     mesh.unweld();
    //     mesh.computeNormals();

    //     drawables.append(.{
    //         .mesh_index = @as(u32, @intCast(meshes.items.len)),
    //         .position = .{ 3, 1, 6 },
    //         .basecolor_roughness = .{ 0.0, 1.0, 0.0, 0.2 },
    //     }) catch unreachable;

    //     appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    // }
    // // Tetrahedron.
    // {
    //     var mesh = zmesh.Shape.initTetrahedron();
    //     defer mesh.deinit();
    //     mesh.unweld();
    //     mesh.computeNormals();

    //     drawables.append(.{
    //         .mesh_index = @as(u32, @intCast(meshes.items.len)),
    //         .position = .{ 0, 0.5, 6 },
    //         .basecolor_roughness = .{ 1.0, 0.0, 1.0, 0.2 },
    //     }) catch unreachable;

    //     appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    // }
    // // Octahedron.
    // {
    //     var mesh = zmesh.Shape.initOctahedron();
    //     defer mesh.deinit();
    //     mesh.unweld();
    //     mesh.computeNormals();

    //     drawables.append(.{
    //         .mesh_index = @as(u32, @intCast(meshes.items.len)),
    //         .position = .{ -3, 1, 6 },
    //         .basecolor_roughness = .{ 0.2, 0.0, 1.0, 0.2 },
    //     }) catch unreachable;

    //     appendMesh(mesh, meshes, meshes_indices, meshes_positions, meshes_normals);
    // }
    // // Rock.
    // {
    //     var rock = zmesh.Shape.initRock(123, 4);
    //     defer rock.deinit();
    //     rock.unweld();
    //     rock.computeNormals();

    //     drawables.append(.{
    //         .mesh_index = @as(u32, @intCast(meshes.items.len)),
    //         .position = .{ -6, 0, 3 },
    //         .basecolor_roughness = .{ 1.0, 1.0, 1.0, 1.0 },
    //     }) catch unreachable;

    //     appendMesh(rock, meshes, meshes_indices, meshes_positions, meshes_normals);
    // }

}

fn appendMesh(
    mesh: zmesh.Shape,
    meshes: *std.ArrayList(Mesh),
    meshes_indices: *std.ArrayList(zmesh.Shape.IndexType),
    meshes_positions: *std.ArrayList([3]f32),
    meshes_normals: *std.ArrayList([3]f32),
) void {
    meshes.append(.{
        .index_offset = @as(u32, @intCast(meshes_indices.items.len)),
        .vertex_offset = @as(i32, @intCast(meshes_positions.items.len)),
        .num_indices = @as(u32, @intCast(mesh.indices.len)),
        .num_vertices = @as(u32, @intCast(mesh.positions.len)),
    }) catch unreachable;

    meshes_indices.appendSlice(mesh.indices) catch unreachable;
    meshes_positions.appendSlice(mesh.positions) catch unreachable;
    meshes_normals.appendSlice(mesh.normals.?) catch unreachable;
}
