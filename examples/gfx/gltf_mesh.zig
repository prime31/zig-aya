const std = @import("std");
const aya = @import("aya");
const zmesh = aya.zmesh;
const zm = aya.zm;
const wgpu = aya.wgpu;

// https://www.slideshare.net/Khronos_Group/gltf-20-reference-guide
// https://toji.dev/webgpu-gltf-case-study/#track-your-render-data-carefully
const cgltf = zmesh.io.zcgltf;

pub const GltfVertex = struct {
    position: [3]f32,
    normal: [3]f32,
    texcoords0: [2]f32,
    // tangent: [4]f32, // temporarily removed
};

pub const GltfRoot = struct {
    meshes: []GltfMeshRoot,
    textures: []GltfTexture,

    pub fn deinit(self: *GltfRoot) void {
        for (self.meshes) |*m| m.deinit();
        aya.mem.free(self.textures);
        aya.mem.free(self.meshes);
    }
};

/// each GltfMeshRoot can contain multiple submeshes ("primitives" in GLTF terminology)
pub const GltfMeshRoot = struct {
    meshes: []GltfMesh,

    pub fn deinit(self: *GltfMeshRoot) void {
        aya.mem.free(self.meshes);
    }
};

/// buffer details required for drawing the mesh with drawIndexed. Maps to a GLTF Primitive
pub const GltfMesh = struct {
    vertex_offset: u32,
    index_offset: u32,
    num_indices: u32,
    material: ?GltfMaterial,
};

/// maps the textures a mesh uses to the GltfRoot.textures index
pub const GltfMaterial = struct {
    // pbr_metallic_roughness
    base_color: ?usize = null,
    metallic_roughness: ?usize = null,

    // pbr_specular_glossiness
    diffuse: ?usize = null,
    specular_glossiness: ?usize = null,

    normal: ?usize = null,
    emissive: ?usize = null,
    occlusion: ?usize = null,
};

pub const GltfTexture = struct {
    texture: aya.render.TextureHandle,
    texture_view: aya.render.TextureViewHandle,
};

const MeshCache = struct {
    arena_allocator: std.heap.ArenaAllocator,
    all_meshes: std.ArrayList(GltfMesh),
    all_vertices: std.ArrayList(GltfVertex),
    all_indices: std.ArrayList(u32),

    indices: std.ArrayList(u32),
    positions: std.ArrayList([3]f32),
    normals: std.ArrayList([3]f32),
    texcoords0: std.ArrayList([2]f32),
    tangents: ?std.ArrayList([4]f32) = null,
    colors: ?std.ArrayList([4]f32) = null,

    pub fn init() MeshCache {
        const arena_allocator = std.heap.ArenaAllocator.init(aya.mem.allocator); // TODO: why do we crash using this?

        return .{
            .arena_allocator = arena_allocator,
            .all_meshes = std.ArrayList(GltfMesh).init(aya.mem.allocator), // allocated without the Arena!
            .all_vertices = std.ArrayList(GltfVertex).init(aya.mem.allocator),
            .all_indices = std.ArrayList(u32).init(aya.mem.allocator),
            .indices = std.ArrayList(u32).init(aya.mem.allocator),
            .positions = std.ArrayList([3]f32).init(aya.mem.allocator),
            .normals = std.ArrayList([3]f32).init(aya.mem.allocator),
            .texcoords0 = std.ArrayList([2]f32).init(aya.mem.allocator),
        };
    }

    pub fn deinit(self: *const MeshCache) void {
        self.all_meshes.deinit();
        self.arena_allocator.deinit();

        self.all_vertices.deinit();
        self.all_indices.deinit();

        self.indices.deinit();
        self.positions.deinit();
        self.normals.deinit();
        self.texcoords0.deinit();
        if (self.tangents) |t| t.deinit();
        if (self.colors) |c| c.deinit();
    }

    pub fn resetState(self: *MeshCache) void {
        self.indices.clearRetainingCapacity();
        self.positions.clearRetainingCapacity();
        self.normals.clearRetainingCapacity();
        self.texcoords0.clearRetainingCapacity();
        if (self.tangents) |*t| t.clearRetainingCapacity();
        if (self.colors) |*c| c.clearRetainingCapacity();
    }
};

