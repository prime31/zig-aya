const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const imgui = @import("imgui");

pub const Camera = struct {
    pos: math.Vec2 = .{},
    window_size: math.Vec2 = .{},
    zoom: f32 = 1,

    pub fn init() Camera {
        return .{};
    }

    pub fn transMat(self: Camera) math.Mat32 {
        var window_half_size = self.window_size.mul(.{ .x = 0.5, .y = 0.5 });
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
        self.zoom = std.math.clamp(self.zoom, 0.5, 5);
    }

    pub fn screenToWorld(self: Camera, pos: math.Vec2) math.Vec2 {
        var inv_trans_mat = self.transMat().invert();
        return inv_trans_mat.transformVec2(pos);
    }

    /// calls screenToWorld converting to ImVec2s
    pub fn igScreenToWorld(self: Camera, pos: imgui.ImVec2) imgui.ImVec2 {
        const tmp = self.screenToWorld(math.Vec2{ .x = pos.x, .y = pos.y });
        return .{ .x = tmp.x, .y = tmp.y };
    }

    pub fn bounds(self: Camera) math.Rect {
        var tl = self.screenToWorld(.{});
        var br = self.screenToWorld(.{ .x = self.window_size.x, .y = self.window_size.y });

        return math.Rect{ .x = tl.x, .y = tl.y, .w = br.x - tl.x, .h = br.y - tl.y };
    }

    /// clamps the map to (0,0) - (width,height) with some optional padding around the outside
    pub fn clampToMap(self: *Camera, width: usize, height: usize, padding: f32) void {
        const bnds = self.bounds();
        var half_screen = math.Vec2{ .x = bnds.w, .y = bnds.h };
        half_screen.scale(0.5);
        half_screen = half_screen.subtract(.{ .x = padding, .y = padding });

        const max = math.Vec2{ .x = @intToFloat(f32, width) - half_screen.x, .y = @intToFloat(f32, height) - half_screen.y };
        // ensure we dont zoom out so far that our clamp becomes pointless
        if (half_screen.x > max.x or half_screen.y > max.y) {
            self.pos = half_screen;
        } else {
            self.pos = self.pos.clamp(half_screen, max);
        }
    }
};
