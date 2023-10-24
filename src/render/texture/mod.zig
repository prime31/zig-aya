const aya = @import("../../aya.zig");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

pub usingnamespace @import("image.zig");

pub const ImagePlugin = struct {
    default_sampler: wgpu.SamplerDescriptor = .{
        .mag_filter = .linear,
        .min_filter = .linear,
        .mipmap_filter = .linear,
    },

    pub fn build(self: ImagePlugin, app: *aya.App) void {
        _ = app.initAsset(aya.Image)
            .addPlugins(aya.RenderAssetPlugin(aya.Image));

        const gctx = app.world.getResourceMut(zgpu.GraphicsContext).?;

        _ = app.insertResource(aya.DefaultImageSampler{
            .sampler = gctx.createSampler(self.default_sampler),
        });
    }

    pub fn defaultLinear() ImagePlugin {
        return .{
            .default_sampler = wgpu.SamplerDescriptor{
                .mag_filter = .linear,
                .min_filter = .linear,
                .mipmap_filter = .linear,
            },
        };
    }

    pub fn defaultNearest() ImagePlugin {
        return .{ .default_sampler = .{} };
    }
};
