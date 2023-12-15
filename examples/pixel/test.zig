const std = @import("std");
const aya = @import("aya");
const zm = aya.zm;
const wgpu = aya.wgpu;

const Mat = zm.Mat;
const Vec2 = aya.math.Vec2;
const Vec3 = aya.math.Vec3;
const Mat32 = aya.math.Mat32;

const Vertex = extern struct {
    position: [3]f32,
    uv: [2]f32,
};

var state: struct {
    renderer: Renderer,
    camera: Camera,
    quad_mesh: QuadMesh,
    renderables: [3]Renderable,

    checker_tex: aya.render.TextureHandle,
    checker_view: aya.render.TextureViewHandle,
    layer1_tex: aya.render.TextureHandle,
    layer2_tex: aya.render.TextureHandle,
    layer3_tex: aya.render.TextureHandle,
} = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() !void {
    state.renderer = Renderer.init();
    state.camera = .{};
    state.quad_mesh = QuadMesh.init();

    state.checker_tex = aya.gpu.createCheckerTexture(4);
    state.checker_view = aya.gctx.createTextureView(state.checker_tex, &.{});

    state.layer1_tex = aya.gctx.createTextureFromFile("examples/pixel/layer1.png");
    state.layer2_tex = aya.gctx.createTextureFromFile("examples/pixel/layer2.png");
    state.layer3_tex = aya.gctx.createTextureFromFile("examples/pixel/layer3.png");

    state.renderables[0] = Renderable.init(state.layer1_tex);
    state.renderables[0].pos.z = 3;
    state.renderables[1] = Renderable.init(state.layer2_tex);
    state.renderables[1].pos.z = 2;
    state.renderables[2] = Renderable.init(state.layer3_tex);
    state.renderables[2].pos.z = 1.99;
}

fn shutdown() !void {
    aya.gctx.releaseResource(state.checker_tex);
    aya.gctx.releaseResource(state.checker_view);
    aya.gctx.releaseResource(state.layer1_tex);
    aya.gctx.releaseResource(state.layer2_tex);
    aya.gctx.releaseResource(state.layer3_tex);
}

fn update() !void {
    state.camera.update();

    for (&state.renderables) |*renderable| {
        aya.ig.igPushID_Ptr(renderable);
        defer aya.ig.igPopID();

        _ = aya.ig.igCheckbox("Enabled", &renderable.enabled);
        _ = aya.ig.igDragFloat3("pos", &renderable.pos.x, 1, -1000, 1000, null, aya.ig.ImGuiSliderFlags_None);
    }
}

fn render(ctx: *aya.render.RenderContext) !void {
    const pass = state.renderer.beginPass(state.camera, ctx);
    state.quad_mesh.setBuffers(pass);

    for (state.renderables) |renderable| {
        renderable.draw(pass);
    }

    pass.end();
    pass.release();
}

pub const Renderable = struct {
    material: Material,
    pos: Vec3 = .{},
    scale: Vec2 = .{ .x = (280 / 272) * 10, .y = 1 * 10 }, // 272 × 280
    enabled: bool = true,

    pub fn init(tex: aya.render.TextureHandle) Renderable {
        return .{
            .material = Material.init(tex),
        };
    }

    pub fn draw(self: Renderable, pass: wgpu.RenderPassEncoder) void {
        if (!self.enabled) return;
        const object_bg = aya.gctx.lookupResource(self.material.object_bind_group) orelse return;

        const object_to_world = zm.mul(zm.scaling(self.scale.x, self.scale.y, 1), zm.translation(self.pos.x, self.pos.y, self.pos.z));

        const mem = aya.gctx.uniforms.allocate(ObjectUniform, 1);
        mem.slice[0].object_to_world = zm.transpose(object_to_world);
        pass.setBindGroup(1, object_bg, &.{mem.offset});

        pass.drawIndexed(6, 1, 0, 0, 0);
    }
};

pub const QuadMesh = struct {
    vbuff: aya.render.BufferHandle,
    ibuff: aya.render.BufferHandle,

    pub fn init() QuadMesh {
        // vertex buffer
        const vertex_data = [_]Vertex{
            .{ .position = .{ 0, 1, 0 }, .uv = .{ 0.0, 0.0 } }, // tl
            .{ .position = .{ 1, 1, 0 }, .uv = .{ 1.0, 0.0 } }, // tr
            .{ .position = .{ 1, 0, 0 }, .uv = .{ 1.0, 1.0 } }, // br
            .{ .position = .{ 0, 0, 0 }, .uv = .{ 0.0, 1.0 } }, // bl
        };
        const vbuff = aya.gctx.createBufferInit(null, .{ .copy_dst = true, .vertex = true }, Vertex, &vertex_data);

        // index buffer
        const index_data = [_]u16{ 0, 1, 3, 1, 2, 3 };
        const ibuff = aya.gctx.createBufferInit(null, .{ .copy_dst = true, .index = true }, u16, &index_data);

        return .{
            .vbuff = vbuff,
            .ibuff = ibuff,
        };
    }

    pub fn setBuffers(self: QuadMesh, pass: wgpu.RenderPassEncoder) void {
        const vb_info = aya.gctx.lookupResourceInfo(self.vbuff) orelse return;
        const ib_info = aya.gctx.lookupResourceInfo(self.ibuff) orelse return;

        pass.setVertexBuffer(0, vb_info.gpuobj.?, 0, vb_info.size);
        pass.setIndexBuffer(ib_info.gpuobj.?, .uint16, 0, ib_info.size);
    }
};

