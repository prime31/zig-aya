const std = @import("std");
const aya = @import("aya");

pub const AppState = struct {
    pub fn init() AppState {
        return .{};
    }

    pub fn deinit(self: AppState) void {}
};