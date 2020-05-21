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
    default,
    no_border,
    no_border_pixel_perfect,
    show_all,
    show_all_pixel_perfect,
    best_fit,

    pub fn getScaler(self: ResolutionPolicy, design_w: i32, design_h: i32) ResolutionScaler {
        // non-default policy requires a design size
        std.debug.assert((self != .default and design_w > 0 and design_h > 0) or self == .default);

        // common config
        var w: i32 = undefined;
        var h: i32 = undefined;
        aya.window.drawableSize(&w, &h);

        // our render target size will be full screen for .default
        var rt_w = if (self == .default) w else design_w;
        var rt_h = if (self == .default) h else design_h;

        // scale of the screen size / render target size, used by both pixel perfect and non-pp
        var res_x = @intToFloat(f32, w) / @intToFloat(f32, rt_w);
        var res_y = @intToFloat(f32, h) / @intToFloat(f32, rt_h);

        var scale: i32 = 1;
        var scale_f: f32 = 1.0;
        var aspect_ratio = @intToFloat(f32, w) / @intToFloat(f32, h);
        var rt_aspect_ratio = @intToFloat(f32, rt_w) / @intToFloat(f32, rt_h);

        if (self != .default) {
            scale_f = if (rt_aspect_ratio > aspect_ratio) res_x else res_y;
            scale = @floatToInt(i32, @floor(scale_f));

            if (scale < 1) scale = 1;
        }

        switch (self) {
            .default => {
                const win_scale = aya.window.scale();
                const width = @floatToInt(i32, @intToFloat(f32, w) / win_scale);
                const height = @floatToInt(i32, @intToFloat(f32, h) / win_scale);
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
                const res_scale = if (self == .no_border) std.math.max(res_x, res_y) else std.math.min(res_x, res_y);

                const x = (@intToFloat(f32, w) - (@intToFloat(f32, rt_w) * res_scale)) / 2.0;
                const y = (@intToFloat(f32, h) - (@intToFloat(f32, rt_h) * res_scale)) / 2.0;

                return ResolutionScaler{
                    .x = @floatToInt(i32, x),
                    .y = @floatToInt(i32, y),
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
                    scale = @floatToInt(i32, @ceil(scale_f));
                }

                const x = @divTrunc(w - (rt_w * scale), 2);
                const y = @divTrunc(h - (rt_h * scale), 2);
                return ResolutionScaler{
                    .x = x,
                    .y = y,
                    .w = rt_w,
                    .h = rt_h,
                    .scale = @intToFloat(f32, scale),
                };
            },
            .best_fit => {
                // TODO: move this into some sort of safe area config
                const bleed_x: i32 = 0;
                const bleed_y: i32 = 0;
                const safe_sx = @intToFloat(f32, w) / @intToFloat(f32, rt_w - bleed_x);
                const safe_sy = @intToFloat(f32, h) / @intToFloat(f32, rt_h - bleed_y);

                const res_scale = std.math.max(res_x, res_y);
                const safe_scale = std.math.min(safe_sx, safe_sy);
                const final_scale = std.math.min(res_scale, safe_scale);

                const x = (@intToFloat(f32, w) - (@intToFloat(f32, rt_w) * final_scale)) / 2.0;
                const y = (@intToFloat(f32, h) - (@intToFloat(f32, rt_h) * final_scale)) / 2.0;

                return ResolutionScaler{
                    .x = @floatToInt(i32, x),
                    .y = @floatToInt(i32, y),
                    .w = rt_w,
                    .h = rt_h,
                    .scale = final_scale,
                };
            },
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
