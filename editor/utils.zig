const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");
const root = @import("root");

pub const Image = @import("utils/image.zig").Image;

pub const known_folders = @import("utils/known-folders.zig");
pub const texture_packer = @import("utils/texture_packer.zig");
pub const file_picker = @import("utils/file_picker.zig");

const AppState = root.data.AppState;
const Point = root.data.Point;
const Tilemap = root.data.Tilemap;
const Camera = @import("camera.zig").Camera;

/// given a mouse position returns the tile under it
pub fn tileIndexUnderMouse(state: *AppState, position: imgui.ImVec2, tile_size: usize, camera: Camera) ?Point {
    // mouse positions need to be subtracted from origin of content rect to get into screen space (window space really)
    const mouse_screen = position.subtract(imgui.ogGetCursorScreenPos());
    return tileIndexUnderPos(state, camera.igScreenToWorld(mouse_screen), tile_size);
}

/// given a world-space position returns the tile under it or null if position is out of bounds
pub fn tileIndexUnderPos(state: *AppState, position: imgui.ImVec2, tile_size: usize) ?Point {
    if (position.x < 0 or position.y < 0) return null;
    if (position.x > @as(f32, @floatFromInt(state.level.map_size.w * state.tile_size))) return null;
    if (position.y > @as(f32, @floatFromInt(state.level.map_size.h * state.tile_size))) return null;

    return Point{ .x = @divTrunc(@as(usize, @intFromFloat(position.x)), tile_size), .y = @divTrunc(@as(usize, @intFromFloat(position.y)), tile_size) };
}

/// fill in all the tiles between the two mouse positions using bresenham's line algo
pub fn bresenham(tilemap: *Tilemap, in_x1: f32, in_y1: f32, in_x2: f32, in_y2: f32, color: u16) void {
    var x1 = in_x1;
    var y1 = in_y1;
    var x2 = in_x2;
    var y2 = in_y2;

    const steep = @abs(y2 - y1) > @abs(x2 - x1);
    if (steep) {
        std.mem.swap(f32, &x1, &y1);
        std.mem.swap(f32, &x2, &y2);
    }

    if (x1 > x2) {
        std.mem.swap(f32, &x1, &x2);
        std.mem.swap(f32, &y1, &y2);
    }

    const dx: f32 = x2 - x1;
    const dy: f32 = @abs(y2 - y1);

    var err: f32 = dx / 2.0;
    var ystep: i32 = if (y1 < y2) 1 else -1;
    var y: i32 = @as(i32, @intFromFloat(y1));

    const maxX: i32 = @as(i32, @intFromFloat(x2));

    var x: i32 = @as(i32, @intFromFloat(x1));
    while (x <= maxX) : (x += 1) {
        if (steep) {
            const index = @as(usize, @intCast(y)) + @as(usize, @intCast(x)) * tilemap.size.w;
            _ = index;
            tilemap.setTile(.{ .x = @as(usize, @intCast(y)), .y = @as(usize, @intCast(x)) }, color);
        } else {
            const index = @as(usize, @intCast(x)) + @as(usize, @intCast(y)) * tilemap.size.w;
            _ = index;
            tilemap.setTile(.{ .x = @as(usize, @intCast(x)), .y = @as(usize, @intCast(y)) }, color);
        }

        err -= dy;
        if (err < 0) {
            y += ystep;
            err += dx;
        }
    }
}
