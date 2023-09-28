const std = @import("std");
const aya = @import("../aya.zig");

const App = aya.App;
const Allocator = std.mem.Allocator;
const AssetServer = @import("asset_server.zig").AssetServer;

pub const AssetId = @import("asset_handle_provider.zig").AssetId;

pub usingnamespace @import("assets.zig");
pub usingnamespace @import("asset_server.zig");
pub usingnamespace @import("handles.zig");

pub const AssetPlugin = struct {
    pub fn build(self: AssetPlugin, app: *App) void {
        _ = self;
        _ = app.initResource(AssetServer);
    }
};
