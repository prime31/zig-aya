const std = @import("std");
const aya = @import("aya");
const ig = aya.ig;

const OffscreenPass = aya.render.OffscreenPass;
const Texture = aya.render.Texture;
const Color = aya.math.Color;
const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

var tex: Texture = undefined;
var super_pass: SuperPass = undefined;

fn init() !void {
    tex = Texture.initFromFile("examples/assets/sword_dude.png", .nearest);
    super_pass = SuperPass.init(16, 9, 2);
}

fn shutdown() !void {
    tex.deinit();
    super_pass.deinit();
}

fn update() !void {}

fn render() !void {
    aya.gfx.beginPass(.{ .pass = super_pass.pass, .color = Color.orange, .viewport = super_pass.viewport(0) });
    aya.gfx.draw.rect(Vec2.init(0, 0), 1, 1, Color.black);
    aya.gfx.draw.rect(Vec2.init(1, 1), 1, 1, Color.black);
    aya.gfx.draw.rect(Vec2.init(2, 2), 1, 1, Color.black);
    aya.gfx.endPass();

    aya.gfx.beginPass(.{ .pass = super_pass.pass, .color = Color.white, .viewport = super_pass.viewport(1) });
    // aya.gfx.draw.rect(Vec2.init(0, 0), 16, 9, Color.white);
    aya.gfx.endPass();

    aya.gfx.beginPass(.{ .pass = super_pass.pass, .color = Color.sky_blue, .viewport = super_pass.viewport(2) });
    // aya.gfx.draw.rect(Vec2.init(0, 0), 16, 9, Color.sky_blue);
    aya.gfx.endPass();

    aya.gfx.beginPass(.{ .pass = super_pass.pass, .color = Color.pink, .viewport = super_pass.viewport(3) });
    // aya.gfx.draw.rect(Vec2.init(0, 0), 16, 9, Color.pink);
    aya.gfx.endPass();

    aya.gfx.beginPass(.{});
    // aya.gfx.draw.texScale(super_pass.pass.color_texture, 0, 0, 32); // 64 for full width
    aya.gfx.draw.texViewport(super_pass.pass.color_texture, super_pass.viewportRect(0), Mat32.initTransform(.{ .sx = 32, .sy = 32 }));
    aya.gfx.endPass();
}

/// holds an OffscreenPass and utility methods to render to portions of it per pass and for blitting them
const SuperPass = struct {
    pass: OffscreenPass,
    stride: u8,

    pub fn init(width: i32, height: i32, stride: u8) SuperPass {
        return .{
            .pass = OffscreenPass.init(width * @as(i32, @intCast(stride)), height * @as(i32, @intCast(stride))),
            .stride = stride,
        };
    }

    pub fn deinit(self: *SuperPass) void {
        self.pass.deinit();
    }

    pub fn viewport(self: *SuperPass, index: u8) aya.rk.Viewport {
        const column = index % self.stride;
        const row = @divFloor(index, self.stride);

        const width: c_int = @divExact(@as(c_int, @intFromFloat(self.pass.color_texture.width)), @as(c_int, @intCast(self.stride)));
        const height: c_int = @divExact(@as(c_int, @intFromFloat(self.pass.color_texture.height)), @as(c_int, @intCast(self.stride)));

        return .{
            .x = column * width,
            .y = row * height,
            .w = width,
            .h = height,
        };
    }

    pub fn viewportRect(self: *SuperPass, index: u8) aya.math.RectI {
        const vp = self.viewport(index);
        return .{
            .x = vp.x,
            .y = vp.y,
            .w = vp.w,
            .h = vp.h,
        };
    }
};

// per_row_col = 2;
// 0 => { 0, 0 } -- 0 % 2 = 0 :
// 1 => { 1, 0 } -- 1 % 2 = 1 :
// 2 => { 0, 1 } -- 2 % 2 = 0 :
// 3 => { 1, 1 } -- 3 % 2 = 1 :

// 0  1
// 2  3