pub const Material = struct {
    object_bind_group: aya.render.BindGroupHandle, // bind group #1
    tex_view: aya.render.TextureViewHandle,

    pub fn init(tex: aya.render.TextureHandle) Material {
        const object_bind_group_layout = aya.gctx.createBindGroupLayout(&.{
            .label = "Texture Bind Group",
            .entries = &.{
                .{ .visibility = .{ .vertex = true, .fragment = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = .true } },
                .{ .visibility = .{ .fragment = true }, .texture = .{} },
                .{ .visibility = .{ .fragment = true }, .sampler = .{} },
            },
        });
        defer aya.gctx.releaseResource(object_bind_group_layout);

        const tex_view = aya.gctx.createTextureView(tex, &.{});
        const object_bind_group = aya.gctx.createBindGroup(object_bind_group_layout, &.{
            .{ .buffer_handle = aya.gctx.uniforms.buffer, .size = 256 },
            .{ .texture_view_handle = tex_view },
            .{ .sampler_handle = aya.gctx.createSampler(&.{}) },
        });

        return .{
            .object_bind_group = object_bind_group,
            .tex_view = tex_view,
        };
    }
};

pub const Renderer = struct {
    frame_bind_group: aya.render.BindGroupHandle, // bind group #0
    depth_tex: aya.render.TextureHandle,
    depth_view: aya.render.TextureViewHandle,
    pipeline: aya.render.RenderPipelineHandle,

    pub fn init() Renderer {
        // bind group
        const frame_bind_group_layout = aya.gctx.createBindGroupLayout(&.{
            .label = "Frame BindGroupLayout", // Camera/Frame uniforms
            .entries = &.{
                .{ .visibility = .{ .vertex = true, .fragment = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = .true } },
            },
        });
        defer aya.gctx.releaseResource(frame_bind_group_layout); // TODO: do we have to hold onto these?

        const frame_bind_group = aya.gctx.createBindGroup(frame_bind_group_layout, &.{
            .{ .buffer_handle = aya.gctx.uniforms.buffer, .size = 256 },
        });

        // depth texture
        const depth_tex = aya.gctx.createTextureConfig(&.{
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

        // pipeline
        const object_bind_group_layout = aya.gctx.createBindGroupLayout(&.{
            .label = "Texture Bind Group",
            .entries = &.{
                .{ .visibility = .{ .vertex = true, .fragment = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = .true } },
                .{ .visibility = .{ .fragment = true }, .texture = .{} },
                .{ .visibility = .{ .fragment = true }, .sampler = .{} },
            },
        });
        defer aya.gctx.releaseResource(object_bind_group_layout);

        const pipeline = createPipeline(
            &.{ aya.gctx.lookupResource(frame_bind_group_layout).?, aya.gctx.lookupResource(object_bind_group_layout).? },
        );

        return .{
            .frame_bind_group = frame_bind_group,
            .depth_tex = depth_tex,
            .depth_view = aya.gctx.createTextureView(depth_tex, &.{}),
            .pipeline = pipeline,
        };
    }

    fn createPipeline(bgls: []const wgpu.BindGroupLayout) aya.render.RenderPipelineHandle {
        const pipeline_layout = aya.gctx.device.createPipelineLayout(&.{
            .bind_group_layout_count = bgls.len,
            .bind_group_layouts = bgls.ptr,
        });
        defer pipeline_layout.release();

        const shader_source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/pixel/pixel.wgsl") catch unreachable;
        const shader_module = aya.gpu.createWgslShaderModule(shader_source, null);
        defer shader_module.release();

        const color_targets = [_]wgpu.ColorTargetState{.{
            .format = aya.render.GraphicsContext.swapchain_format,
            .blend = &wgpu.BlendState.alpha_blending,
        }};

        const vertex_attribs: []const wgpu.VertexAttribute = &aya.gpu.vertexAttributesForType(Vertex).attributes;
        const vertex_buffers = [_]wgpu.VertexBufferLayout{.{
            .array_stride = @sizeOf(Vertex),
            .attribute_count = @intCast(vertex_attribs.len),
            .attributes = vertex_attribs.ptr,
        }};

        const constants: [1]wgpu.ConstantEntry = .{
            wgpu.ConstantEntry{ .key = "uv_type", .value = 1 },
        };

        const pipe_desc = wgpu.RenderPipelineDescriptor{
            .layout = pipeline_layout,
            .vertex = wgpu.VertexState{
                .module = shader_module,
                .entry_point = "vs_main",
                .buffer_count = vertex_buffers.len,
                .buffers = &vertex_buffers,
            },
            .fragment = &wgpu.FragmentState{
                .module = shader_module,
                .entry_point = "fs_main",
                .target_count = color_targets.len,
                .targets = &color_targets,
                .constant_count = constants.len,
                .constants = &constants,
            },
            .depth_stencil = &.{
                .format = .depth32_float,
                .depth_write_enabled = .true,
                .depth_compare = .less,
            },
            .primitive = .{ .front_face = .cw, .cull_mode = .none },
        };

        return aya.gctx.pools.render_pipeline_pool.addResource(aya.gctx.*, .{
            .gpuobj = aya.gctx.device.createRenderPipeline(&pipe_desc),
        });
    }

    pub fn beginPass(self: Renderer, camera: Camera, ctx: *aya.render.RenderContext) wgpu.RenderPassEncoder {
        const pipline = aya.gctx.lookupResource(self.pipeline) orelse unreachable;
        const depth_view = aya.gctx.lookupResource(self.depth_view) orelse unreachable;
        const bg = aya.gctx.lookupResource(self.frame_bind_group) orelse unreachable;

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

        // projection matrix uniform
        {
            const mem = aya.gctx.uniforms.allocate(CameraUniform, 1);
            mem.slice[0] = .{
                .world_to_clip = zm.transpose(camera.cam_world_to_clip),
                .position = camera.position,
                .uv_type = camera.uv_type,
            };
            pass.setBindGroup(0, bg, &.{mem.offset});
        }

        pass.setPipeline(pipline);

        return pass;
    }
};

pub const Camera = struct {
    position: [3]f32 = .{ 5, 5, -6.0 },
    forward: [3]f32 = .{ 0.0, 0.0, 1.0 },
    pitch: f32 = 0.0 * std.math.pi,
    yaw: f32 = 0.0,
    fov: f32 = 70,
    cam_world_to_clip: Mat = zm.identity(),
    uv_type: i32 = 0,

    pub fn update(self: *Camera) void {
        self.imgui();

        // Handle camera rotation with mouse.
        if (aya.mouse.pressed(.left)) {
            for (aya.getEventReader(aya.mouse.MouseMotion).read()) |evt| {
                self.pitch += 0.0045 * evt.yrel;
                self.yaw += 0.0045 * evt.xrel;
                self.pitch = @min(self.pitch, 0.48 * std.math.pi);
                self.pitch = @max(self.pitch, -0.48 * std.math.pi);
                self.yaw = zm.modAngle(self.yaw);
            }
        }

        // Handle camera movement with 'WASD' keys.
        {
            const speed = if (aya.kb.pressed(.lshift)) zm.f32x4s(10.0) else zm.f32x4s(5.0);
            const delta_time = zm.f32x4s(aya.time.dt());
            const transform = zm.mul(zm.rotationX(self.pitch), zm.rotationY(self.yaw));
            var forward = zm.normalize3(zm.mul(zm.f32x4(0.0, 0.0, 1.0, 0.0), transform));

            zm.storeArr3(&self.forward, forward);

            const right = speed * delta_time * zm.normalize3(zm.cross3(zm.f32x4(0.0, 1.0, 0.0, 0.0), forward));
            forward = speed * delta_time * forward;

            var cam_pos = zm.loadArr3(self.position);
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

            zm.storeArr3(&self.position, cam_pos);
        }

        const fb_width = aya.gctx.surface_config.width;
        const fb_height = aya.gctx.surface_config.height;

        const cam_world_to_view = zm.lookToLh(
            zm.loadArr3(self.position),
            zm.loadArr3(self.forward),
            zm.f32x4(0.0, 1.0, 0.0, 0.0),
        );

        const cam_view_to_clip = zm.perspectiveFovLh(
            std.math.degreesToRadians(f32, self.fov),
            @as(f32, @floatFromInt(fb_width)) / @as(f32, @floatFromInt(fb_height)),
            0.01,
            2000.0,
        );
        self.cam_world_to_clip = zm.mul(cam_world_to_view, cam_view_to_clip);
    }

    fn imgui(self: *Camera) void {
        _ = aya.ig.sliderScalar("fov", f32, .{ .v = &self.fov, .min = 10, .max = 120 });
        _ = aya.ig.igDragFloat3("pos", &self.position, 1, -1000, 1000, null, aya.ig.ImGuiSliderFlags_None);
        _ = aya.ig.sliderScalar("uv_type", i32, .{ .v = &self.uv_type, .min = 0, .max = 4 });
        aya.ig.igSpacing();
    }
};

const CameraUniform = struct {
    world_to_clip: Mat,
    position: [3]f32,
    uv_type: i32,
};

const ObjectUniform = struct {
    object_to_world: zm.Mat,
};
