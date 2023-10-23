const std = @import("std");
const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const Assets = aya.Assets;
const Shader = aya.Shader;
const Handle = aya.Handle;

const GpuImage = aya.GpuImage;
const Mesh = aya.Mesh;
const MeshLayouts = aya.MeshLayouts;
const MeshVertexBufferLayout = aya.InnerMeshVertexBufferLayout;
const RenderPipelineDescriptor = aya.RenderPipelineDescriptor;
const VertexAttributeDescriptor = aya.VertexAttributeDescriptor;

pub var MESH_SHADER_HANDLE: Handle(Shader) = undefined;

pub const MeshRenderPlugin = struct {
    pub fn build(_: MeshRenderPlugin, app: *aya.App) void {
        // load internal shaders
        const assets = app.world.getResourceMut(Assets(Shader)).?;
        MESH_SHADER_HANDLE = assets.add(Shader.fromWgsl(@embedFile("mesh.wgsl"), "mesh.wgsl"));

        _ = app.initResource(MeshPipeline);
    }
};

pub const MeshPipeline = struct {
    const Key = MeshPipelineKey;

    view_layouts: zgpu.BindGroupLayoutHandle = .{},
    view_layout_multisampled: zgpu.BindGroupLayoutHandle = .{},
    // This dummy white texture is to be used in place of optional StandardMaterial textures
    dummy_white_gpu_image: ?GpuImage = null,
    clustered_forward_buffer_binding_type: wgpu.BufferBindingType = .storage,
    mesh_layouts: MeshLayouts,
    /// `MeshUniform`s are stored in arrays in buffers. If storage buffers are available, they
    /// are used and this will be `None`, otherwise uniform buffers will be used with batches
    /// of this many `MeshUniform`s, stored at dynamic offsets within the uniform buffer.
    /// Use code like this in custom shaders:
    /// ```wgsl
    /// ##ifdef PER_OBJECT_BUFFER_BATCH_SIZE
    /// @group(2) @binding(0) var<uniform> mesh: array<Mesh, #{PER_OBJECT_BUFFER_BATCH_SIZE}u>;
    /// ##else
    /// @group(2) @binding(0) var<storage> mesh: array<Mesh>;
    /// ##endif // PER_OBJECT_BUFFER_BATCH_SIZE
    /// ```
    // per_object_buffer_batch_size: ?u32 = null,

    pub fn init() MeshPipeline {
        return .{
            .mesh_layouts = MeshLayouts{},
        };
    }

    pub fn specialize(self: MeshPipeline, key: Key, layout: *MeshVertexBufferLayout) !RenderPipelineDescriptor {
        // TODO: setup shader defines
        var vertex_attributes = std.ArrayList(VertexAttributeDescriptor).init(aya.allocator);

        if (layout.contains(Mesh.ATTRIBUTE_POSITION))
            vertex_attributes.append(Mesh.ATTRIBUTE_POSITION.atShaderLocation(0)) catch unreachable;
        if (layout.contains(Mesh.ATTRIBUTE_NORMAL))
            vertex_attributes.append(Mesh.ATTRIBUTE_NORMAL.atShaderLocation(1)) catch unreachable;
        if (layout.contains(Mesh.ATTRIBUTE_UV_0))
            vertex_attributes.append(Mesh.ATTRIBUTE_UV_0.atShaderLocation(2)) catch unreachable;
        if (layout.contains(Mesh.ATTRIBUTE_UV_1))
            vertex_attributes.append(Mesh.ATTRIBUTE_UV_1.atShaderLocation(3)) catch unreachable;
        if (layout.contains(Mesh.ATTRIBUTE_TANGENT))
            vertex_attributes.append(Mesh.ATTRIBUTE_TANGENT.atShaderLocation(4)) catch unreachable;
        if (layout.contains(Mesh.ATTRIBUTE_COLOR))
            vertex_attributes.append(Mesh.ATTRIBUTE_COLOR.atShaderLocation(5)) catch unreachable;

        var bind_group_layout = std.ArrayList(zgpu.BindGroupLayoutHandle).init(aya.allocator);
        bind_group_layout.append(self.view_layout) catch unreachable; // handle MSAA layout
        bind_group_layout.append(self.mesh_layouts.model_only) catch unreachable; // TODO: handle morph targets

        const vertex_buffer_layout = try layout.getLayout(vertex_attributes.items);
        _ = vertex_buffer_layout;

        var label: []const u8 = undefined;
        var blend: ?wgpu.BlendState = null;
        var depth_write_enabled = false;
        var is_opaque = false;

        if (key.blend_alpha) {
            label = "premultiplied_alpha_mesh_pipeline";
            blend = wgpu.BlendState{
                .color = .{ .src_factor = .one, .dst_factor = .one_minus_src_alpha, .operation = .add },
                .alpha = .{ .src_factor = .one, .dst_factor = .one_minus_src_alpha, .operation = .add },
            };
            // shader_defs.push("PREMULTIPLY_ALPHA".into());
            // shader_defs.push("BLEND_PREMULTIPLIED_ALPHA".into());
            // For the transparent pass, fragments that are closer will be alpha blended
            // but their depth is not written to the depth buffer
            depth_write_enabled = false;
        } else if (key.blend_premultiplied_alpha) {
            label = "premultiplied_alpha_mesh_pipeline";
            blend = wgpu.BlendState{
                .color = .{ .src_factor = .one, .dst_factor = .one_minus_alpha, .operation = .add },
                .alpha = .{ .src_factor = .one, .dst_factor = .one_minus_alpha, .operation = .add },
            };
            // shader_defs.push("PREMULTIPLY_ALPHA".into());
            // shader_defs.push("BLEND_PREMULTIPLIED_ALPHA".into());
            // For the transparent pass, fragments that are closer will be alpha blended
            // but their depth is not written to the depth buffer
            depth_write_enabled = false;
        } else if (key.blend_multiply) {
            label = "multiply_mesh_pipeline";
            blend = wgpu.BlendState{
                .color = .{ .src_factor = .dst, .dst_factor = .one_minus_src_alpha, .operation = .add },
            };
            // shader_defs.push("PREMULTIPLY_ALPHA".into());
            // shader_defs.push("BLEND_MULTIPLY".into());
            // For the multiply pass, fragments that are closer will be alpha blended
            // but their depth is not written to the depth buffer
            depth_write_enabled = false;
        } else {
            label = "opaque_mesh_pipeline";
            blend = null;
            // For the opaque and alpha mask passes, fragments that are closer will replace
            // the current fragment value in the output and the depth is written to the
            depth_write_enabled = true;
            is_opaque = true;
        }

        const format = if (key.hdr) wgpu.TextureFormat.rgba16_float else wgpu.TextureFormat.rgba8_unorm_srgb;
        _ = format;

        return RenderPipelineDescriptor{
            .layout = bind_group_layout,
        };
    }
};

