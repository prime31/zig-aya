const mod = @This();

pub usingnamespace @import("math.zig");
pub usingnamespace @import("color.zig");
pub usingnamespace @import("edge.zig");
pub usingnamespace @import("mat4.zig");
pub usingnamespace @import("mat32.zig");
pub usingnamespace @import("quad.zig");
pub usingnamespace @import("rand.zig");
pub usingnamespace @import("rect.zig");
pub usingnamespace @import("vec2.zig");
pub usingnamespace @import("vec3.zig");
pub usingnamespace @import("vec4.zig");

pub const Axis = enum(u8) {
    x,
    y,
};

pub const Size = struct {
    w: c_int = 0,
    h: c_int = 0,

    pub fn asVec2(self: Size) mod.Vec2 {
        return mod.Vec2.init(@floatFromInt(self.w), @floatFromInt(self.h));
    }
};
