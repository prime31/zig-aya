const std = @import("std");
const aya = @import("../aya.zig");

pub const ResolutionScaler = struct {
    x: i32 = 0,
    y: i32 = 0,
    w: i32,
    h: i32,
    scale: f32 = 1,
};

pub const ResolutionPolicy = enum {
    none, // here be dragons: if you use this no faux backbuffer will be created and you must always call gfx.beginNullPass first!
    default,
    no_border,
    no_border_pixel_perfect,
    show_all,
    show_all_pixel_perfect,
    best_fit,

    pub fn getScaler(self: ResolutionPolicy, design_w: i32, design_h: i32) ResolutionScaler {
        if (self == .none) return .{ .w = 0, .h = 0 };

        // non-default policy requires a design size
        std.debug.assert((self != .default and design_w > 0 and design_h > 0) or self == .default);

        // common config
        std.debug.print("---- TODO: we need window size here\n", .{});
        // var w = aya.window.width();
        // var h = aya.window.height();
        var w: i32 = 800;
        var h: i32 = 600;

        // our render target size will be full screen for .default
        var rt_w = if (self == .default) w else design_w;
        var rt_h = if (self == .default) h else design_h;

        // scale of the screen size / render target size, used by both pixel perfect and non-pp
        var res_x = @as(f32, @floatFromInt(w)) / @as(f32, @floatFromInt(rt_w));
        var res_y = @as(f32, @floatFromInt(h)) / @as(f32, @floatFromInt(rt_h));

        var scale: i32 = 1;
        var scale_f: f32 = 1.0;
        var aspect_ratio = @as(f32, @floatFromInt(w)) / @as(f32, @floatFromInt(h));
        var rt_aspect_ratio = @as(f32, @floatFromInt(rt_w)) / @as(f32, @floatFromInt(rt_h));

        if (self != .default) {
            scale_f = if (rt_aspect_ratio > aspect_ratio) res_x else res_y;
            scale = @as(i32, @intFromFloat(@floor(scale_f)));

            if (scale < 1) scale = 1;
        }

        switch (self) {
            .default => {
                std.debug.print("---- TODO: we need window scale here\n", .{});
                // const win_scale = aya.window.scale();
                const win_scale = 1;
                const width = @as(i32, @intFromFloat(@as(f32, @floatFromInt(w)) / win_scale));
                const height = @as(i32, @intFromFloat(@as(f32, @floatFromInt(h)) / win_scale));
                return ResolutionScaler{
                    .x = 0,
                    .y = 0,
                    .w = width,
                    .h = height,
                    .scale = win_scale,
                };
            },
            .no_border, .show_all => {
                // go for the highest scale value if we can crop (No_Border) or
                // go for the lowest scale value so everything fits properly (Show_All)
                const res_scale = if (self == .no_border) @max(res_x, res_y) else @min(res_x, res_y);

                const x = (@as(f32, @floatFromInt(w)) - (@as(f32, @floatFromInt(rt_w)) * res_scale)) / 2.0;
                const y = (@as(f32, @floatFromInt(h)) - (@as(f32, @floatFromInt(rt_h)) * res_scale)) / 2.0;

                return ResolutionScaler{
                    .x = @as(i32, @intFromFloat(x)),
                    .y = @as(i32, @intFromFloat(y)),
                    .w = rt_w,
                    .h = rt_h,
                    .scale = res_scale,
                };
            },
            .no_border_pixel_perfect, .show_all_pixel_perfect => {
                // the only difference is that no_border rounds up (instead of down) and crops. Because
                // of the round up, we flip the compare of the rt aspect ratio vs the screen aspect ratio.
                if (self == .no_border_pixel_perfect) {
                    scale_f = if (rt_aspect_ratio < aspect_ratio) res_x else res_y;
                    scale = @as(i32, @intFromFloat(@ceil(scale_f)));
                }

                const x = @divTrunc(w - (rt_w * scale), 2);
                const y = @divTrunc(h - (rt_h * scale), 2);
                return ResolutionScaler{
                    .x = x,
                    .y = y,
                    .w = rt_w,
                    .h = rt_h,
                    .scale = @as(f32, @floatFromInt(scale)),
                };
            },
            .best_fit => {
                // TODO: move this into some sort of safe area config
                const bleed_x: i32 = 0;
                const bleed_y: i32 = 0;
                const safe_sx = @as(f32, @floatFromInt(w)) / @as(f32, @floatFromInt(rt_w - bleed_x));
                const safe_sy = @as(f32, @floatFromInt(h)) / @as(f32, @floatFromInt(rt_h - bleed_y));

                const res_scale = @max(res_x, res_y);
                const safe_scale = @min(safe_sx, safe_sy);
                const final_scale = @min(res_scale, safe_scale);

                const x = (@as(f32, @floatFromInt(w)) - (@as(f32, @floatFromInt(rt_w)) * final_scale)) / 2.0;
                const y = (@as(f32, @floatFromInt(h)) - (@as(f32, @floatFromInt(rt_h)) * final_scale)) / 2.0;

                return ResolutionScaler{
                    .x = @as(i32, @intFromFloat(x)),
                    .y = @as(i32, @intFromFloat(y)),
                    .w = rt_w,
                    .h = rt_h,
                    .scale = final_scale,
                };
            },
            else => unreachable,
        }

        return ResolutionScaler{
            .w = design_w,
            .h = design_h,
        };
    }
};

test "test resolution policy" {
    // const def_policy = ResolutionPolicy.default;
    // const def_scaler = def_policy.getScaler(600, 480);
}
