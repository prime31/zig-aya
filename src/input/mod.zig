const std = @import("std");
const aya = @import("../aya.zig");

pub usingnamespace @import("input.zig");

pub const InputPlugin = struct {
    pub fn build(app: *aya.App) void {
        _ = app;
    }
};