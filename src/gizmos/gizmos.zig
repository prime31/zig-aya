const std = @import("std");
const sokol = @import("sokol");
const sdtx = sokol.debugtext;

/// Resource
pub const Gizmos = struct {
    lines: std.ArrayList(comptime T: type),

    pub fn text(comptime fmt: []const u8, args: anytype) void {
        sdtx.print(fmt, args);
    }
};
