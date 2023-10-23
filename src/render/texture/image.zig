const std = @import("std");
const aya = @import("../../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

pub const Image = struct {
    data: []const u8,
    texture_descriptor: wgpu.TextureDescriptor,
    sampler_descriptor: ?wgpu.SamplerDescriptor,
    texture_view_descriptor: ?wgpu.TextureViewDescriptor = null,

    pub fn init() Image {
        const format = wgpu.TextureFormat.rgba8_unorm;
        // TODO: TextureFormat pixelSize method
        const data = aya.mem.alloc(u8, 4);
        data = &[_]u8{ 255, 255, 255, 255 };
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
};
