const std = @import("std");
const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const Handle = aya.Handle;
const MeshPipeline = aya.MeshPipeline;
const SpecializedMeshPipelines = aya.SpecializedMeshPipelines;
const Shader = aya.Shader;
const RenderPipelineDescriptor = aya.RenderPipelineDescriptor;
const MeshVertexBufferLayout = aya.InnerMeshVertexBufferLayout;
const MeshPipelineKey = aya.MeshPipelineKey;
const AlphaMode = aya.AlphaMode;
const AssetId = aya.AssetId;
const ResMut = aya.ResMut;
const Res = aya.Res;
const Local = aya.Local;
const OwnedBindingResource = aya.OwnedBindingResource;
const RenderAssets = aya.RenderAssets;
const Image = aya.Image;
const PreparedBindGroup = aya.PreparedBindGroup;

///  Materials must implement [`AsBindGroup`] to define how data will be transferred to the GPU and bound in shaders
pub fn Material(comptime M: type) type {
    return struct {
        const Self = @This();

        pub const MaterialType = M;
        pub const Data = M.Data;

        pub fn vertexShader() aya.ShaderRef {
            if (@hasDecl(M, "vertexShader")) return M.vertexShader();
            return .default;
        }

        pub fn fragmentShader() aya.ShaderRef {
            if (@hasDecl(M, "fragmentShader")) return M.fragmentShader();
            return .default;
        }

        pub fn alphaMode(material: *const M) AlphaMode {
            if (@hasDecl(M, "alphaMode")) return material.alphaMode();
            return AlphaMode.opaque_;
        }

        pub fn depthBias(material: *const M) f32 {
            if (@hasDecl(M, "depthBias")) return material.depthBias();
            return 0;
        }

        pub fn prepassVertexShader() aya.ShaderRef {
            if (@hasDecl(M, "prepassVertexShader")) return M.prepassVertexShader();
            return .default;
        }

        pub fn prepassFragmentShader() aya.ShaderRef {
            if (@hasDecl(M, "prepassFragmentShader")) return M.prepassFragmentShader();
            return .default;
        }

        pub fn asBindGroup(
            material: *const M,
            layout: zgpu.BindGroupLayoutHandle,
            gctx: *zgpu.GraphicsContext,
            images: *const RenderAssets(Image),
        ) !PreparedBindGroup(Data) {
            if (@hasDecl(M, "asBindGroup")) return material.asBindGroup(layout, gctx, images);

            const bind_group = gctx.createBindGroup(layout, &.{
                .{ .binding = 0, .buffer_handle = gctx.uniforms.buffer, .offset = 0, .size = 256 },
                // .{ .binding = 1, .texture_view_handle = texture_view },
                // .{ .binding = 2, .sampler_handle = sampler },
            });

            // let UnpreparedBindGroup { bindings, data } =
            //     Self::unprepared_bind_group(self, layout, render_device, images, fallback_image)?;

            // let entries = bindings
            //     .iter()
            //     .map(|(index, binding)| BindGroupEntry {
            //         binding: *index,
            //         resource: binding.get_binding(),
            //     })
            //     .collect::<Vec<_>>();

            // let bind_group = render_device.create_bind_group(Self::label(), layout, &entries);

            var prepared_bind_group = PreparedBindGroup(Data).init();
            prepared_bind_group.bind_group = bind_group;
            return prepared_bind_group;
        }

        // let bindings = vec![#(#binding_impls,)*];

        // Ok(#render_path::render_resource::UnpreparedBindGroup {
        //     bindings,
        //     data: #get_prepared_data,
        // })

        pub fn specialize(
            _: MaterialPipeline(M),
            _: *RenderPipelineDescriptor,
            _: *MeshVertexBufferLayout,
            _: MaterialPipelineKey(M),
        ) !void {}
    };
}

/// A key uniquely identifying a specialized [`MaterialPipeline`].
pub fn MaterialPipelineKey(comptime M: type) type {
    return struct {
        mesh_key: MeshPipelineKey,
        bind_group_data: M.Data, // TODO: M.Data is a type created by AsBindGroup
    };
}

