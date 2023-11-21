const std = @import("std");
const wgpu = @import("wgpu");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const BufferHandle = BufferPool.Handle;
pub const TextureHandle = TexturePool.Handle;
pub const TextureViewHandle = TextureViewPool.Handle;
pub const SamplerHandle = SamplerPool.Handle;
pub const RenderPipelineHandle = RenderPipelinePool.Handle;
pub const ComputePipelineHandle = ComputePipelinePool.Handle;
pub const BindGroupHandle = BindGroupPool.Handle;
pub const BindGroupLayoutHandle = BindGroupLayoutPool.Handle;
pub const PipelineLayoutHandle = PipelineLayoutPool.Handle;

pub const ResourcePools = struct {
    buffer_pool: BufferPool,
    texture_pool: TexturePool,
    texture_view_pool: TextureViewPool,
    sampler_pool: SamplerPool,
    render_pipeline_pool: RenderPipelinePool,
    compute_pipeline_pool: ComputePipelinePool,
    bind_group_pool: BindGroupPool,
    bind_group_layout_pool: BindGroupLayoutPool,
    pipeline_layout_pool: PipelineLayoutPool,

    pub fn init(allocator: std.mem.Allocator) ResourcePools {
        return .{
            .buffer_pool = BufferPool.init(allocator, 128),
            .texture_pool = TexturePool.init(allocator, 128),
            .texture_view_pool = TextureViewPool.init(allocator, 128),
            .sampler_pool = SamplerPool.init(allocator, 16),
            .render_pipeline_pool = RenderPipelinePool.init(allocator, 128),
            .compute_pipeline_pool = ComputePipelinePool.init(allocator, 32),
            .bind_group_pool = BindGroupPool.init(allocator, 32),
            .bind_group_layout_pool = BindGroupLayoutPool.init(allocator, 32),
            .pipeline_layout_pool = PipelineLayoutPool.init(allocator, 32),
        };
    }

    pub fn deinit(self: *ResourcePools, allocator: std.mem.Allocator) void {
        self.buffer_pool.deinit(allocator);
        self.texture_pool.deinit(allocator);
        self.texture_view_pool.deinit(allocator);
        self.sampler_pool.deinit(allocator);
        self.render_pipeline_pool.deinit(allocator);
        self.compute_pipeline_pool.deinit(allocator);
        self.bind_group_pool.deinit(allocator);
        self.bind_group_layout_pool.deinit(allocator);
        self.pipeline_layout_pool.deinit(allocator);
    }
};

const BufferPool = ResourcePool(BufferInfo, wgpu.Buffer);
const TexturePool = ResourcePool(TextureInfo, wgpu.Texture);
const TextureViewPool = ResourcePool(TextureViewInfo, wgpu.TextureView);
const SamplerPool = ResourcePool(SamplerInfo, wgpu.Sampler);
const RenderPipelinePool = ResourcePool(RenderPipelineInfo, wgpu.RenderPipeline);
const ComputePipelinePool = ResourcePool(ComputePipelineInfo, wgpu.ComputePipeline);
const BindGroupPool = ResourcePool(BindGroupInfo, wgpu.BindGroup);
const BindGroupLayoutPool = ResourcePool(BindGroupLayoutInfo, wgpu.BindGroupLayout);
const PipelineLayoutPool = ResourcePool(PipelineLayoutInfo, wgpu.PipelineLayout);

pub const BufferInfo = struct {
    gpuobj: ?wgpu.Buffer = null,
    size: usize = 0,
    usage: wgpu.BufferUsage = .{},
};

pub const TextureInfo = struct {
    gpuobj: ?wgpu.Texture = null,
    usage: wgpu.TextureUsage = .{},
    dimension: wgpu.TextureDimension = .dim_1d,
    size: wgpu.Extent3D = .{},
    format: wgpu.TextureFormat = .undefined,
    mip_level_count: u32 = 0,
    sample_count: u32 = 0,
};

pub const TextureViewInfo = struct {
    gpuobj: ?wgpu.TextureView = null,
    format: wgpu.TextureFormat = .undefined,
    dimension: wgpu.TextureViewDimension = .undefined,
    base_mip_level: u32 = 0,
    mip_level_count: u32 = 0,
    base_array_layer: u32 = 0,
    array_layer_count: u32 = 0,
    aspect: wgpu.TextureAspect = .all,
    parent_texture_handle: TextureHandle = .{},
};

