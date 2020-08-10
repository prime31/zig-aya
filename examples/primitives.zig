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
    TexturePolygon.generateMesh("assets/sword_dude.png", 2, 0.05);
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.draw.line(aya.math.Vec2.init(0, 0), aya.math.Vec2.init(640, 480), 2, aya.math.Color.blue);
    aya.draw.point(math.Vec2.init(350, 350), 10, math.Color.sky_blue);
    aya.draw.point(math.Vec2.init(380, 380), 15, math.Color.magenta);
    aya.draw.rect(math.Vec2.init(387, 372), 40, 15, math.Color.dark_brown);
    aya.draw.hollowRect(math.Vec2.init(430, 372), 40, 15, 2, math.Color.yellow);
    aya.draw.circle(math.Vec2.init(100, 350), 20, 1, 12, math.Color.orange);

    const poly = [_]math.Vec2{ .{ .x = 400, .y = 30 }, .{ .x = 420, .y = 10 }, .{ .x = 430, .y = 80 }, .{ .x = 410, .y = 60 }, .{ .x = 375, .y = 40 } };
    aya.draw.hollowPolygon(poly[0..], 2, math.Color.gold);
    aya.gfx.endPass();

    aya.gfx.beginPass(.{ .color_action = .SG_ACTION_DONTCARE });
    tri_batch.drawTriangle(.{ .x = 50, .y = 50 }, .{ .x = 150, .y = 150 }, .{ .x = 0, .y = 150 }, Color.black);
    tri_batch.drawTriangle(.{ .x = 300, .y = 50 }, .{ .x = 350, .y = 150 }, .{ .x = 200, .y = 150 }, Color.lime);
    tri_batch.endFrame();
    aya.gfx.endPass();
}

// https://github.com/cocos2d/cocos2d-x/blob/v4/cocos/2d/CCAutoPolygon.cpp
pub const TexturePolygon = struct {
    const stb_image = @import("stb_image");
    fn generateMesh(file: []const u8, epsilon: f32, threshold: f32) void {
        const image_contents = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;

        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = stb_image.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, stb_image.STBI_grey_alpha);
        if (load_res == null) return;
        defer stb_image.stbi_image_free(load_res);

        // var pixels = std.mem.bytesAsSlice(u32, load_res[0..@intCast(usize, w * h * channels)]);
        var pixels = load_res[0..@intCast(usize, w * h * 2)];

        // find first non-transparent pixel
        var pixel: ?struct { x: usize, y: usize } = null;
        var y: usize = 0;
        blk: while (y < h) : (y += 1) {
            var x: usize = 0;
            while (x < w) : (x += 1) {
                var a = pixels[(x + y * @intCast(usize, w)) * 2 + 1];
                if (a > @floatToInt(u8, threshold * 255)) {
                    pixel = .{ .x = x, .y = y };
                    break :blk;
                }
            }
        }

        std.debug.print("l: {}\n", .{pixel});
    }

    fn marchSquare() void {

    }
};