/// Resource. Render pipeline data for a given [`Material`].
pub fn MaterialPipeline(comptime M: type) type {
    return struct {
        const Self = @This();
        pub const Key = MaterialPipelineKey(M);

        mesh_pipeline: MeshPipeline,
        material_layout: zgpu.BindGroupLayoutHandle,
        vertex_shader: ?Handle(Shader),
        fragment_shader: ?Handle(Shader),

        pub fn init(world: *aya.World) Self {
            const asset_server: *aya.AssetServer = world.getResourceMut(aya.AssetServer).?;
            const gctx = world.getResourceMut(zgpu.GraphicsContext).?;

            return .{
                .mesh_pipeline = world.getResourceMut(aya.MeshPipeline).?.*,
                .material_layout = gctx.createBindGroupLayout(&.{
                    zgpu.bufferEntry(0, .{ .vertex = true, .fragment = true }, .uniform, .true, 0), // TODO: wtf, move to Material
                }),
                .vertex_shader = Material(M).vertexShader().getHandle(asset_server),
                .fragment_shader = Material(M).fragmentShader().getHandle(asset_server),
            };
        }

        pub fn specialize(self: Self, key: Key, layout: *MeshVertexBufferLayout) !RenderPipelineDescriptor {
            var descriptor = self.mesh_pipeline.specialize(key.mesh_key, layout) catch unreachable;

            if (self.vertex_shader) |vert_shader| descriptor.vertex.shader = vert_shader;
            if (self.fragment_shader) |frag_shader| descriptor.fragment.shader = frag_shader;

            descriptor.layout.insert(1, self.material_layout);
            M.specialize(self, &descriptor, layout, key);

            if (true) @panic("we fucking made it");

            return descriptor;
        }
    };
}

fn ExtractedMaterialEntry(comptime M: type) type {
    return struct { id: AssetId(M), material: M };
}

