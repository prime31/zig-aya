const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const Color = math.Color;

var tri_batch: aya.gfx.TriangleBatcher = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });

    tri_batch.deinit();
}

fn init() void {
    tri_batch = aya.gfx.TriangleBatcher.init(null, 100) catch unreachable;
    TexturePolygon.generateMesh("assets/sword_dude.png", 2, 0);
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{});
    const poly = TexturePolygon.generateMesh2("assets/sword_dude.png", 2, 0);
    // const poly = [_]math.Vec2{ .{ .x = 400, .y = 30 }, .{ .x = 420, .y = 10 }, .{ .x = 430, .y = 80 }, .{ .x = 410, .y = 60 }, .{ .x = 375, .y = 40 } };
    aya.draw.hollowPolygon(poly[0..], 1, math.Color.gold);
    aya.gfx.endPass();
}

// https://github.com/cocos2d/cocos2d-x/blob/v4/cocos/2d/CCAutoPolygon.cpp
pub const TexturePolygon = struct {
    const stb_image = @import("stb_image");

    var pixels: []const u8 = undefined;
    var threshold: u8 = 0;
    var w: i32 = 0;
    var h: i32 = 0;
    var epsilon: f32 = 0;

    fn generateMesh(file: []const u8, epsilon_: f32, threshold_: f32) void {
        threshold = @floatToInt(u8, threshold_ * 255);
        epsilon = epsilon_;
        const image_contents = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;

        var channels: c_int = undefined;
        const load_res = stb_image.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, stb_image.STBI_grey_alpha);
        if (load_res == null) return;
        defer stb_image.stbi_image_free(load_res);

        // var pixels = std.mem.bytesAsSlice(u32, load_res[0..@intCast(usize, w * h * channels)]);
        pixels = load_res[0..@intCast(usize, w * h * 2)];

        // find first non-transparent pixel
        var pixel: struct { x: usize, y: usize } = undefined;
        var y: usize = 0;
        blk: while (y < h) : (y += 1) {
            var x: usize = 0;
            while (x < w) : (x += 1) {
                if (isOpaque(x, y)) {
                    pixel = .{ .x = x, .y = y };
                    break :blk;
                }
            }
        }

        var pts = marchSquare(pixel.x, pixel.y);
        pts = reduce(&pts);

        std.debug.print("reduced: {}\n", .{pts.items.len});
    }

    fn generateMesh2(file: []const u8, epsilon_: f32, threshold_: f32) []math.Vec2 {
        threshold = @floatToInt(u8, threshold_ * 255);
        epsilon = epsilon_;
        const image_contents = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;

        var channels: c_int = undefined;
        const load_res = stb_image.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, stb_image.STBI_grey_alpha);
        defer stb_image.stbi_image_free(load_res);

        // var pixels = std.mem.bytesAsSlice(u32, load_res[0..@intCast(usize, w * h * channels)]);
        pixels = load_res[0..@intCast(usize, w * h * 2)];

        // find first non-transparent pixel
        var pixel: struct { x: usize, y: usize } = undefined;
        var y: usize = 0;
        blk: while (y < h) : (y += 1) {
            var x: usize = 0;
            while (x < w) : (x += 1) {
                if (isOpaque(x, y)) {
                    pixel = .{ .x = x, .y = y };
                    break :blk;
                }
            }
        }

        var pts = marchSquare(pixel.x, pixel.y);
        pts = reduce(&pts);
        return pts.items;
    }

    fn isOpaque(x: anytype, y: anytype) bool {
        return pixels[(@intCast(usize, x) + @intCast(usize, y) * @intCast(usize, w)) * 2 + 1] > threshold;
    }

    fn getSquareValue(x: i32, y: i32, rect: math.RectI) u32 {
        var fixed_rect = rect;
        fixed_rect.expandEdge(.right, -2);
        fixed_rect.expandEdge(.bottom, -2);

        var sv: u32 = 0;

        if (fixed_rect.contains(x - 1, y - 1) and isOpaque(x - 1, y - 1)) sv += 1;
        if (fixed_rect.contains(x, y - 1) and isOpaque(x, y - 1)) sv += 2;
        if (fixed_rect.contains(x - 1, y) and isOpaque(x - 1, y)) sv += 4;
        if (fixed_rect.contains(x, y) and isOpaque(x, y)) sv += 8;

        return sv;
    }

    fn marchSquare(x: usize, y: usize) std.ArrayList(math.Vec2) {
        const rect = math.RectI.init(0, 0, w, h);

        var step_x: i32 = 0;
        var step_y: i32 = 0;
        var prev_x: i32 = 0;
        var prev_y: i32 = 0;
        var start_x: i32 = @intCast(i32, x);
        var start_y: i32 = @intCast(i32, y);
        var cur_x: i32 = start_x;
        var cur_y: i32 = start_y;
        var count: u32 = 0;
        var case9s = std.ArrayList(usize).init(aya.mem.allocator);
        var case6s = std.ArrayList(usize).init(aya.mem.allocator);
        var points = std.ArrayList(math.Vec2).init(aya.mem.allocator);
        defer case9s.deinit();
        defer case6s.deinit();

        while (true) {
            const sv = getSquareValue(cur_x, cur_y, rect);
            switch (sv) {
                1, 5, 13 => {
                    step_x = 0;
                    step_y = -1;
                },
                8, 10, 11 => {
                    step_x = 0;
                    step_y = 1;
                },
                4, 12, 14 => {
                    step_x = -1;
                    step_y = 0;
                },
                2, 3, 7 => {
                    step_x = 1;
                    step_y = 0;
                },
                9 => {
                    const i = @intCast(usize, x) + @intCast(usize, y) * @intCast(usize, w);
                    if (std.mem.indexOfScalar(usize, case9s.items, i)) |found_index| {
                        step_x = 0;
                        step_y = 1;
                        _ = case9s.swapRemove(i);
                    } else {
                        step_x = 0;
                        step_y = -1;
                        case9s.append(i) catch unreachable;
                    }
                },
                6 => {
                    const i = @intCast(usize, x) + @intCast(usize, y) * @intCast(usize, w);
                    if (std.mem.indexOfScalar(usize, case6s.items, i)) |found_index| {
                        step_x = -1;
                        step_y = 0;
                        _ = case6s.swapRemove(i);
                    } else {
                        step_x = 1;
                        step_y = 0;
                        case6s.append(i) catch unreachable;
                    }
                },
                else => {},
            }

            cur_x += step_x;
            cur_y += step_y;
            if (step_x == prev_x and step_y == prev_y) {
                var last = &points.items[points.items.len - 1];
                last.x = @intToFloat(f32, cur_x);
                last.y = @intToFloat(f32, rect.h - cur_y);
                // _points.back().x = (float)(curx-rect.origin.x) / _scaleFactor;
                // _points.back().y = (float)(rect.size.height - cury + rect.origin.y) / _scaleFactor;
            } else {
                points.append(.{
                    .x = @intToFloat(f32, cur_x),
                    .y = @intToFloat(f32, rect.h - cur_y + rect.x),
                }) catch unreachable;
                //_points.push_back(Vec2((float)(curx - rect.origin.x) / _scaleFactor, (float)(rect.size.height - cury + rect.origin.y) / _scaleFactor));
            }

            count += 1;
            prev_x = step_x;
            prev_y = step_y;

            if (cur_x == start_x and cur_y == start_y)
                break;
        }

        return points;
    }

    fn reduce(pts: *std.ArrayList(math.Vec2)) std.ArrayList(math.Vec2) {
        if (pts.items.len < 3) @panic("less than 3 points");
        if (pts.items.len < 9) return pts.*;

        const max_ep = @intToFloat(f32, std.math.max(w, h));
        var ep = std.math.clamp(epsilon, 0, max_ep * 2);

        var result = rdp(pts.*.items, ep);

        // auto last = result.back();
        // if (last.y > result.front().y && last.getDistance(result.front()) < ep * 0.5f)
        // {
        //     result.front().y = last.y;
        //     result.pop_back();
        // }
        return result;
    }

    fn rdp(v: []math.Vec2, op: f32) std.ArrayList(math.Vec2) {
        var res = std.ArrayList(math.Vec2).init(aya.mem.allocator);
        var index: usize = 0;
        var dist: f32 = 0;

        var x: usize = 1;
        while (x < v.len - 1) : (x += 1) {
            const cdist = perpendicularDistance(v[x], v[0], v[v.len - 1]);
            if (cdist > dist) {
                dist = cdist;
                index = x;
            }
        }

        if (dist > op) {
            var r1 = rdp(v[0 .. index + 1], op);
            const r2 = rdp(v[index..], op);

            for (r2.items[1..]) |item| r1.append(item) catch unreachable;
            return r1;
        }

        res.append(v[0]) catch unreachable;
        res.append(v[v.len - 1]) catch unreachable;
        return res;
    }

    fn perpendicularDistance(i: math.Vec2, start: math.Vec2, end: math.Vec2) f32 {
        var res: f32 = 0;

        if (start.x == end.x) {
            res = std.math.fabs(i.x - end.x);
        } else if (start.y == end.y) {
            res = std.math.fabs(i.y - end.y);
        } else {
            const slope = (end.y - start.y) / (end.x - start.x);
            const intercept = start.y - (slope * start.x);
            res = std.math.fabs(slope * i.x - i.y + intercept) / std.math.sqrt(std.math.pow(f32, slope, 2) + 1);
        }

        return res;
    }
};

// rdp(const std::vector<cocos2d::Vec2>& v, float optimization)
// {
//     if (dist>optimization)
//     {
//         std::vector<Vec2>::const_iterator begin = v.begin();
//         std::vector<Vec2>::const_iterator end   = v.end();
//         std::vector<Vec2> l1(begin, begin+index+1);
//         std::vector<Vec2> l2(begin+index, end);

//         std::vector<Vec2> r1 = rdp(l1, optimization);
//         std::vector<Vec2> r2 = rdp(l2, optimization);

//         r1.insert(r1.end(), r2.begin()+1, r2.end());
//         return r1;
//     }
//     else {
//         std::vector<Vec2> ret;
//         ret.push_back(v.front());
//         ret.push_back(v.back());
//         return ret;
//     }
// }
