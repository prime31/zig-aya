const std = @import("std");
const aya = @import("../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const Assets = aya.Assets;
const Shader = aya.Shader;
const Handle = aya.Handle;

const World = aya.World;
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
    /// This dummy white texture is to be used in place of optional StandardMaterial textures
    dummy_white_gpu_image: GpuImage,
    clustered_forward_buffer_binding_type: wgpu.BufferBindingType = .storage,
    mesh_layouts: MeshLayouts,

    pub fn init(world: *World) MeshPipeline {
        var gctx = world.getResourceMut(zgpu.GraphicsContext).?;

        // A 1x1x1 'all 1.0' texture to use as a dummy texture to use in place of optional StandardMaterial textures
        const dummy_white_gpu_image = blk: {
            const image = aya.Image.init();
            defer image.deinit();

            const texture = gctx.createTexture(image.texture_descriptor);
            const sampler = if (image.sampler_descriptor) |sampler_descriptor| gctx.createSampler(sampler_descriptor) else sblk: {
                const default_sampler = world.getResource(aya.DefaultImageSampler).?;
                break :sblk default_sampler.sampler;
            };

            const format_size = 4; //image.texture_descriptor.format // TODO: make method to get size from format
            gctx.queue.writeTexture(
                .{ .texture = gctx.lookupResource(texture).? },
                .{
                    .bytes_per_row = image.texture_descriptor.size.width * format_size,
                    .rows_per_image = image.texture_descriptor.size.height,
                },
                .{
                    .width = image.texture_descriptor.size.width,
                    .height = image.texture_descriptor.size.height,
                },
                u8,
                image.data,
            );

            const texture_view = gctx.createTextureView(texture, .{});
            break :blk GpuImage{
                .texture = gctx.lookupResource(texture).?,
                .texture_view = texture_view,
                .texture_format = image.texture_descriptor.format,
                .sampler = sampler,
                .size = @Vector(2, f32){ @floatFromInt(image.texture_descriptor.size.width), @floatFromInt(image.texture_descriptor.size.width) },
                .mip_level_count = image.texture_descriptor.mip_level_count,
            };
        };

        return .{
            .dummy_white_gpu_image = dummy_white_gpu_image,
            .mesh_layouts = MeshLayouts.init(gctx),
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
