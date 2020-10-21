const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");

const editor = @import("editor.zig");

/// fill in all the tiles between the two mouse positions using bresenham's line algo
pub fn bresenham(tilemap: *editor.data.Tilemap, in_x1: f32, in_y1: f32, in_x2: f32, in_y2: f32, color: u16) void {
    var x1 = in_x1;
    var y1 = in_y1;
    var x2 = in_x2;
    var y2 = in_y2;

    const steep = std.math.absFloat(y2 - y1) > std.math.absFloat(x2 - x1);
    if (steep) {
        std.mem.swap(f32, &x1, &y1);
        std.mem.swap(f32, &x2, &y2);
    }

    if (x1 > x2) {
        std.mem.swap(f32, &x1, &x2);
        std.mem.swap(f32, &y1, &y2);
    }

    const dx: f32 = x2 - x1;
    const dy: f32 = std.math.absFloat(y2 - y1);

    var err: f32 = dx / 2.0;
    var ystep: i32 = if (y1 < y2) 1 else -1;
    var y: i32 = @floatToInt(i32, y1);

    const maxX: i32 = @floatToInt(i32, x2);

    var x: i32 = @floatToInt(i32, x1);
    while (x <= maxX) : (x += 1) {
        if (steep) {
            const index = @intCast(usize, y) + @intCast(usize, x) * tilemap.size.w;
            tilemap.setTile(.{ .x = @intCast(usize, y), .y = @intCast(usize, x) }, color);
        } else {
            const index = @intCast(usize, x) + @intCast(usize, y) * tilemap.size.w;
            tilemap.setTile(.{ .x = @intCast(usize, x), .y = @intCast(usize, y) }, color);
        }

        err -= dy;
        if (err < 0) {
            y += ystep;
            err += dx;
        }
    }
}