pub fn ExtractedMaterials(comptime M: type) type {
    return struct {
        const Self = @This();

        extracted: std.ArrayList(ExtractedMaterialEntry(M)),
        removed: std.ArrayList(AssetId(M)),

        pub fn init() Self {
            return .{
                .extracted = std.ArrayList(ExtractedMaterialEntry(M)).init(aya.allocator),
                .removed = std.ArrayList(AssetId(M)).init(aya.allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.extracted.deinit();
            self.removed.deinit();
        }

        pub fn clear(self: *Self) void {
            self.extracted.clearRetainingCapacity();
            self.removed.clearRetainingCapacity();
        }
    };
}

/// Adds the necessary ECS resources and render logic to enable rendering entities using the given [`Material`]
/// asset type.
pub fn MaterialPlugin(comptime M: type) type {
    return struct {
        const Self = @This();

        prepass_enabled: bool = true,

        pub fn build(_: Self, app: *aya.App) void {
            _ = app
                .initAsset(M)
                .initResource(ExtractedMaterials(M))
                .initResource(RenderMaterials(M))
                .initResource(MaterialPipeline(M))
                .initResource(SpecializedMeshPipelines(MaterialPipeline(M)))
                .addSystems(aya.PostUpdate, .{ ExtractMaterialsSystem(M), PrepareMaterialsSystem(M) });
        }
    };
}

/// Resource
pub fn PrepareNextFrameMaterials(comptime M: type) type {
    return struct {
        const Self = @This();

        assets: std.ArrayList(ExtractedMaterialEntry(M)),

        pub fn init() Self {
            return .{
                .assets = std.ArrayList(ExtractedMaterialEntry(M)).init(aya.allocator),
            };
        }

        pub fn deinit(self: Self) void {
            self.assets.deinit();
        }

        pub fn clear(self: *Self) void {
            self.assets.clearRetainingCapacity();
        }
    };
}

/// Common [`Material`] properties, calculated for a specific material instance.
pub const MaterialProperties = struct {
    /// Is this material should be rendered by the deferred renderer when AlphaMode::Opaque or AlphaMode::Mask
    // render_method: OpaqueRendererMethod,
    /// The [`AlphaMode`] of this material.
    alpha_mode: AlphaMode,
    /// Add a bias to the view depth of the mesh which can be used to force a specific render order
    /// for meshes with equal depth, to avoid z-fighting.
    /// The bias is in depth-texture units so large values may be needed to overcome small depth differences.
    depth_bias: f32,
};

pub fn PreparedMaterial(comptime M: type) type {
    return struct {
        const Self = @This();

        bindings: std.ArrayList(aya.Bindings),
        bind_group: zgpu.BindGroupHandle,
        key: M.Data,
        properties: MaterialProperties,

        pub fn init() Self {
            return .{
                .bindings = std.ArrayList(aya.Bindings).init(aya.allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.bindings.deinit();
        }
    };
}

/// Resource
pub fn RenderMaterials(comptime M: type) type {
    return struct {
        const Self = @This();

        materials: std.AutoHashMap(AssetId(M), PreparedMaterial(M)),

        pub fn init() Self {
            return .{
                .materials = std.AutoHashMap(AssetId(M), PreparedMaterial(M)).init(aya.allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            var iter = self.materials.valueIterator();
            while (iter.next()) |prepared_material| prepared_material.deinit();

            self.materials.deinit();
        }

        pub fn insert(self: *Self, id: AssetId(M), asset: PreparedMaterial(M)) void {
            self.materials.put(id, asset) catch unreachable;
        }

        pub fn get(self: *Self, id: AssetId(M)) ?PreparedMaterial(M) {
            return self.materials.get(id);
        }

        pub fn remove(self: *Self, id: AssetId(M)) void {
            _ = self.materials.remove(id);
        }
    };
}

pub fn ExtractMaterialsSystem(comptime M: type) type {
    return struct {
        pub const name = "aya.systems.assets.ExtractMaterialsSystem_" ++ aya.utils.typeNameLastComponent(M);

        pub fn run(
            extracted_materials_res: ResMut(ExtractedMaterials(M)),
            event_reader: aya.EventReader(aya.AssetEvent(M)),
            assets_res: Res(aya.Assets(M)),
        ) void {
            const extracted_materials = extracted_materials_res.getAssertExists();
            const asset: *const aya.Assets(M) = assets_res.getAssertExists();

            // TODO: use a HashSet to ensure we dont queue up multiple evnets if an asset is added and removed in one frame for example
            for (event_reader.read()) |evt| {
                switch (evt) {
                    .added, .modified => |mod| {
                        if (asset.get(mod.index)) |ass| {
                            extracted_materials.extracted.append(.{ .id = mod, .material = ass }) catch unreachable;
                        }
                    },
                    .removed => |rem| extracted_materials.removed.append(rem) catch unreachable,
                }
            }
        }
    };
}

pub fn PrepareMaterialsSystem(comptime M: type) type {
    return struct {
        pub const name = "aya.systems.assets.PrepareMaterialsSystem_" ++ aya.utils.typeNameLastComponent(M);

        pub fn run(
            world: *aya.World,
            extracted_materials_res: ResMut(ExtractedMaterials(M)),
            prepare_next_frame_local: Local(PrepareNextFrameMaterials(M)),
            render_materials_res: ResMut(RenderMaterials(M)),
            images_res: Res(RenderAssets(Image)),
            gctx_res: ResMut(zgpu.GraphicsContext),
            pipeline_res: Res(MaterialPipeline(M)),
        ) void {
            _ = world;
            const extracted_materials = extracted_materials_res.getAssertExists();
            const prepare_next_frame = prepare_next_frame_local.get();
            const render_materials = render_materials_res.getAssertExists();
            const images = images_res.getAssertExists();
            const gctx = gctx_res.getAssertExists();
            const pipeline = pipeline_res.getAssertExists();

            // process all PrepareNextFrameAssets
            const next_frame = prepare_next_frame.assets.toOwnedSlice() catch unreachable;
            defer aya.mem.free(next_frame);

            for (next_frame) |obj| {
                const prepared_material = prepareMaterial(M, &obj.material, gctx, images, pipeline) catch {
                    prepare_next_frame.assets.append(obj) catch unreachable;
                    continue;
                };
                render_materials.insert(obj.id, prepared_material);
            }

            for (extracted_materials.removed.items) |rem| {
                render_materials.remove(rem);
            }

            // process all ExtractedAssets
            for (extracted_materials.extracted.items) |obj| {
                const prepared_material = prepareMaterial(M, &obj.material, gctx, images, pipeline) catch {
                    prepare_next_frame.assets.append(obj) catch unreachable;
                    continue;
                };
                render_materials.insert(obj.id, prepared_material);
            }

            extracted_materials.clear();
        }
    };
}

fn prepareMaterial(
    comptime M: type,
    material: *const M,
    gctx: *zgpu.GraphicsContext,
    images: *const RenderAssets(Image),
    pipeline: *const MaterialPipeline(M),
) !PreparedMaterial(M) {
    const prepared: PreparedBindGroup(M.Data) = try Material(M).asBindGroup(material, pipeline.material_layout, gctx, images);
    std.debug.print("------ prepareMaterial working so far. data: {}\n", .{prepared.data});

    return PreparedMaterial(M){
        .bindings = prepared.bindings,
        .bind_group = prepared.bind_group,
        .key = prepared.data,
        .properties = MaterialProperties{
            .alpha_mode = Material(M).alphaMode(material),
            .depth_bias = Material(M).depthBias(material),
        },
    };
}
