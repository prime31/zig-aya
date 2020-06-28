const std = @import("std");
const print = std.debug.print;
const aya = @import("aya");
usingnamespace @import("imgui");

pub var brushes: [14]ImU32 = undefined;
pub var brush_required: ImU32 = 0;
pub var brush_negated: ImU32 = 0;
pub var brush_selected: ImU32 = 0;
pub var pattern_center: ImU32 = 0;

pub var white: ImU32 = 0;

pub fn init() void {
    brushes = [_]ImU32{
        colorRgb(189, 63, 110),
        colorRgb(242, 165, 59),
        colorRgb(252, 234, 87),
        colorRgb(103, 223, 84),
        colorRgb(82, 172, 247),
        colorRgb(128, 118, 152),

        colorRgb(237, 127, 166),
        colorRgb(246, 205, 174),
        colorRgb(115, 45, 81),
        colorRgb(58, 131, 85),
        colorRgb(159, 86, 60),
        colorRgb(93, 86, 79),

        colorRgb(193, 194, 198),
        colorRgb(252, 240, 232),
    };
    brush_required = colorRgb(117, 249, 76);
    brush_negated = colorRgb(235, 50, 35);
    brush_selected = colorRgb(82, 172, 247);

    pattern_center = colorRgb(255, 253, 84);

    white = colorRgb(255, 255, 255);
}

pub fn colorRgb(r: i32, g: i32, b: i32) ImU32 {
    return igGetColorU32Vec4(.{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = 1 });
}

pub fn colorRgba(r: i32, g: i32, b: i32, a: i32) ImU32 {
    return igGetColorU32Vec4(.{ .x = @intToFloat(f32, r) / 255, .y = @intToFloat(f32, g) / 255, .z = @intToFloat(f32, b) / 255, .w = @intToFloat(f32, a) / 255 });
}
