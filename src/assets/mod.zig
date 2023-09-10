const std = @import("std");
const aya = @import("../aya.zig");

const App = aya.App;
const Allocator = std.mem.Allocator;
const AssetServer = @import("asset_server.zig").AssetServer;

pub usingnamespace @import("assets.zig");
pub usingnamespace @import("asset_server.zig");
pub usingnamespace @import("handles.zig");

pub const AssetPlugin = struct {
    pub fn build(app: *App) void {
        _ = app.initResource(AssetServer);
    }
};
