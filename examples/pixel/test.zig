const std = @import("std");
const aya = @import("aya");
const ig = aya.ig;
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
    offscreen_pass: OffscreenPass,
    camera: Camera,
    quad_mesh: QuadMesh,
    renderables: [3]Renderable,
    use_offscreen_pass: bool,
    offscreen_pass_size: u32,

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
        .window = .{
            .width = 768,
            .height = 768,
        },
    });
}

fn init() !void {
    state.use_offscreen_pass = true;
    state.offscreen_pass_size = 280;

    state.renderer = Renderer.init();
    state.offscreen_pass = OffscreenPass.init(state.offscreen_pass_size, state.offscreen_pass_size);
    state.camera = .{};
    state.quad_mesh = QuadMesh.init();

    state.checker_tex = aya.gpu.createCheckerTexture(4);
    state.checker_view = aya.gctx.createTextureView(state.checker_tex, &.{});

    state.layer1_tex = aya.gctx.createTextureFromFile("examples/pixel/layer1.png");
    state.layer2_tex = aya.gctx.createTextureFromFile("examples/pixel/layer2.png");
    state.layer3_tex = aya.gctx.createTextureFromFile("examples/pixel/layer3.png");

    state.renderables[0] = Renderable.init(state.layer1_tex);
    state.renderables[0].pos.z = 2.1;
    state.renderables[1] = Renderable.init(state.layer2_tex);
    state.renderables[1].pos.z = 2;
    state.renderables[2] = Renderable.init(state.layer3_tex);
    state.renderables[2].pos.z = 2;
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
        ig.igPushID_Ptr(renderable);
        defer ig.igPopID();

        _ = ig.igCheckbox("Enabled", &renderable.enabled);
        _ = ig.igDragFloat3("pos", &renderable.pos.x, 1, -1000, 1000, null, ig.ImGuiSliderFlags_None);
    }

    ig.igSpacing();
    _ = ig.igCheckbox("Render Offscreen", &state.use_offscreen_pass);
    ig.igSpacing();
}

fn render(ctx: *aya.render.RenderContext) !void {
    const pass = blk: {
        if (state.use_offscreen_pass)
            break :blk state.renderer.beginOffscreenPass(state.camera, state.offscreen_pass, ctx);
        break :blk state.renderer.beginPass(state.camera, ctx);
    };
    state.quad_mesh.setBuffers(pass);

    for (&state.renderables) |*renderable| {
        renderable.draw(pass);
    }

    pass.end();
    pass.release();

    // if we rendered offscreen we need to blit the render texture to the backbuffer
    if (state.use_offscreen_pass) {
        const p = ctx.beginRenderPass(&.{
            .label = "Offscreen Blit Render Pass Encoder",
            .color_attachment_count = 1,
            .color_attachments = &.{
                .view = ctx.swapchain_view,
                .load_op = .clear,
                .store_op = .store,
                .clear_value = .{ .r = 0.2, .g = 0.2, .b = 0.3, .a = 1.0 },
            },
        });

        const pipeline = aya.gctx.lookupResource(state.offscreen_pass.pipeline) orelse unreachable;
        const bg = aya.gctx.lookupResource(state.offscreen_pass.bind_group) orelse unreachable;

        p.setPipeline(pipeline);
        p.setBindGroup(0, bg, null);
        p.draw(3, 1, 0, 0);

        p.end();
        p.release();
    }
}

