const std = @import("std");
const aya = @import("../../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

const GpuImage = aya.GpuImage;

/// Resource.
pub const DefaultImageSampler = struct {
    sampler: zgpu.SamplerHandle,
};

pub const Image = struct {
    pub const PreparedAsset = GpuImage;
    pub const ExtractedAsset = Image;

    pub const Param = struct {
        images: *aya.Assets(Image),
        gctx: *zgpu.GraphicsContext,
    };

    data: []const u8,
    texture_descriptor: wgpu.TextureDescriptor,
    sampler_descriptor: ?wgpu.SamplerDescriptor = null,
    texture_view_descriptor: ?wgpu.TextureViewDescriptor = null,

    pub fn init() Image {
        const format = wgpu.TextureFormat.rgba8_unorm;
        // TODO: TextureFormat pixelSize method
        var data = aya.mem.alloc(u8, 4);
        data[0..4].* = .{ 255, 255, 255, 255 };

        return .{
            .data = data,
            .texture_descriptor = .{
                .label = "Default Image",
                .usage = wgpu.TextureUsage{
                    .texture_binding = true,
                    .copy_dst = true,
                },
                .dimension = wgpu.TextureDimension.tdim_2d,
                .size = wgpu.Extent3D{
                    .width = 1,
                    .height = 1,
                },
                .format = format,
            },
        };
    }

    pub fn deinit(self: Image) void {
        aya.mem.free(self.data);
    }

    pub fn prepareAsset(self: *const Image.ExtractedAsset, params: Image.Param) !Image.PreparedAsset {
        _ = params;
        _ = self;
        return error.Fooooook;
    }
};
