const std = @import("std");
const aya = @import("../aya.zig");

const App = aya.App;

const gizmos = @import("gizmos.zig");
pub usingnamespace gizmos;

pub const GizmosPlugin = struct {
    pub fn build(_: GizmosPlugin, app: *App) void {
        _ = app.initResource(gizmos.Gizmos);
    }
};
