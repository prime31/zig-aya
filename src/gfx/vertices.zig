const Vec2 = @import("../math/vec2.zig").Vec2;

pub const Vertex = struct {
    pos: Vec2,
    uv: Vec2,
    col: u32 = 0xFFFFFFFF,
};
