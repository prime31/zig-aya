const std = @import("std");
const aya = @import("../aya.zig");
const self = @This();

pub usingnamespace @import("shapes/mod.zig");
pub usingnamespace @import("mesh.zig");

pub const RenderPlugin = struct {
    pub fn build(_: RenderPlugin, app: *aya.App) void {
        _ = app.initAsset(self.Mesh);
    }
};
