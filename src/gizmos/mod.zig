const std = @import("std");
const aya = @import("../aya.zig");
const sokol = @import("sokol");
const sdtx = sokol.debugtext;

const App = aya.App;
const Res = aya.Res;

const gizmos = @import("gizmos.zig");
pub usingnamespace gizmos;

pub const GizmosPlugin = struct {
    pub fn build(_: GizmosPlugin, app: *App) void {
        _ = app.insertResource(gizmos.Gizmos);

        var sdtx_desc: sdtx.Desc = .{};
        sdtx_desc.fonts[0] = sdtx.sdtx_font_z1013();
        sdtx.setup(sdtx_desc);
    }
};
