const std = @import("std");
const aya = @import("aya");
const math = aya.math;
usingnamespace @import("imgui");

pub const Camera = struct {
    pos: math.Vec2 = .{},
    zoom: f32 = 1,

    pub fn transMat(self: Camera) math.Mat32 {
        var window_half_size = ogGetWindowSize().scale(0.5);

        var transform = math.Mat32.identity;

        var tmp = math.Mat32.identity;
        tmp.translate(-self.pos.x, -self.pos.y);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.scale(self.zoom, self.zoom);
        transform = tmp.mul(transform);

        tmp = math.Mat32.identity;
        tmp.translate(window_half_size.x, window_half_size.y);
        transform = tmp.mul(transform);

        return transform;
    }

    pub fn clampZoom(self: *Camera) void {
        self.zoom = std.math.clamp(self.zoom, 0.2, 5);
    }

    pub fn screenToWorld(self: Camera, pos: math.Vec2) math.Vec2 {
        var inv_trans_mat = self.transMat().invert();
        return inv_trans_mat.transformVec2(pos);
    }

    /// calls screenToWorld converting to ImVec2s
    pub fn igScreenToWorld(self: Camera, pos: ImVec2) ImVec2 {
        const tmp = self.screenToWorld(math.Vec2{ .x = pos.x, .y = pos.y });
        return .{ .x = tmp.x, .y = tmp.y };
    }

    pub fn bounds(self: Camera) math.Rect {
        var window_size = ogGetContentRegionAvail();
        var tl = self.screenToWorld(.{});
        var br = self.screenToWorld(math.Vec2{ .x = window_size.x, .y = window_size.y });

        return math.Rect{ .x = tl.x, .y = tl.y, .w = br.x - tl.x, .h = br.y - tl.y };
    }
};