pub const Renderable = struct {
    material: Material,
    pos: Vec3 = .{},
    scale: Vec2 = .{ .x = 1, .y = 1 },
    rot_z: f32 = 0,
    enabled: bool = true,

    pub fn init(tex: aya.render.TextureHandle) Renderable {
        return .{ .material = Material.init(tex) };
    }

    pub fn draw(self: *Renderable, pass: wgpu.RenderPassEncoder) void {
        if (!self.enabled) return;

        // self.rot_z = std.math.degreesToRadians(f32, aya.time.seconds() * 5);
        const object_bg = aya.gctx.lookupResource(self.material.object_bind_group) orelse return;

        const object_to_world = zm.mul(zm.mul(zm.scaling(self.scale.x, self.scale.y, 1), zm.translation(self.pos.x, self.pos.y, self.pos.z)), zm.rotationZ(self.rot_z));

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
            .{ .sampler_handle = aya.gctx.createSampler(&.{
                .mag_filter = .linear,
                .min_filter = .linear,
            }) },
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
    offscreen_pipeline: aya.render.RenderPipelineHandle,

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
            .size = .{ .width = aya.gctx.surface_config.width, .height = aya.gctx.surface_config.height },
            .format = .depth16_unorm,
        });

        // TODO: duplicated from Material
        const object_bind_group_layout = aya.gctx.createBindGroupLayout(&.{
            .label = "Texture Bind Group",
            .entries = &.{
                .{ .visibility = .{ .vertex = true, .fragment = true }, .buffer = .{ .type = .uniform, .has_dynamic_offset = .true } },
                .{ .visibility = .{ .fragment = true }, .texture = .{} },
                .{ .visibility = .{ .fragment = true }, .sampler = .{} },
            },
        });
        defer aya.gctx.releaseResource(object_bind_group_layout);

        // pipelines
        const pipeline = createPipeline(
            &.{ aya.gctx.lookupResource(frame_bind_group_layout).?, aya.gctx.lookupResource(object_bind_group_layout).? },
            aya.render.GraphicsContext.swapchain_format,
        );

        const offscreen_pipeline = createPipeline(
            &.{ aya.gctx.lookupResource(frame_bind_group_layout).?, aya.gctx.lookupResource(object_bind_group_layout).? },
            .rgba8_unorm,
        );

        return .{
            .frame_bind_group = frame_bind_group,
            .depth_tex = depth_tex,
            .depth_view = aya.gctx.createTextureView(depth_tex, &.{}),
            .pipeline = pipeline,
            .offscreen_pipeline = offscreen_pipeline,
        };
    }

    fn createPipeline(bgls: []const wgpu.BindGroupLayout, color_target_format: wgpu.TextureFormat) aya.render.RenderPipelineHandle {
        const pipeline_layout = aya.gctx.device.createPipelineLayout(&.{
            .bind_group_layout_count = bgls.len,
            .bind_group_layouts = bgls.ptr,
        });
        defer pipeline_layout.release();

        const shader_source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/pixel/pixel.wgsl") catch unreachable;
        const shader_module = aya.gpu.createWgslShaderModule(shader_source, null);
        defer shader_module.release();

        const color_targets = [_]wgpu.ColorTargetState{.{
            .format = color_target_format,
            .blend = &wgpu.BlendState.alpha_blending,
        }};

        const vertex_attribs: []const wgpu.VertexAttribute = &aya.gpu.vertexAttributesForType(Vertex).attributes;
        const vertex_buffers = [_]wgpu.VertexBufferLayout{.{
            .array_stride = @sizeOf(Vertex),
            .attribute_count = @intCast(vertex_attribs.len),
            .attributes = vertex_attribs.ptr,
        }};

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
            },
            .depth_stencil = &.{
                .format = .depth16_unorm,
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

    pub fn beginOffscreenPass(self: Renderer, camera: Camera, offscreen_pass: OffscreenPass, ctx: *aya.render.RenderContext) wgpu.RenderPassEncoder {
        const pipline = aya.gctx.lookupResource(self.offscreen_pipeline) orelse unreachable;
        const color_view = aya.gctx.lookupResource(offscreen_pass.color_tex_view) orelse unreachable;
        const depth_view = aya.gctx.lookupResource(offscreen_pass.depth_tex_view) orelse unreachable;
        const bg = aya.gctx.lookupResource(self.frame_bind_group) orelse unreachable;

        const pass = ctx.beginRenderPass(&.{
            .label = "Offscreen Render Pass Encoder",
            .color_attachment_count = 1,
            .color_attachments = &.{
                .view = color_view,
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

pub const OffscreenPass = struct {
    color_tex: aya.render.TextureHandle,
    color_tex_view: aya.render.TextureViewHandle,
    depth_tex: aya.render.TextureHandle,
    depth_tex_view: aya.render.TextureViewHandle,
    bind_group: aya.render.BindGroupHandle,
    pipeline: aya.render.RenderPipelineHandle,

    pub fn init(width: u32, height: u32) OffscreenPass {
        const color_tex = aya.gctx.createTextureConfig(&.{
            .usage = .{ .render_attachment = true, .texture_binding = true },
            .size = .{ .width = width, .height = height },
            .format = .rgba8_unorm,
        });
        const color_tex_view = aya.gctx.createTextureView(color_tex, &.{});

        const depth_tex = aya.gctx.createTextureConfig(&.{
            .usage = .{ .render_attachment = true },
            .size = .{ .width = width, .height = height },
            .format = .depth16_unorm,
        });

        // bind group
        const object_bind_group_layout = aya.gctx.createBindGroupLayout(&.{
            .label = "Offscreen Bind Group",
            .entries = &.{
                .{ .visibility = .{ .fragment = true }, .texture = .{} },
                .{ .visibility = .{ .fragment = true }, .sampler = .{} },
            },
        });
        defer aya.gctx.releaseResource(object_bind_group_layout);

        const bind_group = aya.gctx.createBindGroup(object_bind_group_layout, &.{
            .{ .texture_view_handle = color_tex_view },
            .{ .sampler_handle = aya.gctx.createSampler(&.{}) },
        });

        const pipeline = aya.gctx.createPipeline(&.{
            .source = aya.fs.readZ(aya.mem.tmp_allocator, "examples/pixel/fullscreen.wgsl") catch unreachable,
            .bgls = &.{aya.gctx.lookupResource(object_bind_group_layout).?},
        });

        return .{
            .color_tex = color_tex,
            .color_tex_view = color_tex_view,
            .depth_tex = depth_tex,
            .depth_tex_view = aya.gctx.createTextureView(depth_tex, &.{}),
            .bind_group = bind_group,
            .pipeline = pipeline,
        };
    }

    pub fn deinit(self: OffscreenPass) void {
        aya.gctx.releaseResource(self.color_tex);
    }
};

pub const Camera = struct {
    position: [3]f32 = .{ 0.5, 0.5, 1.5 },
    forward: [3]f32 = .{ 0.0, 0.0, 1.0 },
    pitch: f32 = 0.0 * std.math.pi,
    yaw: f32 = 0.0,
    fov: f32 = 70,
    zoom: f32 = 1,
    cam_world_to_clip: Mat = zm.identity(),
    uv_type: i32 = 3,
    speed: f32 = 4.0,

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
            const speed = if (!aya.kb.pressed(.lshift)) zm.f32x4s(self.speed / 20) else zm.f32x4s(self.speed);
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
                cam_pos[1] -= speed[0] * aya.time.dt();
            } else if (aya.kb.pressed(.e)) {
                cam_pos[1] += speed[0] * aya.time.dt();
            }

            zm.storeArr3(&self.position, cam_pos);
        }

        const fb_width = if (state.use_offscreen_pass) aya.gctx.surface_config.width else state.offscreen_pass_size;
        const fb_height = if (state.use_offscreen_pass) aya.gctx.surface_config.height else state.offscreen_pass_size;

        self.fov = self.cameraFov(@floatFromInt(fb_height));

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
        _ = ig.sliderScalar("fov", f32, .{ .v = &self.fov, .min = 10, .max = 120 });
        _ = ig.igDragFloat3("pos", &self.position, 1, -1000, 1000, null, ig.ImGuiSliderFlags_None);
        _ = ig.igDragFloat3("forward", &self.forward, 1, -1000, 1000, null, ig.ImGuiSliderFlags_None);
        _ = ig.sliderScalar("zoom", f32, .{ .v = &self.zoom, .min = -50, .max = 50 });
        _ = ig.sliderScalar("uv_type", i32, .{ .v = &self.uv_type, .min = 0, .max = 3 });
        ig.igSpacing();
    }

    fn cameraFov(self: *const Camera, viewport_height: f32) f32 {
        const target_height = viewport_height / self.zoom;
        return @abs(std.math.radiansToDegrees(f32, std.math.atan(target_height / (2.0 * self.position[2]))));
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
