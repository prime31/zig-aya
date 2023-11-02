const std = @import("std");
const sdl = @import("sdl");
const math = std.math;
const assert = std.debug.assert;
const wgsl = @import("common_wgsl.zig");
// pub const wgpu = @import("wgpu.zig");
pub const wgpu = @import("mach_gpu");

// if true the following options are set: "skip_validation", "disable_symbol_renaming", "use_user_defined_labels_in_backend"
const dawn_skip_validation = false;

pub const GraphicsContextOptions = struct {
    present_mode: wgpu.PresentMode = .fifo,
};

pub const GraphicsContext = struct {
    pub const swapchain_format = wgpu.Texture.Format.bgra8_unorm;

    allocator: std.mem.Allocator,
    window: *sdl.SDL_Window,
    stats: FrameStats = .{},

    instance: *wgpu.Instance,
    device: *wgpu.Device,
    queue: *wgpu.Queue,
    surface: *wgpu.Surface,
    swapchain: *wgpu.SwapChain,
    swapchain_descriptor: wgpu.SwapChain.Descriptor,

    buffer_pool: BufferPool,
    texture_pool: TexturePool,
    texture_view_pool: TextureViewPool,
    sampler_pool: SamplerPool,
    render_pipeline_pool: RenderPipelinePool,
    compute_pipeline_pool: ComputePipelinePool,
    bind_group_pool: BindGroupPool,
    bind_group_layout_pool: BindGroupLayoutPool,
    pipeline_layout_pool: PipelineLayoutPool,

    mipgens: std.AutoHashMap(wgpu.Texture.Format, MipgenResources),

    uniforms: struct {
        offset: u32 = 0,
        buffer: BufferHandle = .{},
        stage: struct {
            num: u32 = 0,
            current: u32 = 0,
            buffers: [uniforms_staging_pipeline_len]UniformsStagingBuffer =
                [_]UniformsStagingBuffer{.{}} ** uniforms_staging_pipeline_len,
        } = .{},
    } = .{},

    pub fn create(
        allocator: std.mem.Allocator,
        window: *sdl.SDL_Window,
        options: GraphicsContextOptions,
    ) !*GraphicsContext {
        const checkGraphicsApiSupport = (struct {
            fn impl() error{VulkanNotSupported}!void {
                // TODO: On Windows we should check if DirectX 12 is supported (Windows 10+).
                // On Linux we require Vulkan support.
            }
        }).impl;

        try wgpu.Impl.init(allocator, .{});

        checkGraphicsApiSupport() catch |err| switch (err) {
            error.VulkanNotSupported => {
                std.log.err("\n" ++
                    \\---------------------------------------------------------------------------
                    \\This program requires:  Vulkan graphics driver on Linux (OpenGL is NOT supported)
                    \\Please install latest supported driver and try again.
                    \\---------------------------------------------------------------------------
                    \\
                , .{});
                return err;
            },
        };

        const instance = wgpu.createInstance(null).?;

        const adapter = adapter: {
            const Response = struct {
                status: wgpu.RequestAdapterStatus = .unknown,
                adapter: *wgpu.Adapter = undefined,
            };

            const callback = struct {
                inline fn callback(
                    response: *Response,
                    status: wgpu.RequestAdapterStatus,
                    adapter: ?*wgpu.Adapter,
                    message: ?[*:0]const u8,
                ) void {
                    _ = message;
                    response.status = status;
                    response.adapter = adapter.?;
                }
            }.callback;

            var response = Response{};
            instance.requestAdapter(
                &.{ .power_preference = .high_performance },
                &response,
                callback,
            );

            if (response.status != .success) {
                std.log.err("Failed to request GPU adapter (status: {s}).", .{@tagName(response.status)});
                return error.NoGraphicsAdapter;
            }
            break :adapter response.adapter;
        };
        errdefer adapter.release();

        std.debug.print("1 ---------------- {?}\n", .{adapter});

        // var properties: wgpu.Adapter.Properties = undefined;
        // // properties.next_in_chain = null;
        // adapter.getProperties(&properties);
        // std.debug.print("2 ---------------- {}\n", .{properties});
        // std.log.info("[zgpu] High-performance device has been selected:", .{});
        // std.log.info("[zgpu]   Name: {s}", .{properties.name});
        // std.log.info("[zgpu]   Driver: {s}", .{properties.driver_description});
        // std.log.info("[zgpu]   Adapter type: {s}", .{@tagName(properties.adapter_type)});
        // std.log.info("[zgpu]   Backend type: {s}", .{@tagName(properties.backend_type)});

        const device = device: {
            const Response = struct {
                status: wgpu.RequestDeviceStatus = .unknown,
                device: *wgpu.Device = undefined,
            };

            const callback = (struct {
                inline fn callback(
                    resp: *Response,
                    status: wgpu.RequestDeviceStatus,
                    device: *wgpu.Device,
                    message: ?[*:0]const u8,
                ) void {
                    resp.status = status;
                    resp.device = device;
                    if (status != .success)
                        std.debug.print("error creating device: {?s}\n", .{message});
                }
            }).callback;

            const DeviceLostResponse = struct {
                reason: wgpu.Device.LostReason,
                message: [*:0]const u8,
            };

            const device_lost_callback = (struct {
                fn device_lost_callback(
                    reason: wgpu.Device.LostReason,
                    message: [*:0]const u8,
                    userdata: ?*anyopaque,
                ) callconv(.C) void {
                    const response = @as(*DeviceLostResponse, @ptrCast(@alignCast(userdata)));
                    response.reason = reason;
                    response.message = message;
                }
            }).device_lost_callback;

            const toggles = [_][*:0]const u8{ "skip_validation", "disable_symbol_renaming", "use_user_defined_labels_in_backend" };
            const dawn_toggles = wgpu.dawn.TogglesDescriptor{
                .chain = .{ .next = null, .s_type = .dawn_toggles_descriptor },
                .enabled_toggles_count = toggles.len,
                .enabled_toggles = &toggles,
            };

            var response = Response{};
            adapter.requestDevice(
                &wgpu.Device.Descriptor{
                    .next_in_chain = if (dawn_skip_validation)
                        @ptrCast(&dawn_toggles)
                    else
                        .{ .generic = null },
                    .device_lost_callback = device_lost_callback,
                    .device_lost_userdata = @ptrCast(&response),
                },
                &response,
                callback,
            );

            if (response.status != .success) {
                std.log.err("Failed to request GPU device (status: {s}).", .{@tagName(response.status)});
                return error.NoGraphicsDevice;
            }
            break :device response.device;
        };
        errdefer device.release();

        device.setUncapturedErrorCallback(logUnhandledError, null);

        const surface = createSurfaceForWindow(instance, window);
        errdefer surface.release();

        var w: c_int = 0;
        var h: c_int = 0;
        _ = sdl.SDL_GetWindowSizeInPixels(window, &w, &h);

        const swapchain_descriptor = wgpu.SwapChain.Descriptor{
            .label = "gctx-swapchain",
            .usage = .{ .render_attachment = true },
            .format = swapchain_format,
            .width = @intCast(w),
            .height = @intCast(h),
            .present_mode = options.present_mode,
        };
        const swapchain = device.createSwapChain(surface, &swapchain_descriptor);
        errdefer swapchain.release();

        const gctx = try allocator.create(GraphicsContext);
        gctx.* = .{
            .allocator = allocator,
            .window = window,
            .instance = instance,
            .device = device,
            .queue = device.getQueue(),
            .surface = surface,
            .swapchain = swapchain,
            .swapchain_descriptor = swapchain_descriptor,
            .buffer_pool = BufferPool.init(allocator, 256),
            .texture_pool = TexturePool.init(allocator, 256),
            .texture_view_pool = TextureViewPool.init(allocator, 256),
            .sampler_pool = SamplerPool.init(allocator, 16),
            .render_pipeline_pool = RenderPipelinePool.init(allocator, 128),
            .compute_pipeline_pool = ComputePipelinePool.init(allocator, 128),
            .bind_group_pool = BindGroupPool.init(allocator, 32),
            .bind_group_layout_pool = BindGroupLayoutPool.init(allocator, 32),
            .pipeline_layout_pool = PipelineLayoutPool.init(allocator, 32),
            .mipgens = std.AutoHashMap(wgpu.Texture.Format, MipgenResources).init(allocator),
        };

        uniformsInit(gctx);
        return gctx;
    }

    pub fn deinit(gctx: *GraphicsContext) void {
        // Wait for the GPU to finish all encoded commands.
        while (gctx.stats.cpu_frame_number != gctx.stats.gpu_frame_number) {
            gctx.device.tick();
        }

        // Wait for all outstanding mapAsync() calls to complete.
        wait_loop: while (true) {
            gctx.device.tick();
            var i: u32 = 0;
            while (i < gctx.uniforms.stage.num) : (i += 1) {
                if (gctx.uniforms.stage.buffers[i].slice == null) {
                    continue :wait_loop;
                }
            }
            break;
        }

        gctx.mipgens.deinit();
        gctx.pipeline_layout_pool.deinit(gctx.allocator);
        gctx.bind_group_pool.deinit(gctx.allocator);
        gctx.bind_group_layout_pool.deinit(gctx.allocator);
        gctx.buffer_pool.deinit(gctx.allocator);
        gctx.texture_view_pool.deinit(gctx.allocator);
        gctx.texture_pool.deinit(gctx.allocator);
        gctx.sampler_pool.deinit(gctx.allocator);
        gctx.render_pipeline_pool.deinit(gctx.allocator);
        gctx.compute_pipeline_pool.deinit(gctx.allocator);
        gctx.surface.release();
        gctx.swapchain.release();
        gctx.queue.release();
        gctx.device.release();
        // allocator.destroy(gctx);
    }

    //
    // Uniform buffer pool
    //
    pub fn uniformsAllocate(
        gctx: *GraphicsContext,
        comptime T: type,
        num_elements: u32,
    ) struct { slice: []T, offset: u32 } {
        assert(num_elements > 0);
        const size = num_elements * @sizeOf(T);

        const offset = gctx.uniforms.offset;
        const aligned_size = (size + (uniforms_alloc_alignment - 1)) & ~(uniforms_alloc_alignment - 1);
        if ((offset + aligned_size) >= uniforms_buffer_size) {
            std.log.err("[zgpu] Uniforms buffer size is too small. " ++
                "Consider increasing 'zgpu.BuildOptions.uniforms_buffer_size' constant.", .{});
            return .{ .slice = @as([*]T, undefined)[0..0], .offset = 0 };
        }

        const current = gctx.uniforms.stage.current;
        const slice = (gctx.uniforms.stage.buffers[current].slice.?.ptr + offset)[0..size];

        gctx.uniforms.offset += aligned_size;
        return .{
            .slice = std.mem.bytesAsSlice(T, @as([]align(@alignOf(T)) u8, @alignCast(slice))),
            .offset = offset,
        };
    }

    const UniformsStagingBuffer = struct {
        slice: ?[]u8 = null,
        buffer: *wgpu.Buffer = undefined,
    };
    const uniforms_buffer_size = 4 * 1024 * 1024;
    const uniforms_staging_pipeline_len = 8;
    const uniforms_alloc_alignment: u32 = 256;

    fn uniformsInit(gctx: *GraphicsContext) void {
        gctx.uniforms.buffer = gctx.createBuffer(.{
            .usage = .{ .copy_dst = true, .uniform = true },
            .size = uniforms_buffer_size,
        });
        gctx.uniformsNextStagingBuffer();
    }

    inline fn uniformsMappedCallback(usb: *UniformsStagingBuffer, status: wgpu.Buffer.MapAsyncStatus) void {
        assert(usb.slice == null);
        if (status == .success) {
            usb.slice = usb.buffer.getMappedRange(u8, 0, uniforms_buffer_size).?;
        } else {
            std.log.err("[zgpu] Failed to map buffer (status: {s}).", .{@tagName(status)});
        }
    }

    fn uniformsNextStagingBuffer(gctx: *GraphicsContext) void {
        if (gctx.stats.cpu_frame_number > 0) {
            // Map staging buffer which was used this frame.
            const current = gctx.uniforms.stage.current;
            assert(gctx.uniforms.stage.buffers[current].slice == null);
            gctx.uniforms.stage.buffers[current].buffer.mapAsync(
                .{ .write = true },
                0,
                uniforms_buffer_size,
                &gctx.uniforms.stage.buffers[current],
                uniformsMappedCallback,
            );
        }

        gctx.uniforms.offset = 0;

        var i: u32 = 0;
        while (i < gctx.uniforms.stage.num) : (i += 1) {
            if (gctx.uniforms.stage.buffers[i].slice != null) {
                gctx.uniforms.stage.current = i;
                return;
            }
        }

        if (gctx.uniforms.stage.num >= uniforms_staging_pipeline_len) {
            // Wait until one of the buffers is mapped and ready to use.
            while (true) {
                gctx.device.tick();

                i = 0;
                while (i < gctx.uniforms.stage.num) : (i += 1) {
                    if (gctx.uniforms.stage.buffers[i].slice != null) {
                        gctx.uniforms.stage.current = i;
                        return;
                    }
                }
            }
        }

        assert(gctx.uniforms.stage.num < uniforms_staging_pipeline_len);
        const current = gctx.uniforms.stage.num;
        gctx.uniforms.stage.current = current;
        gctx.uniforms.stage.num += 1;

        // Create new staging buffer.
        const buffer_handle = gctx.createBuffer(.{
            .usage = .{ .copy_src = true, .map_write = true },
            .size = uniforms_buffer_size,
            .mapped_at_creation = .true,
        });

        // Add new (mapped) staging buffer to the buffer list.
        gctx.uniforms.stage.buffers[current] = .{
            .slice = gctx.lookupResource(buffer_handle).?.getMappedRange(u8, 0, uniforms_buffer_size).?,
            .buffer = gctx.lookupResource(buffer_handle).?,
        };
    }

    //
    // Submit/Present
    //
    pub fn submit(gctx: *GraphicsContext, commands: []*const wgpu.CommandBuffer) void {
        const stage_commands = stage_commands: {
            const stage_encoder = gctx.device.createCommandEncoder(null);
            defer stage_encoder.release();

            const current = gctx.uniforms.stage.current;
            assert(gctx.uniforms.stage.buffers[current].slice != null);

            gctx.uniforms.stage.buffers[current].slice = null;
            gctx.uniforms.stage.buffers[current].buffer.unmap();

            if (gctx.uniforms.offset > 0) {
                stage_encoder.copyBufferToBuffer(
                    gctx.uniforms.stage.buffers[current].buffer,
                    0,
                    gctx.lookupResource(gctx.uniforms.buffer).?,
                    0,
                    gctx.uniforms.offset,
                );
            }

            break :stage_commands stage_encoder.finish(null);
        };
        defer stage_commands.release();

        // TODO: We support up to 32 command buffers for now. Make it more robust.
        var command_buffers = std.BoundedArray(wgpu.CommandBuffer, 32).init(0) catch unreachable;
        command_buffers.append(stage_commands) catch unreachable;
        command_buffers.appendSlice(commands) catch unreachable;

        gctx.queue.onSubmittedWorkDone(0, gpuWorkDone, @ptrCast(&gctx.stats.gpu_frame_number));
        gctx.queue.submit(command_buffers.slice());

        gctx.stats.tick();
        gctx.uniformsNextStagingBuffer();
    }

    fn gpuWorkDone(status: wgpu.QueueWorkDoneStatus, userdata: ?*anyopaque) callconv(.C) void {
        const gpu_frame_number: *u64 = @ptrCast(@alignCast(userdata));
        gpu_frame_number.* += 1;
        if (status != .success) {
            std.log.err("[zgpu] Failed to complete GPU work (status: {s}).", .{@tagName(status)});
        }
    }

    pub fn present(gctx: *GraphicsContext) enum {
        normal_execution,
        swap_chain_resized,
    } {
        gctx.swapchain.present();

        var w: c_int = undefined;
        var h: c_int = undefined;
        _ = sdl.SDL_GetWindowSizeInPixels(gctx.window, &w, &h);

        if (gctx.swapchain_descriptor.width != @as(u32, @intCast(w)) or gctx.swapchain_descriptor.height != @as(u32, @intCast(h))) {
            if (w != 0 and h != 0) {
                gctx.swapchain_descriptor.width = @intCast(w);
                gctx.swapchain_descriptor.height = @intCast(h);
                gctx.swapchain.release();

                gctx.swapchain = gctx.device.createSwapChain(gctx.surface, &gctx.swapchain_descriptor);

                std.log.info(
                    "Window has been resized to: {d}x{d}.",
                    .{ gctx.swapchain_descriptor.width, gctx.swapchain_descriptor.height },
                );
                return .swap_chain_resized;
            }
        }

        return .normal_execution;
    }

    //
    // Resources
    //
    pub fn createBuffer(gctx: *GraphicsContext, descriptor: wgpu.Buffer.Descriptor) BufferHandle {
        return gctx.buffer_pool.addResource(gctx.*, .{
            .gpuobj = gctx.device.createBuffer(&descriptor),
            .size = descriptor.size,
            .usage = descriptor.usage,
        });
    }

    pub const BufferInitDescriptor = struct {
        label: ?[*:0]const u8 = null,
        usage: wgpu.Buffer.UsageFlags,
        contents: []const u8,
    };

    pub fn createBufferWithData(gctx: *GraphicsContext, descriptor: BufferInitDescriptor) BufferHandle {
        const buffer_size = descriptor.contents.len * @sizeOf(u8);

        const buffer = gctx.buffer_pool.addResource(gctx.*, .{
            .gpuobj = gctx.device.createBuffer(&.{
                .label = descriptor.label,
                .usage = descriptor.usage,
                .size = buffer_size,
            }),
            .size = buffer_size,
            .usage = descriptor.usage,
        });

        gctx.queue.writeBuffer(gctx.buffer_pool.getGpuObj(buffer).?, 0, descriptor.contents);
        return buffer;
    }

    pub fn createTexture(gctx: *GraphicsContext, descriptor: wgpu.Texture.Descriptor) TextureHandle {
        return gctx.texture_pool.addResource(gctx.*, .{
            .gpuobj = gctx.device.createTexture(&descriptor),
            .usage = descriptor.usage,
            .dimension = descriptor.dimension,
            .size = descriptor.size,
            .format = descriptor.format,
            .mip_level_count = descriptor.mip_level_count,
            .sample_count = descriptor.sample_count,
        });
    }

    pub fn createTextureView(
        gctx: *GraphicsContext,
        texture_handle: TextureHandle,
        descriptor: wgpu.TextureView.Descriptor,
    ) TextureViewHandle {
        const texture = gctx.lookupResource(texture_handle).?;
        const info = gctx.lookupResourceInfo(texture_handle).?;
        var dim = descriptor.dimension;
        if (dim == .dimension_undefined) {
            dim = switch (info.dimension) {
                .dimension_1d => .dimension_1d,
                .dimension_2d => .dimension_2d,
                .dimension_3d => .dimension_3d,
            };
        }
        return gctx.texture_view_pool.addResource(gctx.*, .{
            .gpuobj = texture.createView(&descriptor),
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

    pub fn createSampler(gctx: *GraphicsContext, descriptor: wgpu.Sampler.Descriptor) SamplerHandle {
        return gctx.sampler_pool.addResource(gctx.*, .{
            .gpuobj = gctx.device.createSampler(&descriptor),
            .address_mode_u = descriptor.address_mode_u,
            .address_mode_v = descriptor.address_mode_v,
            .address_mode_w = descriptor.address_mode_w,
            .mag_filter = descriptor.mag_filter,
            .min_filter = descriptor.min_filter,
            .mipmap_filter = descriptor.mipmap_filter,
            .lod_min_clamp = descriptor.lod_min_clamp,
            .lod_max_clamp = descriptor.lod_max_clamp,
            .compare = descriptor.compare,
            .max_anisotropy = descriptor.max_anisotropy,
        });
    }

    pub fn createRenderPipeline(
        gctx: *GraphicsContext,
        pipeline_layout: PipelineLayoutHandle,
        descriptor: wgpu.RenderPipelineDescriptor,
    ) RenderPipelineHandle {
        var desc = descriptor;
        desc.layout = gctx.lookupResource(pipeline_layout) orelse null;
        return gctx.render_pipeline_pool.addResource(gctx.*, .{
            .gpuobj = gctx.device.createRenderPipeline(desc),
            .pipeline_layout_handle = pipeline_layout,
        });
    }

    const AsyncCreateOpRender = struct {
        gctx: *GraphicsContext,
        result: *RenderPipelineHandle,
        pipeline_layout: PipelineLayoutHandle,
        allocator: std.mem.Allocator,

        fn create(
            status: wgpu.CreatePipelineAsyncStatus,
            pipeline: wgpu.RenderPipeline,
            message: ?[*:0]const u8,
            userdata: ?*anyopaque,
        ) callconv(.C) void {
            const op = @as(*AsyncCreateOpRender, @ptrCast(@alignCast(userdata)));
            if (status == .success) {
                op.result.* = op.gctx.render_pipeline_pool.addResource(
                    op.gctx.*,
                    .{ .gpuobj = pipeline, .pipeline_layout_handle = op.pipeline_layout },
                );
            } else {
                std.log.err(
                    "[zgpu] Failed to async create render pipeline (status: {s}, message: {?s}).",
                    .{ @tagName(status), message },
                );
            }
            op.allocator.destroy(op);
        }
    };

    pub fn createRenderPipelineAsync(
        gctx: *GraphicsContext,
        allocator: std.mem.Allocator,
        pipeline_layout: PipelineLayoutHandle,
        descriptor: wgpu.RenderPipelineDescriptor,
        result: *RenderPipelineHandle,
    ) void {
        var desc = descriptor;
        desc.layout = gctx.lookupResource(pipeline_layout) orelse null;

        const op = allocator.create(AsyncCreateOpRender) catch unreachable;
        op.* = .{
            .gctx = gctx,
            .result = result,
            .pipeline_layout = pipeline_layout,
            .allocator = allocator,
        };
        gctx.device.createRenderPipelineAsync(desc, AsyncCreateOpRender.create, @ptrCast(op));
    }

    pub fn createComputePipeline(
        gctx: *GraphicsContext,
        pipeline_layout: PipelineLayoutHandle,
        descriptor: wgpu.ComputePipelineDescriptor,
    ) ComputePipelineHandle {
        var desc = descriptor;
        desc.layout = gctx.lookupResource(pipeline_layout) orelse null;
        return gctx.compute_pipeline_pool.addResource(gctx.*, .{
            .gpuobj = gctx.device.createComputePipeline(desc),
            .pipeline_layout_handle = pipeline_layout,
        });
    }

    const AsyncCreateOpCompute = struct {
        gctx: *GraphicsContext,
        result: *ComputePipelineHandle,
        pipeline_layout: PipelineLayoutHandle,
        allocator: std.mem.Allocator,

        fn create(
            status: wgpu.CreatePipelineAsyncStatus,
            pipeline: wgpu.ComputePipeline,
            message: ?[*:0]const u8,
            userdata: ?*anyopaque,
        ) callconv(.C) void {
            const op = @as(*AsyncCreateOpCompute, @ptrCast(@alignCast(userdata)));
            if (status == .success) {
                op.result.* = op.gctx.compute_pipeline_pool.addResource(
                    op.gctx.*,
                    .{ .gpuobj = pipeline, .pipeline_layout_handle = op.pipeline_layout },
                );
            } else {
                std.log.err(
                    "[zgpu] Failed to async create compute pipeline (status: {s}, message: {?s}).",
                    .{ @tagName(status), message },
                );
            }
            op.allocator.destroy(op);
        }
    };

    pub fn createComputePipelineAsync(
        gctx: *GraphicsContext,
        allocator: std.mem.Allocator,
        pipeline_layout: PipelineLayoutHandle,
        descriptor: wgpu.ComputePipelineDescriptor,
        result: *ComputePipelineHandle,
    ) void {
        var desc = descriptor;
        desc.layout = gctx.lookupResource(pipeline_layout) orelse null;

        const op = allocator.create(AsyncCreateOpCompute) catch unreachable;
        op.* = .{
            .gctx = gctx,
            .result = result,
            .pipeline_layout = pipeline_layout,
            .allocator = allocator,
        };
        gctx.device.createComputePipelineAsync(desc, AsyncCreateOpCompute.create, @ptrCast(op));
    }

    pub fn createBindGroup(
        gctx: *GraphicsContext,
        layout: BindGroupLayoutHandle,
        entries: []const BindGroupEntryInfo,
    ) BindGroupHandle {
        assert(entries.len > 0 and entries.len <= max_num_bindings_per_group);

        var bind_group_info = BindGroupInfo{ .num_entries = @intCast(entries.len) };
        var gpu_bind_group_entries: [max_num_bindings_per_group]wgpu.BindGroup.Entry = undefined;

        for (entries, 0..) |entry, i| {
            bind_group_info.entries[i] = entry;

            if (entries[i].buffer_handle) |handle| {
                gpu_bind_group_entries[i] = .{
                    .binding = entries[i].binding,
                    .buffer = gctx.lookupResource(handle).?,
                    .offset = entries[i].offset,
                    .size = entries[i].size,
                    .sampler = null,
                    .texture_view = null,
                };
            } else if (entries[i].sampler_handle) |handle| {
                gpu_bind_group_entries[i] = .{
                    .binding = entries[i].binding,
                    .buffer = null,
                    .offset = 0,
                    .size = 0,
                    .sampler = gctx.lookupResource(handle).?,
                    .texture_view = null,
                };
            } else if (entries[i].texture_view_handle) |handle| {
                gpu_bind_group_entries[i] = .{
                    .binding = entries[i].binding,
                    .buffer = null,
                    .offset = 0,
                    .size = 0,
                    .sampler = null,
                    .texture_view = gctx.lookupResource(handle).?,
                };
            } else unreachable;
        }
        bind_group_info.gpuobj = gctx.device.createBindGroup(&.{
            .layout = gctx.lookupResource(layout).?,
            .entry_count = @intCast(entries.len),
            .entries = &gpu_bind_group_entries,
        });
        return gctx.bind_group_pool.addResource(gctx.*, bind_group_info);
    }

    pub fn createBindGroupLayout(
        gctx: *GraphicsContext,
        entries: []const wgpu.BindGroupLayout.Entry,
    ) BindGroupLayoutHandle {
        assert(entries.len > 0 and entries.len <= max_num_bindings_per_group);

        var bind_group_layout_info = BindGroupLayoutInfo{
            .gpuobj = gctx.device.createBindGroupLayout(&.{
                .entry_count = @intCast(entries.len),
                .entries = entries.ptr,
            }),
            .num_entries = @intCast(entries.len),
        };
        for (entries, 0..) |entry, i| {
            bind_group_layout_info.entries[i] = entry;
            // bind_group_layout_info.entries[i].next_in_chain = .{};
            bind_group_layout_info.entries[i].buffer.next_in_chain = null;
            bind_group_layout_info.entries[i].sampler.next_in_chain = null;
            bind_group_layout_info.entries[i].texture.next_in_chain = null;
            bind_group_layout_info.entries[i].storage_texture.next_in_chain = null;
        }
        return gctx.bind_group_layout_pool.addResource(gctx.*, bind_group_layout_info);
    }

    pub fn createBindGroupLayoutAuto(
        gctx: *GraphicsContext,
        pipeline: anytype,
        group_index: u32,
    ) BindGroupLayoutHandle {
        const bgl = gctx.lookupResource(pipeline).?.getBindGroupLayout(group_index);
        return gctx.bind_group_layout_pool.addResource(gctx.*, BindGroupLayoutInfo{ .gpuobj = bgl });
    }

    pub fn createPipelineLayout(
        gctx: *GraphicsContext,
        bind_group_layouts: []const BindGroupLayoutHandle,
    ) PipelineLayoutHandle {
        assert(bind_group_layouts.len > 0);

        var info: PipelineLayoutInfo = .{ .num_bind_group_layouts = @as(u32, @intCast(bind_group_layouts.len)) };
        var gpu_bind_group_layouts: [max_num_bind_groups_per_pipeline]wgpu.BindGroupLayout = undefined;

        for (bind_group_layouts, 0..) |bgl, i| {
            info.bind_group_layouts[i] = bgl;
            gpu_bind_group_layouts[i] = gctx.lookupResource(bgl).?;
        }

        info.gpuobj = gctx.device.createPipelineLayout(.{
            .bind_group_layout_count = info.num_bind_group_layouts,
            .bind_group_layouts = &gpu_bind_group_layouts,
        });

        return gctx.pipeline_layout_pool.addResource(gctx.*, info);
    }

    pub fn lookupResource(gctx: GraphicsContext, handle: anytype) ?*handleToGpuResourceType(@TypeOf(handle)) {
        if (gctx.isResourceValid(handle)) {
            const T = @TypeOf(handle);
            return switch (T) {
                BufferHandle => gctx.buffer_pool.getGpuObj(handle).?,
                TextureHandle => gctx.texture_pool.getGpuObj(handle).?,
                TextureViewHandle => gctx.texture_view_pool.getGpuObj(handle).?,
                SamplerHandle => gctx.sampler_pool.getGpuObj(handle).?,
                RenderPipelineHandle => gctx.render_pipeline_pool.getGpuObj(handle).?,
                ComputePipelineHandle => gctx.compute_pipeline_pool.getGpuObj(handle).?,
                BindGroupHandle => gctx.bind_group_pool.getGpuObj(handle).?,
                BindGroupLayoutHandle => gctx.bind_group_layout_pool.getGpuObj(handle).?,
                PipelineLayoutHandle => gctx.pipeline_layout_pool.getGpuObj(handle).?,
                else => @compileError(
                    "[zgpu] GraphicsContext.lookupResource() not implemented for " ++ @typeName(T),
                ),
            };
        }
        return null;
    }

    pub fn lookupResourceInfo(gctx: GraphicsContext, handle: anytype) ?handleToResourceInfoType(@TypeOf(handle)) {
        if (gctx.isResourceValid(handle)) {
            const T = @TypeOf(handle);
            return switch (T) {
                BufferHandle => gctx.buffer_pool.getInfo(handle),
                TextureHandle => gctx.texture_pool.getInfo(handle),
                TextureViewHandle => gctx.texture_view_pool.getInfo(handle),
                SamplerHandle => gctx.sampler_pool.getInfo(handle),
                RenderPipelineHandle => gctx.render_pipeline_pool.getInfo(handle),
                ComputePipelineHandle => gctx.compute_pipeline_pool.getInfo(handle),
                BindGroupHandle => gctx.bind_group_pool.getInfo(handle),
                BindGroupLayoutHandle => gctx.bind_group_layout_pool.getInfo(handle),
                PipelineLayoutHandle => gctx.pipeline_layout_pool.getInfo(handle),
                else => @compileError(
                    "[zgpu] GraphicsContext.lookupResourceInfo() not implemented for " ++ @typeName(T),
                ),
            };
        }
        return null;
    }

    pub fn releaseResource(gctx: *GraphicsContext, handle: anytype) void {
        const T = @TypeOf(handle);
        switch (T) {
            BufferHandle => gctx.buffer_pool.destroyResource(handle, false),
            TextureHandle => gctx.texture_pool.destroyResource(handle, false),
            TextureViewHandle => gctx.texture_view_pool.destroyResource(handle, false),
            SamplerHandle => gctx.sampler_pool.destroyResource(handle, false),
            RenderPipelineHandle => gctx.render_pipeline_pool.destroyResource(handle, false),
            ComputePipelineHandle => gctx.compute_pipeline_pool.destroyResource(handle, false),
            BindGroupHandle => gctx.bind_group_pool.destroyResource(handle, false),
            BindGroupLayoutHandle => gctx.bind_group_layout_pool.destroyResource(handle, false),
            PipelineLayoutHandle => gctx.pipeline_layout_pool.destroyResource(handle, false),
            else => @compileError("[zgpu] GraphicsContext.releaseResource() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn destroyResource(gctx: *GraphicsContext, handle: anytype) void {
        const T = @TypeOf(handle);
        switch (T) {
            BufferHandle => gctx.buffer_pool.destroyResource(handle, true),
            TextureHandle => gctx.texture_pool.destroyResource(handle, true),
            else => @compileError("[zgpu] GraphicsContext.destroyResource() not implemented for " ++ @typeName(T)),
        }
    }

    pub fn isResourceValid(gctx: GraphicsContext, handle: anytype) bool {
        const T = @TypeOf(handle);
        switch (T) {
            BufferHandle => return gctx.buffer_pool.isHandleValid(handle),
            TextureHandle => return gctx.texture_pool.isHandleValid(handle),
            TextureViewHandle => {
                if (gctx.texture_view_pool.isHandleValid(handle)) {
                    const texture = gctx.texture_view_pool.getInfoPtr(handle).parent_texture_handle;
                    return gctx.isResourceValid(texture);
                }
                return false;
            },
            SamplerHandle => return gctx.sampler_pool.isHandleValid(handle),
            RenderPipelineHandle => return gctx.render_pipeline_pool.isHandleValid(handle),
            ComputePipelineHandle => return gctx.compute_pipeline_pool.isHandleValid(handle),
            BindGroupHandle => {
                if (gctx.bind_group_pool.isHandleValid(handle)) {
                    const num_entries = gctx.bind_group_pool.getInfoPtr(handle).num_entries;
                    const entries = &gctx.bind_group_pool.getInfoPtr(handle).entries;
                    var i: u32 = 0;
                    while (i < num_entries) : (i += 1) {
                        if (entries[i].buffer_handle) |buffer| {
                            if (!gctx.isResourceValid(buffer))
                                return false;
                        } else if (entries[i].sampler_handle) |sampler| {
                            if (!gctx.isResourceValid(sampler))
                                return false;
                        } else if (entries[i].texture_view_handle) |texture_view| {
                            if (!gctx.isResourceValid(texture_view))
                                return false;
                        } else unreachable;
                    }
                    return true;
                }
                return false;
            },
            BindGroupLayoutHandle => return gctx.bind_group_layout_pool.isHandleValid(handle),
            PipelineLayoutHandle => return gctx.pipeline_layout_pool.isHandleValid(handle),
            else => @compileError("[zgpu] GraphicsContext.isResourceValid() not implemented for " ++ @typeName(T)),
        }
    }

    //
    // Mipmaps
    //
    const MipgenResources = struct {
        pipeline: ComputePipelineHandle = .{},
        scratch_texture: TextureHandle = .{},
        scratch_texture_views: [max_levels_per_dispatch]TextureViewHandle =
            [_]TextureViewHandle{.{}} ** max_levels_per_dispatch,
        bind_group_layout: BindGroupLayoutHandle = .{},

        const max_levels_per_dispatch = 4;
    };

    pub fn generateMipmaps(
        gctx: *GraphicsContext,
        arena: std.mem.Allocator,
        encoder: wgpu.CommandEncoder,
        texture: TextureHandle,
    ) void {
        const texture_info = gctx.lookupResourceInfo(texture) orelse return;
        if (texture_info.mip_level_count == 1) return;

        const max_size = 2048;

        assert(texture_info.usage.copy_dst == true);
        assert(texture_info.dimension == .tdim_2d);
        assert(texture_info.size.width <= max_size and texture_info.size.height <= max_size);
        assert(texture_info.size.width == texture_info.size.height);
        assert(math.isPowerOfTwo(texture_info.size.width));

        const format = texture_info.format;
        const entry = gctx.mipgens.getOrPut(format) catch unreachable;
        const mipgen = entry.value_ptr;

        if (!entry.found_existing) {
            mipgen.bind_group_layout = gctx.createBindGroupLayout(&.{
                bufferEntry(0, .{ .compute = true }, .uniform, true, 0),
                textureEntry(1, .{ .compute = true }, .unfilterable_float, .tvdim_2d, false),
                storageTextureEntry(2, .{ .compute = true }, .write_only, format, .tvdim_2d),
                storageTextureEntry(3, .{ .compute = true }, .write_only, format, .tvdim_2d),
                storageTextureEntry(4, .{ .compute = true }, .write_only, format, .tvdim_2d),
                storageTextureEntry(5, .{ .compute = true }, .write_only, format, .tvdim_2d),
            });

            const pipeline_layout = gctx.createPipelineLayout(&.{
                mipgen.bind_group_layout,
            });
            defer gctx.releaseResource(pipeline_layout);

            const wgsl_src = wgsl.csGenerateMipmaps(arena, formatToShaderFormat(format));
            const cs_module = createWgslShaderModule(gctx.device, wgsl_src, "zgpu_cs_generate_mipmaps");
            defer {
                arena.free(wgsl_src);
                cs_module.release();
            }

            mipgen.pipeline = gctx.createComputePipeline(pipeline_layout, .{
                .compute = .{
                    .module = cs_module,
                    .entry_point = "main",
                },
            });

            mipgen.scratch_texture = gctx.createTexture(.{
                .usage = .{ .copy_src = true, .storage_binding = true },
                .dimension = .tdim_2d,
                .size = .{ .width = max_size / 2, .height = max_size / 2, .depth_or_array_layers = 1 },
                .format = format,
                .mip_level_count = MipgenResources.max_levels_per_dispatch,
                .sample_count = 1,
            });

            for (&mipgen.scratch_texture_views, 0..) |*view, i| {
                view.* = gctx.createTextureView(mipgen.scratch_texture, .{
                    .base_mip_level = @intCast(i),
                    .mip_level_count = 1,
                    .base_array_layer = 0,
                    .array_layer_count = 1,
                });
            }
        }

        var array_layer: u32 = 0;
        while (array_layer < texture_info.size.depth_or_array_layers) : (array_layer += 1) {
            const texture_view = gctx.createTextureView(texture, .{
                .dimension = .tvdim_2d,
                .base_array_layer = array_layer,
                .array_layer_count = 1,
            });
            defer gctx.releaseResource(texture_view);

            const bind_group = gctx.createBindGroup(mipgen.bind_group_layout, &[_]BindGroupEntryInfo{
                .{ .binding = 0, .buffer_handle = gctx.uniforms.buffer, .offset = 0, .size = 8 },
                .{ .binding = 1, .texture_view_handle = texture_view },
                .{ .binding = 2, .texture_view_handle = mipgen.scratch_texture_views[0] },
                .{ .binding = 3, .texture_view_handle = mipgen.scratch_texture_views[1] },
                .{ .binding = 4, .texture_view_handle = mipgen.scratch_texture_views[2] },
                .{ .binding = 5, .texture_view_handle = mipgen.scratch_texture_views[3] },
            });
            defer gctx.releaseResource(bind_group);

            const MipgenUniforms = extern struct {
                src_mip_level: i32,
                num_mip_levels: u32,
            };

            var total_num_mips: u32 = texture_info.mip_level_count - 1;
            var current_src_mip_level: u32 = 0;

            while (true) {
                const dispatch_num_mips = @min(MipgenResources.max_levels_per_dispatch, total_num_mips);
                {
                    const pass = encoder.beginComputePass(null);
                    defer {
                        pass.end();
                        pass.release();
                    }

                    pass.setPipeline(gctx.lookupResource(mipgen.pipeline).?);

                    const mem = gctx.uniformsAllocate(MipgenUniforms, 1);
                    mem.slice[0] = .{
                        .src_mip_level = @intCast(current_src_mip_level),
                        .num_mip_levels = dispatch_num_mips,
                    };
                    pass.setBindGroup(0, gctx.lookupResource(bind_group).?, &.{mem.offset});

                    pass.dispatchWorkgroups(
                        @max(texture_info.size.width >> @intCast(3 + current_src_mip_level), 1),
                        @max(texture_info.size.height >> @intCast(3 + current_src_mip_level), 1),
                        1,
                    );
                }

                var mip_index: u32 = 0;
                while (mip_index < dispatch_num_mips) : (mip_index += 1) {
                    const src_origin = wgpu.Origin3D{ .x = 0, .y = 0, .z = 0 };
                    const dst_origin = wgpu.Origin3D{ .x = 0, .y = 0, .z = array_layer };
                    encoder.copyTextureToTexture(
                        .{
                            .texture = gctx.lookupResource(mipgen.scratch_texture).?,
                            .mip_level = mip_index,
                            .origin = src_origin,
                        },
                        .{
                            .texture = gctx.lookupResource(texture).?,
                            .mip_level = mip_index + current_src_mip_level + 1,
                            .origin = dst_origin,
                        },
                        .{
                            .width = texture_info.size.width >> @intCast(mip_index + current_src_mip_level + 1),
                            .height = texture_info.size.height >> @intCast(mip_index + current_src_mip_level + 1),
                        },
                    );
                }

                assert(total_num_mips >= dispatch_num_mips);
                total_num_mips -= dispatch_num_mips;
                if (total_num_mips == 0) {
                    break;
                }
                current_src_mip_level += dispatch_num_mips;
            }
        }
    }
};

/// Helper to create a buffer BindGroupLayoutEntry.
pub fn bufferEntry(
    binding: u32,
    visibility: wgpu.ShaderStageFlags,
    binding_type: wgpu.Buffer.BindingType,
    has_dynamic_offset: wgpu.Bool32,
    min_binding_size: u64,
) wgpu.BindGroupLayout.Entry {
    return .{
        .binding = binding,
        .visibility = visibility,
        .buffer = .{
            .type = binding_type,
            .has_dynamic_offset = has_dynamic_offset,
            .min_binding_size = min_binding_size,
        },
    };
}

/// Helper to create a sampler BindGroupLayoutEntry.
pub fn samplerEntry(
    binding: u32,
    visibility: wgpu.ShaderStage,
    binding_type: wgpu.SamplerBindingType,
) wgpu.BindGroupLayout.Entry {
    return .{
        .binding = binding,
        .visibility = visibility,
        .sampler = .{ .binding_type = binding_type },
    };
}

/// Helper to create a texture BindGroupLayoutEntry.
pub fn textureEntry(
    binding: u32,
    visibility: wgpu.ShaderStage,
    sample_type: wgpu.TextureSampleType,
    view_dimension: wgpu.TextureViewDimension,
    multisampled: bool,
) wgpu.BindGroupLayout.Entry {
    return .{
        .binding = binding,
        .visibility = visibility,
        .texture = .{
            .sample_type = sample_type,
            .view_dimension = view_dimension,
            .multisampled = multisampled,
        },
    };
}

/// Helper to create a storage texture BindGroupLayoutEntry.
pub fn storageTextureEntry(
    binding: u32,
    visibility: wgpu.ShaderStage,
    access: wgpu.StorageTextureAccess,
    format: wgpu.TextureFormat,
    view_dimension: wgpu.TextureViewDimension,
) wgpu.BindGroupLayout.Entry {
    return .{
        .binding = binding,
        .visibility = visibility,
        .storage_texture = .{
            .access = access,
            .format = format,
            .view_dimension = view_dimension,
        },
    };
}

/// You may disable async shader compilation for debugging purposes.
const enable_async_shader_compilation = true;

/// Helper function for creating render pipelines.
/// Supports: one vertex buffer, one non-blending render target,
/// one vertex shader module and one fragment shader module.
pub fn createRenderPipelineSimple(
    allocator: std.mem.Allocator,
    gctx: *GraphicsContext,
    bgls: []const BindGroupLayoutHandle,
    wgsl_vs: [:0]const u8,
    wgsl_fs: [:0]const u8,
    vertex_stride: ?u64,
    vertex_attribs: ?[]const wgpu.VertexAttribute,
    primitive_state: wgpu.PrimitiveState,
    rt_format: wgpu.TextureFormat,
    depth_state: ?wgpu.DepthStencilState,
    out_pipe: *RenderPipelineHandle,
) void {
    const pl = gctx.createPipelineLayout(bgls);
    defer gctx.releaseResource(pl);

    const vs_mod = createWgslShaderModule(gctx.device, wgsl_vs, null);
    defer vs_mod.release();

    const fs_mod = createWgslShaderModule(gctx.device, wgsl_fs, null);
    defer fs_mod.release();

    const color_targets = [_]wgpu.ColorTargetState{.{ .format = rt_format }};

    const vertex_buffers = if (vertex_stride) |vs| [_]wgpu.VertexBufferLayout{.{
        .array_stride = vs,
        .attribute_count = @intCast(vertex_attribs.?.len),
        .attributes = vertex_attribs.?.ptr,
    }} else null;

    const pipe_desc = wgpu.RenderPipelineDescriptor{
        .vertex = wgpu.VertexState{
            .module = vs_mod,
            .entry_point = "main",
            .buffer_count = if (vertex_buffers) |vbs| vbs.len else 0,
            .buffers = if (vertex_buffers) |vbs| &vbs else null,
        },
        .fragment = &wgpu.FragmentState{
            .module = fs_mod,
            .entry_point = "main",
            .target_count = color_targets.len,
            .targets = &color_targets,
        },
        .depth_stencil = if (depth_state) |ds| &ds else null,
        .primitive = primitive_state,
    };

    if (enable_async_shader_compilation) {
        gctx.createRenderPipelineAsync(allocator, pl, pipe_desc, out_pipe);
    } else {
        out_pipe.* = gctx.createRenderPipeline(pl, pipe_desc);
    }
}

/// Helper function for creating render passes.
/// Supports: One color attachment and optional depth attachment.
pub fn beginRenderPassSimple(
    encoder: *wgpu.CommandEncoder,
    load_op: wgpu.LoadOp,
    color_texv: *wgpu.TextureView,
    clear_color: ?wgpu.Color,
    depth_texv: ?*wgpu.TextureView,
    clear_depth: ?f32,
) *wgpu.RenderPassEncoder {
    if (depth_texv == null) {
        assert(clear_depth == null);
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

pub fn endReleasePass(pass: anytype) void {
    pass.end();
    pass.release();
}

pub fn createWgslShaderModule(
    device: wgpu.Device,
    source: [*:0]const u8,
    label: ?[*:0]const u8,
) wgpu.ShaderModule {
    const wgsl_desc = wgpu.ShaderModuleWgslDescriptor{
        .chain = .{ .next = null, .struct_type = .shader_module_wgsl_descriptor },
        .code = source,
    };
    const desc = wgpu.ShaderModuleDescriptor{
        .next_in_chain = @ptrCast(&wgsl_desc),
        .label = if (label) |l| l else null,
    };
    return device.createShaderModule(desc);
}

pub fn imageInfoToTextureFormat(num_components: u32, bytes_per_component: u32, is_hdr: bool) wgpu.TextureFormat {
    assert(num_components == 1 or num_components == 2 or num_components == 4);
    assert(bytes_per_component == 1 or bytes_per_component == 2);
    assert(if (is_hdr and bytes_per_component != 2) false else true);

    if (is_hdr) {
        if (num_components == 1) return .r16_float;
        if (num_components == 2) return .rg16_float;
        if (num_components == 4) return .rgba16_float;
    } else {
        if (bytes_per_component == 1) {
            if (num_components == 1) return .r8_unorm;
            if (num_components == 2) return .rg8_unorm;
            if (num_components == 4) return .rgba8_unorm;
        } else {
            // TODO: Looks like wgpu does not support 16 bit unorm formats.
            unreachable;
        }
    }
    unreachable;
}

pub const BufferInfo = struct {
    gpuobj: ?*wgpu.Buffer = null,
    size: usize = 0,
    usage: wgpu.Buffer.UsageFlags = .{},
};

pub const TextureInfo = struct {
    gpuobj: ?*wgpu.Texture = null,
    usage: wgpu.Texture.UsageFlags = .{},
    dimension: wgpu.Texture.Dimension = .dimension_1d,
    size: wgpu.Extent3D = .{ .width = 0 },
    format: wgpu.Texture.Format = .undefined,
    mip_level_count: u32 = 0,
    sample_count: u32 = 0,
};

pub const TextureViewInfo = struct {
    gpuobj: ?*wgpu.TextureView = null,
    format: wgpu.Texture.Format = .undefined,
    dimension: wgpu.TextureView.Dimension = .dimension_undefined,
    base_mip_level: u32 = 0,
    mip_level_count: u32 = 0,
    base_array_layer: u32 = 0,
    array_layer_count: u32 = 0,
    aspect: wgpu.Texture.Aspect = .all,
    parent_texture_handle: TextureHandle = .{},
};

pub const SamplerInfo = struct {
    gpuobj: ?*wgpu.Sampler = null,
    address_mode_u: wgpu.Sampler.AddressMode = .repeat,
    address_mode_v: wgpu.Sampler.AddressMode = .repeat,
    address_mode_w: wgpu.Sampler.AddressMode = .repeat,
    mag_filter: wgpu.FilterMode = .nearest,
    min_filter: wgpu.FilterMode = .nearest,
    mipmap_filter: wgpu.MipmapFilterMode = .nearest,
    lod_min_clamp: f32 = 0.0,
    lod_max_clamp: f32 = 0.0,
    compare: wgpu.CompareFunction = .undefined,
    max_anisotropy: u16 = 0,
};

pub const RenderPipelineInfo = struct {
    gpuobj: ?*wgpu.RenderPipeline = null,
    pipeline_layout_handle: PipelineLayoutHandle = .{},
};

pub const ComputePipelineInfo = struct {
    gpuobj: ?*wgpu.ComputePipeline = null,
    pipeline_layout_handle: PipelineLayoutHandle = .{},
};

pub const BindGroupEntryInfo = struct {
    binding: u32 = 0,
    buffer_handle: ?BufferHandle = null,
    offset: u64 = 0,
    size: u64 = 0,
    sampler_handle: ?SamplerHandle = null,
    texture_view_handle: ?TextureViewHandle = null,
};

const max_num_bindings_per_group = 10;

pub const BindGroupInfo = struct {
    gpuobj: ?*wgpu.BindGroup = null,
    num_entries: u32 = 0,
    entries: [max_num_bindings_per_group]BindGroupEntryInfo =
        [_]BindGroupEntryInfo{.{}} ** max_num_bindings_per_group,
};

pub const BindGroupLayoutInfo = struct {
    gpuobj: ?*wgpu.BindGroupLayout = null,
    num_entries: u32 = 0,
    entries: [max_num_bindings_per_group]wgpu.BindGroupLayout.Entry =
        [_]wgpu.BindGroupLayout.Entry{.{ .binding = 0, .visibility = .{} }} ** max_num_bindings_per_group,
};

const max_num_bind_groups_per_pipeline = 4;

pub const PipelineLayoutInfo = struct {
    gpuobj: ?*wgpu.PipelineLayout = null,
    num_bind_group_layouts: u32 = 0,
    bind_group_layouts: [max_num_bind_groups_per_pipeline]BindGroupLayoutHandle =
        [_]BindGroupLayoutHandle{.{}} ** max_num_bind_groups_per_pipeline,
};

pub const BufferHandle = BufferPool.Handle;
pub const TextureHandle = TexturePool.Handle;
pub const TextureViewHandle = TextureViewPool.Handle;
pub const SamplerHandle = SamplerPool.Handle;
pub const RenderPipelineHandle = RenderPipelinePool.Handle;
pub const ComputePipelineHandle = ComputePipelinePool.Handle;
pub const BindGroupHandle = BindGroupPool.Handle;
pub const BindGroupLayoutHandle = BindGroupLayoutPool.Handle;
pub const PipelineLayoutHandle = PipelineLayoutPool.Handle;

const BufferPool = ResourcePool(BufferInfo, wgpu.Buffer);
const TexturePool = ResourcePool(TextureInfo, wgpu.Texture);
const TextureViewPool = ResourcePool(TextureViewInfo, wgpu.TextureView);
const SamplerPool = ResourcePool(SamplerInfo, wgpu.Sampler);
const RenderPipelinePool = ResourcePool(RenderPipelineInfo, wgpu.RenderPipeline);
const ComputePipelinePool = ResourcePool(ComputePipelineInfo, wgpu.ComputePipeline);
const BindGroupPool = ResourcePool(BindGroupInfo, wgpu.BindGroup);
const BindGroupLayoutPool = ResourcePool(BindGroupLayoutInfo, wgpu.BindGroupLayout);
const PipelineLayoutPool = ResourcePool(PipelineLayoutInfo, wgpu.PipelineLayout);

fn ResourcePool(comptime Info: type, comptime Resource: type) type {
    const zpool = @import("zpool");
    const Pool = zpool.Pool(16, 16, Resource, struct { info: Info });

    return struct {
        const Self = @This();

        pub const Handle = Pool.Handle;

        pool: Pool,

        fn init(allocator: std.mem.Allocator, capacity: u32) Self {
            const pool = Pool.initCapacity(allocator, capacity) catch unreachable;
            return .{ .pool = pool };
        }

        fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            _ = allocator;
            self.pool.deinit();
        }

        fn addResource(self: *Self, gctx: GraphicsContext, info: Info) Handle {
            assert(info.gpuobj != null);

            if (self.pool.addIfNotFull(.{ .info = info })) |handle| {
                return handle;
            }

            // If pool is free, attempt to remove a resource that is now invalid
            // because of dependent resources which have become invalid.
            // For example, texture view becomes invalid when parent texture
            // is destroyed.
            //
            // TODO: We could instead store a linked list in Info to track
            // dependencies.  The parent resource could "point" to the first
            // dependent resource, and each dependent resource could "point" to
            // the parent and the prev/next dependent resources of the same
            // type (perhaps using handles instead of pointers).
            // When a parent resource is destroyed, we could traverse that list
            // to destroy dependent resources, and when a dependent resource
            // is destroyed, we can remove it from the doubly-linked list.
            //
            // pub const TextureInfo = struct {
            //     ...
            //     // note generic name:
            //     first_dependent_handle: TextureViewHandle = .{}
            // };
            //
            // pub const TextureViewInfo = struct {
            //     ...
            //     // note generic names:
            //     parent_handle: TextureHandle = .{},
            //     prev_dependent_handle: TextureViewHandle,
            //     next_dependent_handle: TextureViewHandle,
            // };
            if (self.removeResourceIfInvalid(gctx)) {
                if (self.pool.addIfNotFull(.{ .info = info })) |handle| {
                    return handle;
                }
            }

            // TODO: For now we just assert if pool is full - make it more roboust.
            assert(false);
            return Handle.nil;
        }

        fn removeResourceIfInvalid(self: *Self, gctx: GraphicsContext) bool {
            var live_handles = self.pool.liveHandles();
            while (live_handles.next()) |live_handle| {
                if (!gctx.isResourceValid(live_handle)) {
                    self.destroyResource(live_handle, true);
                    return true;
                }
            }
            return false;
        }

        fn destroyResource(self: *Self, handle: Handle, comptime call_destroy: bool) void {
            if (!self.isHandleValid(handle))
                return;

            const resource_info = self.pool.getColumnPtrAssumeLive(handle, .info);
            const gpuobj = resource_info.gpuobj.?;

            if (call_destroy and (Handle == BufferHandle or Handle == TextureHandle)) {
                gpuobj.destroy();
            }
            gpuobj.release();
            resource_info.* = .{};

            self.pool.removeAssumeLive(handle);
        }

        fn isHandleValid(self: Self, handle: Handle) bool {
            return self.pool.isLiveHandle(handle);
        }

        fn getInfoPtr(self: Self, handle: Handle) *Info {
            return self.pool.getColumnPtrAssumeLive(handle, .info);
        }

        fn getInfo(self: Self, handle: Handle) Info {
            return self.pool.getColumnAssumeLive(handle, .info);
        }

        fn getGpuObj(self: Self, handle: Handle) ?*Resource {
            if (self.pool.getColumnPtrIfLive(handle, .info)) |info| {
                return info.gpuobj;
            }
            return null;
        }
    };
}

const FrameStats = struct {
    time: f64 = 0.0,
    delta_time: f32 = 0.0,
    fps_counter: u32 = 0,
    fps: f64 = 0.0,
    average_cpu_time: f64 = 0.0,
    previous_time: f64 = 0.0,
    fps_refresh_time: f64 = 0.0,
    cpu_frame_number: u64 = 0,
    gpu_frame_number: u64 = 0,

    fn tick(stats: *FrameStats) void {
        stats.time = @as(f64, @floatFromInt(sdl.SDL_GetTicks())) / 1000;
        stats.delta_time = @floatCast(stats.time - stats.previous_time);
        stats.previous_time = stats.time;

        if ((stats.time - stats.fps_refresh_time) >= 1.0) {
            const t = stats.time - stats.fps_refresh_time;
            const fps = @as(f64, @floatFromInt(stats.fps_counter)) / t;
            const ms = (1.0 / fps) * 1000.0;

            stats.fps = fps;
            stats.average_cpu_time = ms;
            stats.fps_refresh_time = stats.time;
            stats.fps_counter = 0;
        }
        stats.fps_counter += 1;
        stats.cpu_frame_number += 1;
    }
};

const SurfaceDescriptorTag = enum {
    metal_layer,
    windows_hwnd,
    xlib,
};

const SurfaceDescriptor = union(SurfaceDescriptorTag) {
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

fn createSurfaceForWindow(instance: *wgpu.Instance, window: *sdl.SDL_Window) *wgpu.Surface {
    const os_tag = @import("builtin").target.os.tag;
    const descriptor = if (os_tag == .windows) blk: {
        var info: sdl.SDL_SysWMinfo = undefined;
        if (sdl.SDL_GetWindowWMInfo(window, &info, sdl.SDL_SYSWM_CURRENT_VERSION) != 0) {
            sdl.SDL_Log("SDL_GetWindowWMInfo failed. SDL error: %s", sdl.SDL_GetError());
            @panic("SDL_GetWindowWMInfo failed");
        }
        std.debug.print("SDL_GetWindowWMInfo (remove this once tested): {}\n", .{info});

        break :blk SurfaceDescriptor{
            .windows_hwnd = .{
                .label = "basic surface",
                .hinstance = std.os.windows.kernel32.GetModuleHandleW(null) or info.info.hinstance,
                .hwnd = info.info.window,
            },
        };
    } else if (os_tag == .linux) blk: {
        var info: sdl.SDL_SysWMinfo = undefined;
        if (sdl.SDL_GetWindowWMInfo(window, &info, sdl.SDL_SYSWM_CURRENT_VERSION) != 0) {
            sdl.SDL_Log("SDL_GetWindowWMInfo failed. SDL error: %s", sdl.SDL_GetError());
            @panic("SDL_GetWindowWMInfo failed");
        }
        std.debug.print("SDL_GetWindowWMInfo (remove this once tested): {}\n", .{info});

        break :blk SurfaceDescriptor{
            .xlib = .{
                .label = "basic surface",
                .display = info.info.display, // zglfw.native.getX11Display()
                .window = info.info.window, // zglfw.native.getX11Window(window)
            },
        };
    } else if (os_tag == .macos) blk: {
        const metal_view = sdl.SDL_Metal_CreateView(window);
        const metal_layer = sdl.SDL_Metal_GetLayer(metal_view);

        break :blk SurfaceDescriptor{
            .metal_layer = .{
                .label = "basic surface",
                .layer = metal_layer.?,
            },
        };
    } else unreachable;

    return switch (descriptor) {
        .metal_layer => |src| blk: {
            var desc: wgpu.Surface.DescriptorFromMetalLayer = undefined;
            desc.chain.next = null;
            desc.chain.s_type = .surface_descriptor_from_metal_layer;
            desc.layer = src.layer;
            break :blk instance.createSurface(&.{
                .next_in_chain = .{
                    .from_metal_layer = &desc,
                },
                .label = if (src.label) |l| l else null,
            });
        },
        .windows_hwnd => |src| blk: {
            var desc: wgpu.Surface.DescriptorFromWindowsHWND = undefined;
            desc.chain.next = null;
            desc.chain.s_type = .surface_descriptor_from_windows_hwnd;
            desc.hinstance = src.hinstance;
            desc.hwnd = src.hwnd;
            break :blk instance.createSurface(&.{
                .next_in_chain = .{
                    .from_windows_hwnd = &desc,
                },
                .label = if (src.label) |l| l else null,
            });
        },
        .xlib => |src| blk: {
            var desc: wgpu.Surface.DescriptorFromXlibWindow = undefined;
            desc.chain.next = null;
            desc.chain.s_type = .surface_descriptor_from_xlib_window;
            desc.display = src.display;
            desc.window = src.window;
            break :blk instance.createSurface(&.{
                .next_in_chain = .{
                    .from_xlib_window = &desc,
                },
                .label = if (src.label) |l| l else null,
            });
        },
    };
}

fn logUnhandledError(
    err_type: wgpu.ErrorType,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque,
) callconv(.C) void {
    _ = userdata;
    switch (err_type) {
        .no_error => std.log.info("[zgpu] No error: {?s}", .{message}),
        .validation => std.log.err("[zgpu] Validation: {?s}", .{message}),
        .out_of_memory => std.log.err("[zgpu] Out of memory: {?s}", .{message}),
        .device_lost => std.log.err("[zgpu] Device lost: {?s}", .{message}),
        .internal => std.log.err("[zgpu] Internal error: {?s}", .{message}),
        .unknown => std.log.err("[zgpu] Unknown error: {?s}", .{message}),
    }

    // Exit the process for easier debugging.
    if (@import("builtin").mode == .Debug)
        std.process.exit(1);
}

fn handleToGpuResourceType(comptime T: type) type {
    return switch (T) {
        BufferHandle => wgpu.Buffer,
        TextureHandle => wgpu.Texture,
        TextureViewHandle => wgpu.TextureView,
        SamplerHandle => wgpu.Sampler,
        RenderPipelineHandle => wgpu.RenderPipeline,
        ComputePipelineHandle => wgpu.ComputePipeline,
        BindGroupHandle => wgpu.BindGroup,
        BindGroupLayoutHandle => wgpu.BindGroupLayout,
        PipelineLayoutHandle => wgpu.PipelineLayout,
        else => @compileError("[zgpu] handleToGpuResourceType() not implemented for " ++ @typeName(T)),
    };
}

fn handleToResourceInfoType(comptime T: type) type {
    return switch (T) {
        BufferHandle => BufferInfo,
        TextureHandle => TextureInfo,
        TextureViewHandle => TextureViewInfo,
        SamplerHandle => SamplerInfo,
        RenderPipelineHandle => RenderPipelineInfo,
        ComputePipelineHandle => ComputePipelineInfo,
        BindGroupHandle => BindGroupInfo,
        BindGroupLayoutHandle => BindGroupLayoutInfo,
        PipelineLayoutHandle => PipelineLayoutInfo,
        else => @compileError("[zgpu] handleToResourceInfoType() not implemented for " ++ @typeName(T)),
    };
}

fn formatToShaderFormat(format: wgpu.TextureFormat) []const u8 {
    // TODO: Add missing formats.
    return switch (format) {
        .rgba8_unorm => "rgba8unorm",
        .rgba8_snorm => "rgba8snorm",
        .rgba16_float => "rgba16float",
        .rgba32_float => "rgba32float",
        else => unreachable,
    };
}
