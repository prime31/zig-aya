const std = @import("std");
const aya = @import("../aya.zig");
const self = @This();

pub usingnamespace @import("spatial_bundle.zig");
pub usingnamespace @import("texture.zig");
pub usingnamespace @import("gfx.zig");
pub usingnamespace @import("batcher.zig");
pub usingnamespace @import("fontbook.zig");
pub usingnamespace @import("mesh.zig");

pub const Axis = enum(u8) {
    x,
    y,
};

pub const Size = struct {
    w: c_int = 0,
    h: c_int = 0,
};