// TODO: see where this is used and how its used
pub const MeshPipelineKey = packed struct(u32) {
    none: bool = false,
    hdr: bool = false,
    tonemap_in_shader: bool = false,
    deband_dither: bool = false,
    depth_prepass: bool = false,
    normal_prepass: bool = false,
    deferred_prepass: bool = false,
    motion_vector_prepass: bool = false,
    may_discard: bool = false,
    blend_opaque: bool = false,
    blend_premultiplied_alpha: bool = false,
    blend_multiply: bool = false,
    blend_alpha: bool = false,
    _padding: u19 = 0,
};

// pub const MeshPipelineKey = struct {
//     const NONE                              = 0;
//     const HDR                               = (1 << 0);
//     const TONEMAP_IN_SHADER                 = (1 << 1);
//     const DEBAND_DITHER                     = (1 << 2);
//     const DEPTH_PREPASS                     = (1 << 3);
//     const NORMAL_PREPASS                    = (1 << 4);
//     const DEFERRED_PREPASS                  = (1 << 5);
//     const MOTION_VECTOR_PREPASS             = (1 << 6);
//     const MAY_DISCARD                       = (1 << 7); // Guards shader codepaths that may discard, allowing early depth tests in most cases
//                                                         // See: https://www.khronos.org/opengl/wiki/Early_Fragment_Test
//     const ENVIRONMENT_MAP                   = (1 << 8);
//     const SCREEN_SPACE_AMBIENT_OCCLUSION    = (1 << 9);
//     const DEPTH_CLAMP_ORTHO                 = (1 << 10);
//     const TAA                               = (1 << 11);
//     const MORPH_TARGETS                     = (1 << 12);
//     const BLEND_RESERVED_BITS               = Self::BLEND_MASK_BITS << Self::BLEND_SHIFT_BITS; // ← Bitmask reserving bits for the blend state
//     const BLEND_OPAQUE                      = (0 << Self::BLEND_SHIFT_BITS);                   // ← Values are just sequential within the mask, and can range from 0 to 3
//     const BLEND_PREMULTIPLIED_ALPHA         = (1 << Self::BLEND_SHIFT_BITS);                   //
//     const BLEND_MULTIPLY                    = (2 << Self::BLEND_SHIFT_BITS);                   // ← We still have room for one more value without adding more bits
//     const BLEND_ALPHA                       = (3 << Self::BLEND_SHIFT_BITS);
//     const MSAA_RESERVED_BITS                = Self::MSAA_MASK_BITS << Self::MSAA_SHIFT_BITS;
//     const PRIMITIVE_TOPOLOGY_RESERVED_BITS  = Self::PRIMITIVE_TOPOLOGY_MASK_BITS << Self::PRIMITIVE_TOPOLOGY_SHIFT_BITS;
//     const TONEMAP_METHOD_RESERVED_BITS      = Self::TONEMAP_METHOD_MASK_BITS << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_NONE               = 0 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_REINHARD           = 1 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_REINHARD_LUMINANCE = 2 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_ACES_FITTED        = 3 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_AGX                = 4 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_SOMEWHAT_BORING_DISPLAY_TRANSFORM = 5 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_TONY_MC_MAPFACE     = 6 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const TONEMAP_METHOD_BLENDER_FILMIC      = 7 << Self::TONEMAP_METHOD_SHIFT_BITS;
//     const SHADOW_FILTER_METHOD_RESERVED_BITS = Self::SHADOW_FILTER_METHOD_MASK_BITS << Self::SHADOW_FILTER_METHOD_SHIFT_BITS;
//     const SHADOW_FILTER_METHOD_HARDWARE_2X2  = 0 << Self::SHADOW_FILTER_METHOD_SHIFT_BITS;
//     const SHADOW_FILTER_METHOD_CASTANO_13    = 1 << Self::SHADOW_FILTER_METHOD_SHIFT_BITS;
//     const SHADOW_FILTER_METHOD_JIMENEZ_14    = 2 << Self::SHADOW_FILTER_METHOD_SHIFT_BITS;
// };
