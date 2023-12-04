const std = @import("std");
const aya = @import("../aya.zig");

// pub usingnamespace @import("render_layers.zig");
// pub usingnamespace @import("texture.zig");
// pub usingnamespace @import("graphics_context.zig");
pub usingnamespace @import("batcher.zig");
// pub usingnamespace @import("triangle_batcher.zig");
// pub usingnamespace @import("fontbook.zig");
pub usingnamespace @import("mesh.zig");

pub const Vertex = extern struct {
    pos: aya.math.Vec2 = .{},
    uv: aya.math.Vec2 = .{},
    col: u32 = 0xFFFFFFFF,
};