/// manages packing multiple GLTF scenes into a single vertex/index buffer. Loads all associated
/// textures as well.
pub const GltfLoader = struct {
    mesh_cache: MeshCache,
    gltfs: aya.utils.Vec(GltfRoot),

    pub fn init() GltfLoader {
        return .{
            .mesh_cache = MeshCache.init(),
            .gltfs = aya.utils.Vec(GltfRoot).init(),
        };
    }

    pub fn deinit(self: *GltfLoader) void {
        self.mesh_cache.deinit();
        for (self.gltfs.slice()) |*g| g.deinit();
        self.gltfs.deinit();
    }

    pub fn appendGltf(self: *GltfLoader, path: [:0]const u8) void {
        var gltf = GltfData.init(path);
        defer gltf.deinit();

        gltf.logCounts();

        var textures = aya.mem.alloc(GltfTexture, gltf.textures.len);
        for (gltf.textures, 0..) |tex, i| {
            textures[i] = loadTexture(tex);
        }

        var mesh_root = aya.mem.alloc(GltfMeshRoot, gltf.meshes.len);
        for (0..gltf.meshes.len) |i| {
            mesh_root[i] = gltf.loadMesh(&self.mesh_cache, &gltf.meshes[i]);
        }
        self.gltfs.append(.{ .meshes = mesh_root, .textures = textures });

        // TODO: delete all this
        std.debug.print("loaded {} meshes\n", .{mesh_root.len});
        for (mesh_root) |mesh| {
            std.debug.print("    primitives: {}\n", .{mesh.meshes.len});
        }
    }

    pub fn generateBuffers(self: *const GltfLoader) struct { aya.render.BufferHandle, aya.render.BufferHandle } {
        return .{
            aya.gctx.createBufferInit(null, .{ .copy_dst = true, .vertex = true }, GltfVertex, self.mesh_cache.all_vertices.items),
            aya.gctx.createBufferInit(null, .{ .copy_dst = true, .index = true }, u32, self.mesh_cache.all_indices.items),
        };
    }
};

