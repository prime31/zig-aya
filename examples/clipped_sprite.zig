const std = @import("std");
const aya = @import("aya");
const math = aya.math;
const Color = math.Color;
usingnamespace @import("imgui");

pub const enable_imgui = true;

var tex: aya.gfx.Texture = undefined;
var tri_batch: aya.gfx.TriangleBatcher = undefined;

var trans: math.Mat32.TransformParams = .{};
var trans2: math.Mat32.TransformParams = .{};

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() !void {
    tri_batch = aya.gfx.TriangleBatcher.init(null, 1000) catch unreachable;
    tex = aya.gfx.Texture.initFromFile("examples/assets/textures/sword_dude.png", .nearest) catch unreachable;
    TexturePolygon.generateMesh("examples/assets/textures/sword_dude.png", 2, 0);
}

fn update() !void {
    // _ = aya.utils.inspect("Trans", &trans);
    // _ = aya.utils.inspect("Trans2", &trans2);
    if (ogButton("go " ++ icons.inbox)) {
        var poly = TexturePolygon.generateMesh2("examples/assets/textures/sword_dude.png", 2, 0);
        for (poly) |pt| {
            std.debug.print("{d}\n", .{pt});
        }
    }
}

fn render() !void {
    aya.gfx.beginPass(.{});
    tri_batch.begin();

    // var poly = TexturePolygon.generateMesh2("examples/assets/textures/sword_dude.png", 2, 0);
    // var mat = math.Mat32.initTransform(.{ .x = 200, .y = 200, .sx = 1, .sy = -1 });
    // mat.transformVec2Slice(math.Vec2, poly, poly);

    // aya.draw.hollowPolygon(poly[0..], 1, math.Color.gold);

    // poly = TexturePolygon.generateMesh2("examples/assets/textures/sword_dude.png", 2, 0);
    // // mat = math.Mat32.initTransform(.{ .sx = 1, .sy = -1, .ox = 0, .oy = 64 });
    // mat = math.Mat32.initTransform(trans);
    // mat.transformVec2Slice(math.Vec2, poly, poly);
    // mat = math.Mat32.initTransform(trans2);
    // mat.transformVec2Slice(math.Vec2, poly, poly);
    // mat = math.Mat32.initTransform(.{ .x = 200, .y = 200, .sx = 1, .sy = 1 });
    // mat.transformVec2Slice(math.Vec2, poly, poly);

    // aya.draw.hollowPolygon(poly[0..], 1, math.Color.gold);
    // aya.draw.point(.{ .x = 200, .y = 200 }, 4, math.Color.black);
    aya.draw.point(.{ .x = 200, .y = 200 }, 4, math.Color.black);

    tri_batch.drawTriangle(.{ .x = 3.60, .y = 28.60 }, .{ .x = 0.00, .y = 37.40 }, .{ .x = 0.40, .y = 38.60 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 3.60, .y = 28.60 }, .{ .x = 0.00, .y = 32.20 }, .{ .x = 0.00, .y = 37.40 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 3.60, .y = 28.60 }, .{ .x = 0.40, .y = 38.60 }, .{ .x = 20.00, .y = 35.80 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 22.00, .y = 45.50 }, .{ .x = 20.00, .y = 35.80 }, .{ .x = 0.40, .y = 38.60 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 26.00, .y = 33.60 }, .{ .x = 20.00, .y = 35.80 }, .{ .x = 22.00, .y = 45.50 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 26.00, .y = 48.00 }, .{ .x = 26.00, .y = 33.60 }, .{ .x = 22.00, .y = 45.50 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 26.00, .y = 33.60 }, .{ .x = 26.00, .y = 48.00 }, .{ .x = 38.10, .y = 50.00 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 26.00, .y = 33.60 }, .{ .x = 38.10, .y = 50.00 }, .{ .x = 36.90, .y = 30.50 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 36.90, .y = 30.50 }, .{ .x = 26.00, .y = 27.30 }, .{ .x = 26.00, .y = 33.60 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 26.00, .y = 48.00 }, .{ .x = 26.00, .y = 50.00 }, .{ .x = 38.10, .y = 50.00 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 26.00, .y = 48.00 }, .{ .x = 22.00, .y = 45.50 }, .{ .x = 22.00, .y = 48.20 }, Color.purple);
    tri_batch.drawTriangle(.{ .x = 26.00, .y = 48.00 }, .{ .x = 22.00, .y = 48.20 }, .{ .x = 24.20, .y = 49.30 }, Color.purple);

    tri_batch.end();

    // const poly = [_]math.Vec2{ .{ .x = 36.90, .y = 30.50 }, .{ .x = 38.10, .y = 50.00 }, .{ .x = 26.00, .y = 50.00 }, .{ .x = 26.00, .y = 48.00 }, .{ .x = 24.20, .y = 49.30 }, .{ .x = 22.00, .y = 48.20 }, .{ .x = 22.00, .y = 45.50 }, .{ .x = 0.40, .y = 38.60 }, .{ .x = 0.00, .y = 37.40 }, .{ .x = 0.00, .y = 32.20 }, .{ .x = 3.60, .y = 28.60 }, .{ .x = 20.00, .y = 35.80 }, .{ .x = 26.00, .y = 33.60 }, .{ .x = 26.00, .y = 27.30 } };
    // aya.draw.hollowPolygon(poly[0..], 1, math.Color.gold);

    aya.draw.texScale(tex, 200, 200, 1);
    aya.draw.tex(tex, 0, 0);
    aya.gfx.endPass();
}

// https://github.com/cocos2d/cocos2d-x/blob/v4/cocos/2d/CCAutoPolygon.cpp
pub const TexturePolygon = struct {
    const stb = @import("stb");

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
        const load_res = stb.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, stb.STBI_grey_alpha);
        if (load_res == null) return;
        defer stb.stbi_image_free(load_res);

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
        const load_res = stb.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, stb.STBI_grey_alpha);
        defer stb.stbi_image_free(load_res);

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
            } else {
                points.append(.{
                    .x = @intToFloat(f32, cur_x),
                    .y = @intToFloat(f32, rect.h - cur_y + rect.x),
                }) catch unreachable;
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
