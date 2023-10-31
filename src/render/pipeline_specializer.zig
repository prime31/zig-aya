const std = @import("std");
const aya = @import("../aya.zig");

const World = aya.World;
const PipelineCache = aya.PipelineCache;
const InnerMeshVertexBufferLayout = aya.InnerMeshVertexBufferLayout;
const VertexBufferLayout = aya.VertexBufferLayout;

// pub trait S {
//     type Key;
//     fn specialize(&self, key: Self.Key) -> RenderPipelineDescriptor;
// }

const CachedRenderPipelineId = usize; // TODO: is this right?

/// Resource.
pub fn SpecializedRenderPipelines(comptime S: type) type {
    return struct {
        const Self = @This();

        cache: std.AutoHashMap(S.Key, CachedRenderPipelineId),

        pub fn init() Self {
            return .{ .cache = std.AutoHashMap(S.Key, CachedRenderPipelineId).init(aya.allocator) };
        }

        pub fn deinit(self: *Self) void {
            self.cache.deinit();
        }

        pub fn specialize(self: Self, cache: PipelineCache, specialize_pipeline: *S, key: S.Key) CachedRenderPipelineId {
            _ = key;
            _ = specialize_pipeline;
            _ = cache;
            _ = self;

            // *self.cache.entry(key.clone()).or_insert_with(|| {
            //     let descriptor = specialize_pipeline.specialize(key);
            //     cache.queue_render_pipeline(descriptor)
            // })
        }
    };
}

// pub trait S {
//     type Key;
//     fn specialize(&self, key: Self.Key, layout: MeshVertexBufferLayout) -> !RenderPipelineDescriptor;
// }

/// Resource.
pub fn SpecializedMeshPipelines(comptime S: type) type {
    return struct {
        const Self = @This();

        mesh_layout_cache: std.AutoHashMap(InnerMeshVertexBufferLayout, std.AutoHashMap(S.Key, CachedRenderPipelineId)),
        vertex_layout_cache: std.AutoHashMap(VertexBufferLayout, std.AutoHashMap(S.Key, CachedRenderPipelineId)),

        pub fn init() Self {
            return .{
                .mesh_layout_cache = std.AutoHashMap(InnerMeshVertexBufferLayout, std.AutoHashMap(S.Key, CachedRenderPipelineId)).init(aya.allocator),
                .vertex_layout_cache = std.AutoHashMap(VertexBufferLayout, std.AutoHashMap(S.Key, CachedRenderPipelineId)).init(aya.allocator),
            };
        }
    };
}