/// simplified representation of the cgltf.Data struct
pub const GltfData = struct {
    gltf: *cgltf.Data,
    meshes: []cgltf.Mesh,
    materials: []cgltf.Material,
    accessors: []cgltf.Accessor,
    buffer_views: []cgltf.BufferView,
    buffers: []cgltf.Buffer,
    images: []cgltf.Image,
    textures: []cgltf.Texture,
    samplers: []cgltf.Sampler,
    nodes: []cgltf.Node,
    scenes: []cgltf.Scene,
    scene: ?*cgltf.Scene,

    pub fn init(path: [:0]const u8) GltfData {
        const data = cgltf.parseFile(.{}, path) catch unreachable;
        errdefer cgltf.free(data);

        cgltf.loadBuffers(.{}, data, path) catch unreachable;

        return .{
            .gltf = data,
            .meshes = if (data.meshes) |m| m[0..data.meshes_count] else &.{},
            .materials = if (data.materials) |m| m[0..data.materials_count] else &.{},
            .accessors = if (data.accessors) |a| a[0..data.accessors_count] else &.{},
            .buffer_views = if (data.buffer_views) |bv| bv[0..data.buffer_views_count] else &.{},
            .buffers = if (data.buffers) |b| b[0..data.buffers_count] else &.{},
            .images = if (data.images) |img| img[0..data.images_count] else &.{},
            .textures = if (data.textures) |tex| tex[0..data.textures_count] else &.{},
            .samplers = if (data.samplers) |s| s[0..data.samplers_count] else &.{},
            .nodes = if (data.nodes) |node| node[0..data.nodes_count] else &.{},
            .scenes = if (data.scenes) |scene| scene[0..data.scenes_count] else &.{},
            .scene = data.scene,
        };
    }

    pub fn deinit(self: *const GltfData) void {
        zmesh.io.freeData(self.gltf);
    }

    pub fn logCounts(self: GltfData) void {
        std.debug.print("meshes: {}\n", .{self.meshes.len});
        std.debug.print("materials: {}\n", .{self.materials.len});
        std.debug.print("accessors: {}\n", .{self.accessors.len});
        std.debug.print("buffers: {}\n", .{self.buffers.len});
        std.debug.print("images: {}\n", .{self.images.len});
        std.debug.print("textures: {}\n\n", .{self.textures.len});
    }

    /// loads the mesh at `index` and all its Primitives
    fn loadMesh(self: *const GltfData, mesh_cache: *MeshCache, mesh: *cgltf.Mesh) GltfMeshRoot {
        var mesh_root = GltfMeshRoot{ .meshes = aya.mem.alloc(GltfMesh, mesh.primitives_count) };

        for (mesh.primitives[0..mesh.primitives_count], 0..) |*primitive, i| {
            const pre_indices_len = mesh_cache.all_indices.items.len;
            const pre_positions_len = mesh_cache.all_vertices.items.len;

            appendMeshPrimitive(primitive, mesh_cache);

            mesh_root.meshes[i].index_offset = @as(u32, @intCast(pre_indices_len));
            mesh_root.meshes[i].num_indices = @as(u32, @intCast(mesh_cache.indices.items.len));
            mesh_root.meshes[i].vertex_offset = @as(u32, @intCast(pre_positions_len));
            mesh_root.meshes[i].material = self.loadMaterial(primitive);

            mesh_cache.all_indices.ensureTotalCapacity(mesh_cache.all_indices.items.len + mesh_cache.indices.items.len) catch unreachable;
            for (mesh_cache.indices.items) |mesh_index| {
                mesh_cache.all_indices.appendAssumeCapacity(mesh_index);
            }

            mesh_cache.all_vertices.ensureTotalCapacity(mesh_cache.all_vertices.items.len + mesh_cache.positions.items.len) catch unreachable;
            for (mesh_cache.positions.items, 0..) |_, j| {
                mesh_cache.all_vertices.appendAssumeCapacity(.{
                    .position = mesh_cache.positions.items[j],
                    .normal = mesh_cache.normals.items[j],
                    .texcoords0 = mesh_cache.texcoords0.items[j],
                });
            }

            mesh_cache.resetState();
        }

        return mesh_root;
    }

    fn loadMaterial(self: *const GltfData, primitive: *cgltf.Primitive) ?GltfMaterial {
        const mat = primitive.material orelse return null;
        var material = GltfMaterial{};

        const getTextureIndex = struct {
            pub fn getTextureIndex(data: *const GltfData, tv: cgltf.TextureView) ?usize {
                const texture = tv.texture orelse return null;

                std.debug.assert(tv.has_transform == 0);
                std.debug.assert(tv.texcoord == 0);
                std.debug.assert(tv.scale == 1);

                for (data.textures, 0..) |*t, i| {
                    if (t == texture) return i;
                }
                return null;
            }
        }.getTextureIndex;

        if (mat.has_pbr_metallic_roughness > 0) {
            material.base_color = getTextureIndex(self, mat.pbr_metallic_roughness.base_color_texture);
            material.metallic_roughness = getTextureIndex(self, mat.pbr_metallic_roughness.metallic_roughness_texture);
        }

        if (mat.has_pbr_specular_glossiness > 0) {
            material.diffuse = getTextureIndex(self, mat.pbr_specular_glossiness.diffuse_texture);
            material.specular_glossiness = getTextureIndex(self, mat.pbr_specular_glossiness.specular_glossiness_texture);
        }
        material.normal = getTextureIndex(self, mat.normal_texture);
        material.emissive = getTextureIndex(self, mat.emissive_texture);
        material.occlusion = getTextureIndex(self, mat.occlusion_texture);

        return material;
    }
};

fn loadTexture(gltf_texture: zmesh.io.zcgltf.Texture) GltfTexture {
    const image = gltf_texture.image orelse unreachable;
    const buffer_view = image.buffer_view orelse unreachable;
    const data = buffer_view.buffer.data orelse unreachable;

    var x: c_int = undefined;
    var y: c_int = undefined;
    const buffer_bytes = @as([*]const u8, @ptrCast(data))[buffer_view.offset .. buffer_view.offset + buffer_view.size];
    const stb_image = aya.stb.stbi_load_from_memory(buffer_bytes.ptr, @intCast(buffer_bytes.len), &x, &y, null, 4);
    defer aya.stb.stbi_image_free(stb_image);

    const texture = aya.gctx.createTexture(@intCast(x), @intCast(y), .rgba8_unorm);
    const image_data = stb_image[0..@as(usize, @intCast(x * y * 4))];
    aya.gctx.writeTexture(texture, u8, image_data);

    return .{
        .texture = texture,
        .texture_view = aya.gctx.createTextureView(texture, &.{}),
    };
}

