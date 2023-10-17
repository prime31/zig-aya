const std = @import("std");

/// Resource
pub const Gizmos = struct {
    pub fn text(comptime fmt: []const u8, args: anytype) void {
        _ = args;
        _ = fmt;
    }
};