pub const SamplerInfo = struct {
    gpuobj: ?wgpu.Sampler = null,
    address_mode_u: wgpu.AddressMode = .repeat,
    address_mode_v: wgpu.AddressMode = .repeat,
    address_mode_w: wgpu.AddressMode = .repeat,
    mag_filter: wgpu.FilterMode = .nearest,
    min_filter: wgpu.FilterMode = .nearest,
    mipmap_filter: wgpu.MipmapFilterMode = .nearest,
    lod_min_clamp: f32 = 0.0,
    lod_max_clamp: f32 = 0.0,
    compare: wgpu.CompareFunction = .undefined,
    max_anisotropy: u16 = 0,
};

pub const RenderPipelineInfo = struct {
    gpuobj: ?wgpu.RenderPipeline = null,
};

pub const ComputePipelineInfo = struct {
    gpuobj: ?wgpu.ComputePipeline = null,
};

pub const BindGroupEntryInfo = struct {
    buffer_handle: ?BufferHandle = null,
    offset: u64 = 0,
    size: u64 = 0,
    sampler_handle: ?SamplerHandle = null,
    texture_view_handle: ?TextureViewHandle = null,
};

pub const BindGroupInfo = struct {
    pub const MAX_BINDINGS_PER_GROUP = 10;

    gpuobj: ?wgpu.BindGroup = null,
    num_entries: u32 = 0,
    entries: [MAX_BINDINGS_PER_GROUP]BindGroupEntryInfo =
        [_]BindGroupEntryInfo{.{}} ** MAX_BINDINGS_PER_GROUP,
};

pub const BindGroupLayoutInfo = struct {
    gpuobj: ?wgpu.BindGroupLayout = null,
    num_entries: u32 = 0,
    entries: [BindGroupInfo.MAX_BINDINGS_PER_GROUP]wgpu.BindGroupLayoutEntry =
        [_]wgpu.BindGroupLayoutEntry{.{ .binding = 0, .visibility = .{} }} ** BindGroupInfo.MAX_BINDINGS_PER_GROUP,
};

pub const PipelineLayoutInfo = struct {
    pub const MAX_BIND_GROUPS_PER_PIPELINE = 4;

    gpuobj: ?wgpu.PipelineLayout = null,
    num_bind_group_layouts: u32 = 0,
    bind_group_layouts: [MAX_BIND_GROUPS_PER_PIPELINE]BindGroupLayoutHandle =
        [_]BindGroupLayoutHandle{.{}} ** MAX_BIND_GROUPS_PER_PIPELINE,
};

// helpers to get Resource and Info types
pub fn HandleToGpuResourceType(comptime T: type) type {
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
        else => @compileError("[gpu] handleToGpuResourceType() not implemented for " ++ @typeName(T)),
    };
}

pub fn HandleToResourceInfoType(comptime T: type) type {
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
        else => @compileError("[gpu] handleToResourceInfoType() not implemented for " ++ @typeName(T)),
    };
}

fn ResourcePool(comptime Info: type, comptime Resource: type) type {
    const zpool = @import("zpool");
    const Pool = zpool.Pool(16, 16, Resource, struct { info: Info });

    return struct {
        const Self = @This();

        pub const Handle = Pool.Handle;

        pool: Pool,

        pub fn init(allocator: std.mem.Allocator, capacity: u32) Self {
            const pool = Pool.initCapacity(allocator, capacity) catch unreachable;
            return .{ .pool = pool };
        }

        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            _ = allocator;
            self.pool.deinit();
        }

        pub fn addResource(self: *Self, gctx: GraphicsContext, info: Info) Handle {
            std.debug.assert(info.gpuobj != null);

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
            std.debug.assert(false);
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

        pub fn destroyResource(self: *Self, handle: Handle, comptime call_destroy: bool) void {
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

        pub fn isHandleValid(self: Self, handle: Handle) bool {
            return self.pool.isLiveHandle(handle);
        }

        pub fn getInfoPtr(self: Self, handle: Handle) *Info {
            return self.pool.getColumnPtrAssumeLive(handle, .info);
        }

        pub fn getInfo(self: Self, handle: Handle) Info {
            return self.pool.getColumnAssumeLive(handle, .info);
        }

        pub fn getGpuObj(self: Self, handle: Handle) ?Resource {
            if (self.pool.getColumnPtrIfLive(handle, .info)) |info| {
                return info.gpuobj;
            }
            return null;
        }
    };
}
