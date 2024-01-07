const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;

const pools = @import("resource_pools.zig");
const internal = @import("../internal.zig");

const DeletionQueue = @import("deletion_queue.zig").DeletionQueue;
const ResourcePools = @import("resource_pools.zig").ResourcePools;
const UniformBufferCache = @import("uniform_buffer_cache.zig").UniformBufferCache;
const Instance = wgpu.Instance;

const BufferHandle = pools.BufferHandle;
const TextureHandle = pools.TextureHandle;
const TextureViewHandle = pools.TextureViewHandle;
const SamplerHandle = pools.SamplerHandle;
const RenderPipelineHandle = pools.RenderPipelineHandle;
const ComputePipelineHandle = pools.ComputePipelineHandle;
const BindGroupHandle = pools.BindGroupHandle;
const BindGroupLayoutHandle = pools.BindGroupLayoutHandle;
const PipelineLayoutHandle = pools.PipelineLayoutHandle;

pub const GraphicsContext = struct {
    pub var swapchain_format = wgpu.TextureFormat.bgra8_unorm;

    cpu_frame_number: u64 = 0,
    gpu_frame_number: u64 = 0,

    instance: Instance,
    device: wgpu.Device,
    queue: wgpu.Queue,
    surface: wgpu.Surface,
    surface_config: wgpu.SurfaceConfiguration,

    pools: ResourcePools,
    deletion_queue: DeletionQueue,
    uniforms: UniformBufferCache,

    pub fn init() !*GraphicsContext {
        const instance = wgpu.createInstance();
        errdefer instance.release();

        const adapter = try createAdapter(instance);
        errdefer adapter.release();

        const device = try createDevice(adapter);
        errdefer device.release();

        device.setUncapturedErrorCallback(logUnhandledError, null);

        const surface = createSurfaceForWindow(instance, aya.window.sdl_window);
        errdefer surface.release();

        var surface_capabilities: wgpu.SurfaceCapabilities = undefined;
        surface.getCapabilities(adapter, &surface_capabilities);

        // find a compatible PresentMode
        var present_mode = wgpu.PresentMode.fifo;
        var properties: wgpu.AdapterProperties = undefined;
        adapter.getProperties(&properties);

        const supported_modes: []wgpu.PresentMode = surface_capabilities.present_modes[0..surface_capabilities.present_mode_count];
        for ([_]wgpu.PresentMode{ .fifo, .mailbox, .immediate }) |mode| {
            if (std.mem.indexOfPos(wgpu.PresentMode, supported_modes, 0, &.{mode}) != null) {
                present_mode = mode;
                break;
            }
        }

        const win_size = aya.window.sizeInPixels();

        // for now, dont use srgb which is the preferred format until we get tonemapping in
        // swapchain_format = surface.getPreferredFormat(adapter);

        const surface_config = wgpu.SurfaceConfiguration{
            .device = device,
            .format = swapchain_format,
            .usage = .{ .render_attachment = true },
            .width = @intCast(win_size.w),
            .height = @intCast(win_size.h),
            .present_mode = present_mode,
            .alpha_mode = surface_capabilities.alpha_modes[0],
        };
        surface.configure(&surface_config);

        const gctx = aya.mem.create(GraphicsContext);
        gctx.* = .{
            .instance = instance,
            .device = device,
            .queue = device.getQueue(),
            .surface = surface,
            .surface_config = surface_config,
            .pools = ResourcePools.init(),
            .deletion_queue = DeletionQueue.init(),
            .uniforms = undefined,
        };
        gctx.uniforms = UniformBufferCache.init(gctx);
        return gctx;
    }

    pub fn deinit(self: *GraphicsContext) void {
        // Wait for the GPU to finish all encoded commands.
        while (self.cpu_frame_number != self.gpu_frame_number)
            _ = self.device.poll(true, null);

        self.deletion_queue.deinit();
        self.pools.deinit(aya.mem.allocator);
        self.uniforms.deinit();

        self.surface.release();
        self.queue.release();
        self.device.release();
        self.device.destroy();

        aya.mem.destroy(self);
    }

    pub fn resize(self: *GraphicsContext, width: i32, height: i32) void {
        self.surface_config.width = @intCast(width);
        self.surface_config.height = @intCast(height);

        // create a new swapchain
        self.surface.configure(&self.surface_config);
    }

    pub fn submit(self: *GraphicsContext, commands: []const wgpu.CommandBuffer) void {
        const stage_commands = stage_commands: {
            const stage_encoder = self.device.createCommandEncoder(null);
            defer stage_encoder.release();

            const current = self.uniforms.stage.current;
            std.debug.assert(self.uniforms.stage.buffers[current].slice != null);

            self.uniforms.stage.buffers[current].slice = null;
            self.uniforms.stage.buffers[current].buffer.unmap();

            if (self.uniforms.offset > 0) {
                stage_encoder.copyBufferToBuffer(
                    self.uniforms.stage.buffers[current].buffer,
                    0,
                    self.lookupResource(self.uniforms.buffer).?,
                    0,
                    self.uniforms.offset,
                );
            }

            break :stage_commands stage_encoder.finish(null);
        };
        defer stage_commands.release();

        // TODO: We support up to 8 command buffers for now. Make it more robust.
        var command_buffers = std.BoundedArray(wgpu.CommandBuffer, 8).init(0) catch unreachable;
        command_buffers.append(stage_commands) catch unreachable;
        command_buffers.appendSlice(commands) catch unreachable;

        onSubmittedWorkDone(self.queue, self, gpuWorkDone);
        self.queue.submit(command_buffers.slice().len, &command_buffers.buffer);

        self.cpu_frame_number += 1;
        self.uniforms.nextStagingBuffer(self);
        self.deletion_queue.flush();
    }

    inline fn gpuWorkDone(self: *GraphicsContext, status: wgpu.QueueWorkDoneStatus) void {
        self.gpu_frame_number += 1;

        if (status != .success) {
            std.log.err("[gpu] Failed to complete GPU work (status: {s}).", .{@tagName(status)});
        }
    }

    // move this to webgpu.zig generator
    fn onSubmittedWorkDone(
        queue: wgpu.Queue,
        context: anytype,
        comptime callback: fn (ctx: @TypeOf(context), status: wgpu.QueueWorkDoneStatus) callconv(.Inline) void,
    ) void {
        const Context = @TypeOf(context);
        const cb = struct {
            pub fn cb(status: wgpu.QueueWorkDoneStatus, userdata: ?*anyopaque) callconv(.C) void {
                callback(if (Context == void) {} else @as(Context, @ptrCast(@alignCast(userdata))), status);
            }
        }.cb;
        queue.onSubmittedWorkDone(cb, if (Context == void) null else context);
    }

    // Resource creation and mutation
    pub fn createBuffer(self: *GraphicsContext, descriptor: *const wgpu.BufferDescriptor) BufferHandle {
        return self.pools.buffer_pool.addResource(self.*, .{
            .gpuobj = self.device.createBuffer(descriptor),
            .size = descriptor.size,
            .usage = descriptor.usage,
        });
    }

    pub inline fn writeBuffer(
        self: *GraphicsContext,
        buffer: BufferHandle,
        buffer_offset: u64,
        comptime T: type,
        data: []const T,
    ) void {
        const size = @as(u64, @intCast(data.len)) * @sizeOf(T);
        self.queue.writeBuffer(self.lookupResource(buffer).?, buffer_offset, @as([*]const u8, @ptrCast(data.ptr)), size);
    }

    pub fn createBufferInit(
        self: *GraphicsContext,
        label: ?[*:0]const u8,
        usage: wgpu.BufferUsage,
        comptime T: type,
        data: []const T,
    ) BufferHandle {
        const size = @as(u64, @intCast(data.len)) * @sizeOf(T);
        const buffer = self.device.createBuffer(&.{
            .label = label,
            .usage = usage,
            .size = size,
            .mapped_at_creation = .true,
        });

        var mapped_data = buffer.getMappedRange(T, 0, data.len).?;
        std.mem.copy(T, mapped_data, data[0..]);
        buffer.unmap();

        return self.pools.buffer_pool.addResource(self.*, .{
            .gpuobj = buffer,
            .size = size,
            .usage = usage,
        });
    }

    pub fn createTextureFromFile(self: *GraphicsContext, file: []const u8) TextureHandle {
        if (internal.assets.tryGetTexture(file)) |tex| return tex;

        const image = aya.stb.Image.init(aya.mem.tmp_allocator, file) catch unreachable;

        var desc = wgpu.TextureDescriptor{
            .size = .{ .width = image.w, .height = image.h },
            .usage = .{ .texture_binding = true, .copy_dst = true },
            .format = .rgba8_unorm,
        };

        const handle = self.pools.texture_pool.addResource(self.*, .{
            .gpuobj = self.device.createTexture(&desc),
            .usage = desc.usage,
            .dimension = desc.dimension,
            .size = desc.size,
            .format = desc.format,
            .mip_level_count = desc.mip_level_count,
            .sample_count = desc.sample_count,
        });

        self.writeTexture(handle, u8, image.getImageData());
        internal.assets.putTexture(file, handle);

        return handle;
    }

    pub fn createTexture(self: *GraphicsContext, width: u32, height: u32, format: wgpu.TextureFormat) TextureHandle {
        var desc = wgpu.TextureDescriptor{
            .size = .{ .width = width, .height = height },
            .usage = .{ .texture_binding = true, .copy_dst = true },
            .format = format,
        };

        return self.pools.texture_pool.addResource(self.*, .{
            .gpuobj = self.device.createTexture(&desc),
            .usage = desc.usage,
            .dimension = desc.dimension,
            .size = desc.size,
            .format = desc.format,
            .mip_level_count = desc.mip_level_count,
            .sample_count = desc.sample_count,
        });
    }

    pub fn createTextureConfig(self: *GraphicsContext, descriptor: *const wgpu.TextureDescriptor) TextureHandle {
        return self.pools.texture_pool.addResource(self.*, .{
            .gpuobj = self.device.createTexture(descriptor),
            .usage = descriptor.usage,
            .dimension = descriptor.dimension,
            .size = descriptor.size,
            .format = descriptor.format,
            .mip_level_count = descriptor.mip_level_count,
            .sample_count = descriptor.sample_count,
        });
    }

    pub fn writeTexture(self: *GraphicsContext, texture: TextureHandle, comptime T: type, data: []const T) void {
        const texture_info: pools.TextureInfo = self.lookupResourceInfo(texture).?;

        self.queue.writeTexture(
            &.{ .texture = self.lookupResource(texture).? },
            @as(*const anyopaque, @ptrCast(data.ptr)),
            @as(usize, @intCast(data.len)) * @sizeOf(T),
            &.{
                .bytes_per_row = 4 * texture_info.size.width,
                .rows_per_image = texture_info.size.height,
            },
            &.{ .width = texture_info.size.width, .height = texture_info.size.height },
        );
    }

    pub fn createTextureView(
        self: *GraphicsContext,
        texture_handle: TextureHandle,
        descriptor: *const wgpu.TextureViewDescriptor,
    ) TextureViewHandle {
        const texture = self.lookupResource(texture_handle).?;
        const info = self.lookupResourceInfo(texture_handle).?;
        var dim = descriptor.dimension;
        if (dim == .undefined) {
            dim = switch (info.dimension) {
                .dim_1d => .dim_1d,
                .dim_2d => .dim_2d,
                .dim_3d => .dim_3d,
            };
        }

        return self.pools.texture_view_pool.addResource(self.*, .{
            .gpuobj = texture.createView(descriptor),
            .format = if (descriptor.format == .undefined) info.format else descriptor.format,
            .dimension = dim,
            .base_mip_level = descriptor.base_mip_level,
            .mip_level_count = if (descriptor.mip_level_count == 0xffff_ffff)
                info.mip_level_count
            else
                descriptor.mip_level_count,
            .base_array_layer = descriptor.base_array_layer,
            .array_layer_count = if (descriptor.array_layer_count == 0xffff_ffff)
                info.size.depth_or_array_layers
            else
                descriptor.array_layer_count,
            .aspect = descriptor.aspect,
            .parent_texture_handle = texture_handle,
        });
    }

    pub fn createSampler(self: *GraphicsContext, desc: *const wgpu.SamplerDescriptor) SamplerHandle {
        return self.pools.sampler_pool.addResource(self.*, .{
            .gpuobj = self.device.createSampler(desc),
            .address_mode_u = desc.address_mode_u,
            .address_mode_v = desc.address_mode_v,
            .address_mode_w = desc.address_mode_w,
            .mag_filter = desc.mag_filter,
            .min_filter = desc.min_filter,
            .mipmap_filter = desc.mipmap_filter,
            .lod_min_clamp = desc.lod_min_clamp,
            .lod_max_clamp = desc.lod_max_clamp,
            .compare = desc.compare,
            .max_anisotropy = desc.max_anisotropy,
        });
    }

    pub const BindGroupLayoutEntryInfo = struct {
        visibility: wgpu.ShaderStage = @import("std").mem.zeroes(wgpu.ShaderStage),
        buffer: ?wgpu.BufferBindingLayout = null,
        sampler: ?wgpu.SamplerBindingLayout = null,
        texture: ?wgpu.TextureBindingLayout = null,
        storage_texture: ?wgpu.StorageTextureBindingLayout = null,
    };

    pub const BindGroupLayoutDesc = struct {
        label: ?[*:0]const u8 = null,
        entries: []const BindGroupLayoutEntryInfo,
    };

    pub fn createBindGroupLayout(self: *GraphicsContext, desc: *const BindGroupLayoutDesc) BindGroupLayoutHandle {
        var entries: [8]wgpu.BindGroupLayoutEntry = undefined;
        for (desc.entries, 0..) |entry, i| {
            entries[i] = .{ .binding = @intCast(i), .visibility = entry.visibility };

            if (entry.buffer) |buff| {
                entries[i].buffer = buff;
            } else if (entry.sampler) |sampler| {
                entries[i].sampler = sampler;
            } else if (entry.storage_texture) |stex| {
                entries[i].storage_texture = stex;
            } else if (entry.texture) |tex| {
                entries[i].texture = tex;
            }
        }

        var bind_group_layout_info = pools.BindGroupLayoutInfo{
            .gpuobj = self.device.createBindGroupLayout(&.{
                .label = desc.label,
                .entry_count = desc.entries.len,
                .entries = entries[0..desc.entries.len].ptr,
            }),
            .num_entries = @intCast(entries.len),
        };

        for (entries, 0..) |entry, i|
            bind_group_layout_info.entries[i] = entry;

        return self.pools.bind_group_layout_pool.addResource(self.*, bind_group_layout_info);
    }

    pub fn createBindGroup(self: *GraphicsContext, layout: BindGroupLayoutHandle, entries: []const pools.BindGroupEntryInfo) BindGroupHandle {
        var bind_group_info = pools.BindGroupInfo{ .num_entries = @intCast(entries.len) };
        var bg_entries: [pools.BindGroupInfo.MAX_BINDINGS_PER_GROUP]wgpu.BindGroupEntry = undefined;

        for (entries, 0..) |entry, i| {
            bind_group_info.entries[i] = entry;
            bg_entries[i] = .{ .binding = @intCast(i), .offset = entry.offset, .size = entry.size };

            if (entry.sampler_handle) |sampler| {
                bg_entries[i].sampler = self.lookupResource(sampler).?;
            } else if (entry.texture_view_handle) |tv| {
                bg_entries[i].texture_view = self.lookupResource(tv).?;
            } else if (entry.buffer_handle) |buffer| {
                bg_entries[i].buffer = self.lookupResource(buffer).?;
            }
        }

        bind_group_info.gpuobj = self.device.createBindGroup(&.{
            .layout = self.lookupResource(layout).?,
            .entry_count = @intCast(entries.len),
            .entries = bg_entries[0..entries.len].ptr,
        });

        return self.pools.bind_group_pool.addResource(self.*, bind_group_info);
    }

    pub const PipelineDesc = struct {
        label: ?[*:0]const u8 = null,
        source: [*:0]const u8,
        bgls: []const wgpu.BindGroupLayout = &.{},
        vbuffers: []const wgpu.VertexBufferLayout = &.{},
        blend_state: wgpu.BlendState = wgpu.BlendState.alpha_blending,
    };

    pub fn createPipeline(self: *GraphicsContext, desc: *const PipelineDesc) RenderPipelineHandle {
        const shader_module = createWgslShaderModule(self, desc.source, null);
        defer shader_module.release();

        const pipeline_layout = if (desc.bgls.len == 0) null else self.device.createPipelineLayout(&.{
            .bind_group_layout_count = desc.bgls.len,
            .bind_group_layouts = desc.bgls.ptr,
        });
        defer if (pipeline_layout) |pl| pl.release();

        const pipe_desc = wgpu.RenderPipelineDescriptor{
            .layout = pipeline_layout,
            .vertex = wgpu.VertexState{
                .module = shader_module,
                .entry_point = "vs_main",
                .buffer_count = desc.vbuffers.len,
                .buffers = desc.vbuffers.ptr,
            },
            .fragment = &wgpu.FragmentState{
                .module = shader_module,
                .entry_point = "fs_main",
                .target_count = 1,
                .targets = &[_]wgpu.ColorTargetState{
                    .{
                        .format = swapchain_format,
                        .blend = &desc.blend_state,
                    },
                },
            },
        };

        return self.pools.render_pipeline_pool.addResource(self.*, .{
            .gpuobj = self.device.createRenderPipeline(&pipe_desc),
        });
    }

    /// Helper function for creating render pipelines.
    /// Supports: one vertex buffer, one non-blending render target, one vertex shader module and one fragment shader module.
    pub fn createPipelineSimple(
        self: *GraphicsContext,
        bgls: []const wgpu.BindGroupLayout,
        shader_source: [:0]const u8,
        vertex_stride: ?u64,
        vertex_attribs: ?[]const wgpu.VertexAttribute,
        primitive_state: wgpu.PrimitiveState,
        rt_format: wgpu.TextureFormat,
        depth_state: ?*const wgpu.DepthStencilState,
    ) RenderPipelineHandle {
        const pipeline_layout = self.device.createPipelineLayout(&.{
            .bind_group_layout_count = bgls.len,
            .bind_group_layouts = bgls.ptr,
        });
        defer pipeline_layout.release();

        const shader_module = createWgslShaderModule(self, shader_source, null);
        defer shader_module.release();

        const color_targets = [_]wgpu.ColorTargetState{.{ .format = rt_format }};

        const vertex_buffers = if (vertex_stride) |vs| [_]wgpu.VertexBufferLayout{.{
            .array_stride = vs,
            .attribute_count = @intCast(vertex_attribs.?.len),
            .attributes = vertex_attribs.?.ptr,
        }} else null;

        const pipe_desc = wgpu.RenderPipelineDescriptor{
            .layout = pipeline_layout,
            .vertex = wgpu.VertexState{
                .module = shader_module,
                .entry_point = "vs_main",
                .buffer_count = if (vertex_buffers) |vbs| vbs.len else 0,
                .buffers = if (vertex_buffers) |vbs| &vbs else null,
            },
            .fragment = &wgpu.FragmentState{
                .module = shader_module,
                .entry_point = "fs_main",
                .target_count = color_targets.len,
                .targets = &color_targets,
            },
            .depth_stencil = if (depth_state) |ds| ds else null,
            .primitive = primitive_state,
        };

        return self.pools.render_pipeline_pool.addResource(self.*, .{
            .gpuobj = self.device.createRenderPipeline(&pipe_desc),
        });
    }

    // TODO: not supported yet by wgpu
    fn createPipelineAsync(
        self: *GraphicsContext,
        allocator: std.mem.Allocator,
        result: *RenderPipelineHandle,
        desc: *const PipelineDesc,
    ) void {
        const AsyncCreateOpRender = struct {
            gctx: *GraphicsContext,
            result: *RenderPipelineHandle,
            allocator: std.mem.Allocator,

            fn create(
                status: wgpu.CreatePipelineAsyncStatus,
                pipeline: wgpu.RenderPipeline,
                message: ?[*:0]const u8,
                userdata: ?*anyopaque,
            ) callconv(.C) void {
                const op = @as(*@This(), @ptrCast(@alignCast(userdata)));
                if (status == .success) {
                    op.result.* = op.gctx.pools.render_pipeline_pool.addResource(
                        op.gctx.*,
                        .{ .gpuobj = pipeline },
                    );
                } else {
                    std.log.err(
                        "[gpu] Failed to async create render pipeline (status: {s}, message: {?s}).",
                        .{ @tagName(status), message },
                    );
                }
                op.allocator.destroy(op);
            }
        };

        const shader_module = createWgslShaderModule(self, desc.source, null);
        defer shader_module.release();

        const pipeline_layout = if (desc.bgls.len == 0) null else self.device.createPipelineLayout(&.{
            .bind_group_layout_count = desc.bgls.len,
            .bind_group_layouts = desc.bgls.ptr,
        });
        defer if (pipeline_layout) |pl| pl.release();

        const pipe_desc = wgpu.RenderPipelineDescriptor{
            .layout = pipeline_layout,
            .vertex = wgpu.VertexState{
                .module = shader_module,
                .entry_point = "vs_main",
                .buffer_count = desc.vbuffers.len,
                .buffers = desc.vbuffers.ptr,
            },
            .fragment = &wgpu.FragmentState{
                .module = shader_module,
                .entry_point = "fs_main",
                .target_count = 1,
                .targets = &[_]wgpu.ColorTargetState{
                    .{ .format = GraphicsContext.swapchain_format },
                },
            },
        };

        const op = allocator.create(AsyncCreateOpRender) catch unreachable;
        op.* = .{
            .gctx = self,
            .result = result,
            .allocator = allocator,
        };
        self.device.createRenderPipelineAsync(&pipe_desc, AsyncCreateOpRender.create, @ptrCast(op));
    }

    pub const ComputePipelineDesc = struct {
        label: ?[*:0]const u8 = null,
        source: [*:0]const u8,
        entry_point: [*c]const u8 = "main",
        bgls: []const wgpu.BindGroupLayout = &.{},
    };

    pub fn createComputePipeline(
        self: *GraphicsContext,
        descriptor: wgpu.ComputePipelineDescriptor,
        desc: *const ComputePipelineDesc,
    ) ComputePipelineHandle {
        _ = descriptor;
        const shader_module = createWgslShaderModule(self, desc.source, null);
        defer shader_module.release();

        const pipeline_layout = if (desc.bgls.len == 0) null else self.device.createPipelineLayout(&.{
            .bind_group_layout_count = desc.bgls.len,
            .bind_group_layouts = desc.bgls.ptr,
        });
        defer if (pipeline_layout) |pl| pl.release();

        return self.compute_pipeline_pool.addResource(self.*, .{
            .gpuobj = self.device.createComputePipeline(&.{
                .pipeline_layout = pipeline_layout,
                .compute = .{
                    .module = shader_module,
                    .entry_point = desc.entry_point,
                },
            }),
        });
    }

    /// Helper function for creating render passes. Supports: One color attachment and optional depth attachment
    pub fn beginRenderPassSimple(
        self: *GraphicsContext,
        encoder: wgpu.CommandEncoder,
        load_op: wgpu.LoadOp,
        color_texv: wgpu.TextureView,
        clear_color: ?wgpu.Color,
        depth_texv: ?wgpu.TextureView,
        clear_depth: ?f32,
    ) wgpu.RenderPassEncoder {
        _ = self;
        if (depth_texv == null) {
            std.debug.assert(clear_depth == null);
        }
        const color_attachments = [_]wgpu.RenderPassColorAttachment{.{
            .view = color_texv,
            .load_op = load_op,
            .store_op = .store,
            .clear_value = if (clear_color) |cc| cc else .{ .r = 0, .g = 0, .b = 0, .a = 0 },
        }};
        if (depth_texv) |dtexv| {
            const depth_attachment = wgpu.RenderPassDepthStencilAttachment{
                .view = dtexv,
                .depth_load_op = load_op,
                .depth_store_op = .store,
                .depth_clear_value = if (clear_depth) |cd| cd else 0.0,
            };
            return encoder.beginRenderPass(&.{
                .color_attachment_count = color_attachments.len,
                .color_attachments = &color_attachments,
                .depth_stencil_attachment = &depth_attachment,
            });
        }
        return encoder.beginRenderPass(&.{
            .color_attachment_count = color_attachments.len,
            .color_attachments = &color_attachments,
        });
    }

    // Resource management
    pub fn lookupResource(self: GraphicsContext, handle: anytype) ?pools.HandleToGpuResourceType(@TypeOf(handle)) {
        if (self.isResourceValid(handle)) {
            const T = @TypeOf(handle);
            return switch (T) {
                BufferHandle => self.pools.buffer_pool.getGpuObj(handle).?,
                TextureHandle => self.pools.texture_pool.getGpuObj(handle).?,
                TextureViewHandle => self.pools.texture_view_pool.getGpuObj(handle).?,
                SamplerHandle => self.pools.sampler_pool.getGpuObj(handle).?,
                RenderPipelineHandle => self.pools.render_pipeline_pool.getGpuObj(handle).?,
                ComputePipelineHandle => self.pools.compute_pipeline_pool.getGpuObj(handle).?,
                BindGroupHandle => self.pools.bind_group_pool.getGpuObj(handle).?,
                BindGroupLayoutHandle => self.pools.bind_group_layout_pool.getGpuObj(handle).?,
                PipelineLayoutHandle => self.pools.pipeline_layout_pool.getGpuObj(handle).?,
                else => @compileError(
                    "[gpu] GraphicsContext.lookupResource() not implemented for " ++ @typeName(T),
                ),
            };
        }
        return null;
    }

    pub fn lookupResourceInfo(self: GraphicsContext, handle: anytype) ?pools.HandleToResourceInfoType(@TypeOf(handle)) {
        if (self.isResourceValid(handle)) {
            const T = @TypeOf(handle);
            return switch (T) {
                BufferHandle => self.pools.buffer_pool.getInfo(handle),
                TextureHandle => self.pools.texture_pool.getInfo(handle),
                TextureViewHandle => self.pools.texture_view_pool.getInfo(handle),
                SamplerHandle => self.pools.sampler_pool.getInfo(handle),
                RenderPipelineHandle => self.pools.render_pipeline_pool.getInfo(handle),
                ComputePipelineHandle => self.pools.compute_pipeline_pool.getInfo(handle),
                BindGroupHandle => self.pools.bind_group_pool.getInfo(handle),
                BindGroupLayoutHandle => self.pools.bind_group_layout_pool.getInfo(handle),
                PipelineLayoutHandle => self.pools.pipeline_layout_pool.getInfo(handle),
                else => @compileError(
                    "[gpu] GraphicsContext.lookupResourceInfo() not implemented for " ++ @typeName(T),
                ),
            };
        }
        return null;
    }

    pub fn cloneResource(self: *GraphicsContext, handle: anytype) void {
        const T = @TypeOf(handle);
        switch (T) {
            BufferHandle => self.pools.buffer_pool.cloneResource(handle),
            TextureHandle => self.pools.texture_pool.cloneResource(handle),
            TextureViewHandle => self.pools.texture_view_pool.cloneResource(handle),
            SamplerHandle => self.pools.sampler_pool.cloneResource(handle),
            RenderPipelineHandle => self.pools.render_pipeline_pool.cloneResource(handle),
            ComputePipelineHandle => self.pools.compute_pipeline_pool.cloneResource(handle),
            BindGroupHandle => self.pools.bind_group_pool.cloneResource(handle),
            BindGroupLayoutHandle => self.pools.bind_group_layout_pool.cloneResource(handle),
            PipelineLayoutHandle => self.pools.pipeline_layout_pool.cloneResource(handle),
            else => @compileError("[gpu] GraphicsContext.cloneResource() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn releaseResource(self: *GraphicsContext, handle: anytype) void {
        const T = @TypeOf(handle);
        switch (T) {
            BufferHandle => self.pools.buffer_pool.destroyResource(handle, false),
            TextureHandle => self.pools.texture_pool.destroyResource(handle, false),
            TextureViewHandle => self.pools.texture_view_pool.destroyResource(handle, false),
            SamplerHandle => self.pools.sampler_pool.destroyResource(handle, false),
            RenderPipelineHandle => self.pools.render_pipeline_pool.destroyResource(handle, false),
            ComputePipelineHandle => self.pools.compute_pipeline_pool.destroyResource(handle, false),
            BindGroupHandle => self.pools.bind_group_pool.destroyResource(handle, false),
            BindGroupLayoutHandle => self.pools.bind_group_layout_pool.destroyResource(handle, false),
            PipelineLayoutHandle => self.pools.pipeline_layout_pool.destroyResource(handle, false),
            else => @compileError("[gpu] GraphicsContext.releaseResource() not implemented for " ++ @typeName(T)),
        }
    }

    /// releases the resource at the end of the frame
    pub fn releaseResourceDelayed(self: *GraphicsContext, handle: anytype) void {
        self.deletion_queue.append(handle);
    }

    pub fn destroyResource(self: *GraphicsContext, handle: anytype) void {
        const T = @TypeOf(handle);
        switch (T) {
            BufferHandle => self.pools.buffer_pool.destroyResource(handle, true),
            TextureHandle => self.pools.texture_pool.destroyResource(handle, true),
            else => @compileError("[gpu] GraphicsContext.destroyResource() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn isResourceValid(self: GraphicsContext, handle: anytype) bool {
        switch (@TypeOf(handle)) {
            BufferHandle => return self.pools.buffer_pool.isHandleValid(handle),
            TextureHandle => return self.pools.texture_pool.isHandleValid(handle),
            TextureViewHandle => {
                if (self.pools.texture_view_pool.isHandleValid(handle)) {
                    const texture = self.pools.texture_view_pool.getInfoPtr(handle).parent_texture_handle;
                    return self.isResourceValid(texture);
                }
                return false;
            },
            SamplerHandle => return self.pools.sampler_pool.isHandleValid(handle),
            RenderPipelineHandle => return self.pools.render_pipeline_pool.isHandleValid(handle),
            ComputePipelineHandle => return self.pools.compute_pipeline_pool.isHandleValid(handle),
            BindGroupHandle => {
                if (self.pools.bind_group_pool.isHandleValid(handle)) {
                    const num_entries = self.pools.bind_group_pool.getInfoPtr(handle).num_entries;
                    const entries = &self.pools.bind_group_pool.getInfoPtr(handle).entries;
                    var i: u32 = 0;
                    while (i < num_entries) : (i += 1) {
                        if (entries[i].buffer_handle) |buffer| {
                            if (!self.isResourceValid(buffer))
                                return false;
                        } else if (entries[i].sampler_handle) |sampler| {
                            if (!self.isResourceValid(sampler))
                                return false;
                        } else if (entries[i].texture_view_handle) |texture_view| {
                            if (!self.isResourceValid(texture_view))
                                return false;
                        } else unreachable;
                    }
                    return true;
                }
                return false;
            },
            BindGroupLayoutHandle => return self.pools.bind_group_layout_pool.isHandleValid(handle),
            PipelineLayoutHandle => return self.pools.pipeline_layout_pool.isHandleValid(handle),
            else => @compileError("[gpu] GraphicsContext.isResourceValid() not implemented for " ++ @typeName(@TypeOf(handle))),
        }
    }
};

const LocalSurfaceDescriptor = union(enum) {
    metal_layer: struct {
        label: ?[*:0]const u8 = null,
        layer: *anyopaque,
    },
    windows_hwnd: struct {
        label: ?[*:0]const u8 = null,
        hinstance: *anyopaque,
        hwnd: *anyopaque,
    },
    xlib: struct {
        label: ?[*:0]const u8 = null,
        display: *anyopaque,
        window: u32,
    },
};

fn createSurfaceForWindow(instance: Instance, window: *aya.sdl.SDL_Window) wgpu.Surface {
    const os_tag = @import("builtin").target.os.tag;
    const descriptor = if (os_tag == .windows) blk: {
        var info: aya.sdl.SDL_SysWMinfo = undefined;
        if (aya.sdl.SDL_GetWindowWMInfo(window, &info, aya.sdl.SDL_SYSWM_CURRENT_VERSION) != 0) {
            aya.sdl.SDL_Log("SDL_GetWindowWMInfo failed. SDL error: %s", aya.sdl.SDL_GetError());
            @panic("SDL_GetWindowWMInfo failed");
        }
        std.debug.print("SDL_GetWindowWMInfo (remove this once tested): {}\n", .{info});

        break :blk LocalSurfaceDescriptor{
            .windows_hwnd = .{
                .label = "basic surface",
                .hinstance = std.os.windows.kernel32.GetModuleHandleW(null).?, // or info.in```fo.hinstance,
                .hwnd = info.info.win.window,
            },
        };
    } else if (os_tag == .linux) blk: {
        var info: aya.sdl.SDL_SysWMinfo = undefined;
        if (aya.sdl.SDL_GetWindowWMInfo(window, &info, aya.sdl.SDL_SYSWM_CURRENT_VERSION) != 0) {
            aya.sdl.SDL_Log("SDL_GetWindowWMInfo failed. SDL error: %s", aya.sdl.SDL_GetError());
            @panic("SDL_GetWindowWMInfo failed");
        }
        std.debug.print("SDL_GetWindowWMInfo (remove this once tested): {}\n", .{info});

        break :blk LocalSurfaceDescriptor{
            .xlib = .{
                .label = "basic surface",
                .display = info.info.display, // zglfw.native.getX11Display()
                .window = info.info.window, // zglfw.native.getX11Window(window)
            },
        };
    } else if (os_tag == .macos) blk: {
        const metal_view = aya.sdl.SDL_Metal_CreateView(window);
        const metal_layer = aya.sdl.SDL_Metal_GetLayer(metal_view);

        break :blk LocalSurfaceDescriptor{
            .metal_layer = .{
                .label = "basic surface",
                .layer = metal_layer.?,
            },
        };
    } else unreachable;

    return switch (descriptor) {
        .metal_layer => |src| blk: {
            var desc: wgpu.SurfaceDescriptorFromMetalLayer = undefined;
            desc.chain.next = null;
            desc.chain.s_type = .surface_descriptor_from_metal_layer;
            desc.layer = src.layer;
            break :blk instance.createSurface(&.{
                .next_in_chain = @ptrCast(&desc),
                .label = if (src.label) |l| l else null,
            });
        },
        .windows_hwnd => |src| blk: {
            var desc: wgpu.SurfaceDescriptorFromWindowsHWND = undefined;
            desc.chain.next = null;
            desc.chain.s_type = .surface_descriptor_from_windows_hwnd;
            desc.hinstance = src.hinstance;
            desc.hwnd = src.hwnd;
            break :blk instance.createSurface(&.{
                .next_in_chain = @ptrCast(&desc),
                .label = if (src.label) |l| l else null,
            });
        },
        .xlib => |src| blk: {
            var desc: wgpu.SurfaceDescriptorFromXlibWindow = undefined;
            desc.chain.next = null;
            desc.chain.s_type = .surface_descriptor_from_xlib_window;
            desc.display = src.display;
            desc.window = src.window;
            break :blk instance.createSurface(&.{
                .next_in_chain = @ptrCast(&desc),
                .label = if (src.label) |l| l else null,
            });
        },
    };
}

fn createAdapter(instance: Instance) !wgpu.Adapter {
    const adapter = adapter: {
        const Response = struct {
            status: wgpu.RequestAdapterStatus = .unknown,
            adapter: wgpu.Adapter = undefined,
            message: ?[*:0]const u8 = null,
        };

        const callback = struct {
            fn callback(
                status: wgpu.RequestAdapterStatus,
                adapter: wgpu.Adapter,
                message: ?[*:0]const u8,
                userdata: ?*anyopaque,
            ) callconv(.C) void {
                const response = @as(*Response, @ptrCast(@alignCast(userdata)));
                response.status = status;
                response.adapter = adapter;
                response.message = message;
            }
        }.callback;

        var response = Response{};
        instance.requestAdapter(
            &.{ .power_preference = .high_performance },
            callback,
            @ptrCast(&response),
        );

        if (response.status != .success) {
            std.log.err("Failed to request GPU adapter (status: {s}).", .{@tagName(response.status)});
            return error.NoGraphicsAdapter;
        }
        break :adapter response.adapter;
    };
    errdefer adapter.release();

    var properties: wgpu.AdapterProperties = undefined;
    properties.next_in_chain = null;
    adapter.getProperties(&properties);

    std.log.info("Found [{s}] backend on [{s}] adapter: [{s}], [{s}]\n", .{
        @tagName(properties.backend_type),
        @tagName(properties.adapter_type),
        properties.name,
        properties.driver_description,
    });

    return adapter;
}

fn createDevice(adapter: wgpu.Adapter) !wgpu.Device {
    const device = device: {
        const Response = struct {
            status: wgpu.RequestDeviceStatus = .unknown,
            device: wgpu.Device = undefined,
            message: ?[*:0]const u8 = null,
        };

        const callback = (struct {
            fn callback(
                status: wgpu.RequestDeviceStatus,
                device: wgpu.Device,
                message: ?[*:0]const u8,
                userdata: ?*anyopaque,
            ) callconv(.C) void {
                const response = @as(*Response, @ptrCast(@alignCast(userdata)));
                response.status = status;
                response.device = device;
                response.message = message;
            }
        }).callback;

        var response = Response{};
        adapter.requestDevice(
            &.{ .device_lost_callback = deviceLost },
            callback,
            @ptrCast(&response),
        );

        if (response.status != .success) {
            std.log.err("Failed to request GPU device (status: {s}).", .{@tagName(response.status)});
            return error.NoGraphicsDevice;
        }
        break :device response.device;
    };
    errdefer device.release();

    return device;
}

fn logUnhandledError(err_type: wgpu.ErrorType, message: ?[*:0]const u8, _: ?*anyopaque) callconv(.C) void {
    switch (err_type) {
        .no_error => std.log.info("[gpu] No error: {?s}", .{message}),
        .validation => std.log.err("[gpu] Validation: {?s}", .{message}),
        .out_of_memory => std.log.err("[gpu] Out of memory: {?s}", .{message}),
        .device_lost => std.log.err("[gpu] Device lost: {?s}", .{message}),
        .internal => std.log.err("[gpu] Internal error: {?s}", .{message}),
        .unknown => std.log.err("[gpu] Unknown error: {?s}", .{message}),
    }

    // Exit the process for easier debugging.
    if (@import("builtin").mode == .Debug)
        std.process.exit(1);
}

fn deviceLost(reason: wgpu.DeviceLostReason, message: ?[*:0]const u8, _: ?*anyopaque) callconv(.C) void {
    std.debug.print("Device lost! reason {} with message {?s}\n", .{ reason, std.mem.span(message) });
}

fn createWgslShaderModule(self: *GraphicsContext, source: [*:0]const u8, label: ?[*:0]const u8) wgpu.ShaderModule {
    const wgsl_desc = wgpu.ShaderModuleWGSLDescriptor{
        .chain = .{ .next = null, .s_type = .shader_module_wgsl_descriptor },
        .code = source,
    };
    const desc = wgpu.ShaderModuleDescriptor{
        .next_in_chain = @ptrCast(&wgsl_desc),
        .label = if (label) |l| l else null,
    };
    return self.device.createShaderModule(&desc);
}
