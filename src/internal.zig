const std = @import("std");
const aya = @import("aya.zig");

const Assets = @import("assets.zig").Assets;

// internal to avoid API confusion
pub var assets: Assets = undefined;

pub fn init() void {
    assets = Assets.init();
}

pub fn deinit() void {
    assets.deinit();
}
