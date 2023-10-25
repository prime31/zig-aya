const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const RenderPipelineDescriptor = aya.RenderPipelineDescriptor;

pub const PipelineCache = struct {
    gctx: *zgpu.GraphicsContext,
    // layout_cache: LayoutCache,
    // shader_cache: ShaderCache,
    // device: RenderDevice,
    // pipelines: Vec<CachedPipeline>,
    // waiting_pipelines: HashSet<CachedPipelineId>,
    // new_pipelines: Mutex<Vec<CachedPipeline>>,

    pub fn init(world: *aya.World) PipelineCache {
        return .{
            .gctx = world.getResourceMut(zgpu.GraphicsContext).?,
        };
    }

    pub fn queueRenderPipeline(self: *PipelineCache, descriptor: RenderPipelineDescriptor) zgpu.RenderPipelineHandle {
        return self.processRenderPipeline(descriptor);
    }

    pub fn processRenderPipeline(self: *PipelineCache, descriptor: RenderPipelineDescriptor) zgpu.RenderPipelineHandle {
        _ = descriptor;
        _ = self;

        // return self.gctx.createRenderPipeline(pipeline_layout: PipelineLayoutHandle, descriptor: wgpu.RenderPipelineDescriptor);
        return .{};
    }
};

//.add_systems(ExtractSchedule, PipelineCache::extract_shaders)
const ExtractShaders = struct {
    pub fn run(
        cache: aya.ResMut(PipelineCache),
        shaders: aya.Res(aya.Assets(aya.Shader)),
        events: aya.EventReader(aya.AssetEvent(aya.Shader)),
    ) void {
        _ = events;
        _ = shaders;
        _ = cache;
        // for event in events.read() {
        //     match event {
        //         AssetEvent::Added { id } | AssetEvent::Modified { id } => {
        //             if let Some(shader) = shaders.get(*id) {
        //                 cache.set_shader(*id, shader);
        //             }
        //         }
        //         AssetEvent::Removed { id } => cache.remove_shader(*id),
        //         AssetEvent::LoadedWithDependencies { .. } => {
        //             // TODO: handle this
        //         }
        //     }
        // }
    }
};
