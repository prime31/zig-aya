const std = @import("std");
const aya = @import("../aya.zig");

pub const WindowPlugin = struct {
    pub fn build(app: *aya.App) void {
        _ = app;
    }
};
