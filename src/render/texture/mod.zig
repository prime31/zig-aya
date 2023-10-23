const aya = @import("../../aya.zig");

pub usingnamespace @import("image.zig");

pub const ImagePlugin = struct {
    pub fn build(_: ImagePlugin, app: *aya.App) void {
        _ = app.initAsset(aya.Image)
            .addPlugins(aya.RenderAssetPlugin(aya.Image));
    }
};