fn appendMeshPrimitive(prim: *cgltf.Primitive, mesh_cache: *MeshCache) void {
    const num_vertices: u32 = @as(u32, @intCast(prim.attributes[0].data.count));
    const num_indices: u32 = @as(u32, @intCast(prim.indices.?.count));

    // Indices.
    {
        mesh_cache.indices.ensureTotalCapacity(mesh_cache.indices.items.len + num_indices) catch unreachable;

        const accessor = prim.indices.?;
        const buffer_view = accessor.buffer_view.?;

        std.debug.assert(accessor.stride == buffer_view.stride or buffer_view.stride == 0);
        std.debug.assert(accessor.stride * accessor.count == buffer_view.size);
        std.debug.assert(buffer_view.buffer.data != null);

        const data_addr = @as([*]const u8, @ptrCast(buffer_view.buffer.data)) +
            accessor.offset + buffer_view.offset;

        if (accessor.stride == 1) {
            std.debug.assert(accessor.component_type == .r_8u);
            const src = @as([*]const u8, @ptrCast(data_addr));
            var i: u32 = 0;
            while (i < num_indices) : (i += 1) {
                mesh_cache.indices.appendAssumeCapacity(src[i]);
            }
        } else if (accessor.stride == 2) {
            std.debug.assert(accessor.component_type == .r_16u);
            const src = @as([*]const u16, @ptrCast(@alignCast(data_addr)));
            var i: u32 = 0;
            while (i < num_indices) : (i += 1) {
                mesh_cache.indices.appendAssumeCapacity(src[i]);
            }
        } else if (accessor.stride == 4) {
            std.debug.assert(accessor.component_type == .r_32u);
            const src = @as([*]const u32, @ptrCast(@alignCast(data_addr)));
            var i: u32 = 0;
            while (i < num_indices) : (i += 1) {
                mesh_cache.indices.appendAssumeCapacity(src[i]);
            }
        } else {
            unreachable;
        }
    }

    // Attributes.
    {
        const attributes = prim.attributes[0..prim.attributes_count];
        for (attributes) |attrib| {
            const accessor = attrib.data;
            std.debug.assert(accessor.component_type == .r_32f);

            const buffer_view = accessor.buffer_view.?;
            std.debug.assert(buffer_view.buffer.data != null);

            std.debug.assert(accessor.stride == buffer_view.stride or buffer_view.stride == 0);
            std.debug.assert(accessor.stride * accessor.count == buffer_view.size);

            const data_addr = @as([*]const u8, @ptrCast(buffer_view.buffer.data)) +
                accessor.offset + buffer_view.offset;

            if (attrib.type == .position) {
                std.debug.assert(accessor.type == .vec3);
                const slice = @as([*]const [3]f32, @ptrCast(@alignCast(data_addr)))[0..num_vertices];
                mesh_cache.positions.appendSlice(slice) catch unreachable;
            } else if (attrib.type == .color) {
                if (mesh_cache.colors) |*col| {
                    std.debug.assert(accessor.type == .vec4);
                    const slice = @as([*]const [4]f32, @ptrCast(@alignCast(data_addr)))[0..num_vertices];
                    col.appendSlice(slice) catch unreachable;
                }
            } else if (attrib.type == .normal) {
                std.debug.assert(accessor.type == .vec3);
                const slice = @as([*]const [3]f32, @ptrCast(@alignCast(data_addr)))[0..num_vertices];
                mesh_cache.normals.appendSlice(slice) catch unreachable;
            } else if (attrib.type == .texcoord) {
                std.debug.assert(accessor.type == .vec2);
                const slice = @as([*]const [2]f32, @ptrCast(@alignCast(data_addr)))[0..num_vertices];
                mesh_cache.texcoords0.appendSlice(slice) catch unreachable;
            } else if (attrib.type == .tangent) {
                if (mesh_cache.tangents) |*t| {
                    std.debug.assert(accessor.type == .vec4);
                    const slice = @as([*]const [4]f32, @ptrCast(@alignCast(data_addr)))[0..num_vertices];
                    t.appendSlice(slice) catch unreachable;
                }
            }
        }
    }
}
