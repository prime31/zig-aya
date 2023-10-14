const std = @import("std");
const sokol = @import("sokol");
const sdtx = sokol.debugtext;

/// Resource
pub const Gizmos = struct {
    pub fn text(comptime fmt: []const u8, args: anytype) void {
        sdtx.print(fmt, args);
    }
};
