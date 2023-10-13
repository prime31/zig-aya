const aya = @import("../aya.zig");

pub usingnamespace @import("mesh.zig");

pub const RenderPlugin = struct {
    pub fn build(_: RenderPlugin, app: *aya.App) void {
        _ = app;
    }
};
