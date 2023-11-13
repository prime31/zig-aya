const std = @import("std");
const aya = @import("aya");
const ig = aya.ig;

const OffscreenPass = aya.render.OffscreenPass;
const Texture = aya.render.Texture;
const Color = aya.math.Color;
const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;
const Rect = aya.math.Rect;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

var camera: Camera = .{};
var upscale_camera: Camera = .{};
var cam_speed: f32 = 1;
var cam_scroll_distance: f32 = 10;
var cam_start_x: f32 = 0;

var tex: Texture = undefined;
var super_pass: SuperPass = undefined;
var bgs: [4]Texture = undefined;
var layers: [4]ParallaxLayer = [_]ParallaxLayer{ .{ .ratio = 1 }, .{ .ratio = 0.5 }, .{ .ratio = 0.0 }, .{ .ratio = -1 } };

fn init() !void {
    tex = Texture.initFromFile("examples/assets/sword_dude.png", .nearest);
    super_pass = SuperPass.init(16, 9, 2);

    bgs[0] = Texture.initFromFile("examples/assets/bg0.png", .nearest);
    bgs[1] = Texture.initFromFile("examples/assets/bg1.png", .nearest);
    bgs[2] = Texture.initFromFile("examples/assets/bg2.png", .nearest);
    bgs[3] = Texture.initFromFile("examples/assets/bg3.png", .nearest);

    var pass_size = Vec2.init(16, 9);
    pass_size.scale(0.5);
    camera.pos = pass_size;
    cam_start_x = camera.pos.x;
    camera.size = pass_size;

    const window_size = aya.window.sizeInPixels().asVec2();
    var window_half_size = window_size.mul(.{ .x = 0.5, .y = 0.5 });
    upscale_camera.pos.x = window_half_size.x - 20;
    upscale_camera.pos.y = window_half_size.y - 20;
}

fn shutdown() !void {
    tex.deinit();
    super_pass.deinit();
    for (bgs) |bg| bg.deinit();
}

fn update() !void {
    ig.igText("Default Camera");
    ig.igText("Cam Start Pos.x %0.2f", cam_start_x);
    _ = ig.igDragFloat("Cam Start Pos.x", &cam_start_x, 0.1, -80, 80, null, ig.ImGuiSliderFlags_None);
    _ = ig.igDragFloat2("Cam Pos##1", &camera.pos.x, 0.1, -80, 80, null, ig.ImGuiSliderFlags_None);
    _ = ig.igDragFloat("Cam Speed", &cam_speed, 0.1, 0, 5, null, ig.ImGuiSliderFlags_None);
    _ = ig.igDragFloat("Cam Scroll Dist", &cam_scroll_distance, 0.1, 0.01, 25, null, ig.ImGuiSliderFlags_None);

    ig.igDummy(.{ .y = 20 });
    for (&layers) |*layer| {
        ig.igPushID_Ptr(layer);
        defer ig.igPopID();

        ig.igText("Layer - Ratio: %.2f, Offset.x: %.4f, Remainder.x: %.2f", layer.ratio, layer.offset.x, layer.cam_remainder.x);
        _ = ig.igDragFloat("Ratio", &layer.ratio, 0.1, -2, 5, null, ig.ImGuiSliderFlags_None);
    }

    if (cam_speed > 0)
        camera.pos.x = cam_start_x + aya.math.pingpong(aya.time.seconds() * cam_speed, cam_scroll_distance);

    for (&layers) |*layer| layer.update(camera);
}

fn render() !void {
    for (0..4) |i| {
        aya.gfx.beginPass(.{
            .pass = super_pass.pass,
            .color = Color.transparent,
            .viewport = super_pass.viewport(@intCast(i)),
            .trans_mat = camera.transMatClampedToLayer(layers[i]),
        });
        aya.gfx.draw.tex(bgs[i], -16, 0);
        aya.gfx.draw.tex(bgs[i], 0, 0);
        aya.gfx.draw.tex(bgs[i], 16, 0);
        aya.gfx.endPass();
    }

    // for (0..4) |i| {
    //     aya.gfx.beginPass(.{
    //         .pass = super_pass.pass,
    //         .color = Color.transparent,
    //         .viewport = super_pass.viewport(@intCast(i)),
    //         .trans_mat = camera.transMat(),
    //     });

    //     aya.gfx.draw.tex(bgs[i], -16 + layers[i].offset.x, 0);
    //     aya.gfx.draw.tex(bgs[i], layers[i].offset.x, 0);
    //     aya.gfx.draw.tex(bgs[i], 16 + layers[i].offset.x, 0);
    //     aya.gfx.endPass();
    // }

    aya.gfx.beginPass(.{});
    // aya.gfx.draw.texScale(super_pass.pass.color_texture, 0, 0, 32); // 64 for full width
    // aya.gfx.draw.texViewport(super_pass.pass.color_texture, super_pass.viewportRect(0), Mat32.initTransform(.{ .sx = 32, .sy = 32 }));
    for (0..4) |i| {
        const scale = 32;
        var offset_x = layers[i].cam_remainder.x;
        const mat = Mat32.initTransform(.{ .x = offset_x * scale, .y = 0, .sx = scale, .sy = scale });
        aya.gfx.draw.texViewport(super_pass.pass.color_texture, super_pass.viewportRect(@intCast(i)), mat);
    }
    aya.gfx.endPass();

    // debug render in bottom-right corner
    aya.gfx.beginPass(.{ .clear_color = false });
    const scale: f32 = 10;
    const win_size = aya.window.sizeInPixels();
    const x = @as(f32, @floatFromInt(win_size.w)) - super_pass.pass.color_texture.width * scale;
    const y = @as(f32, @floatFromInt(win_size.h)) - super_pass.pass.color_texture.height * scale;
    aya.gfx.draw.texScale(super_pass.pass.color_texture, x - 10, y - 10, scale);
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

const ParallaxLayer = struct {
    /// 0 is central layer, -n is forground and +n is bg. Over 1 reverses parallax
    ratio: f32 = 0,
    offset: Vec2 = .{},
    cam_remainder: Vec2 = .{},

    pub fn update(self: *ParallaxLayer, cam: Camera) void {
        const cam_displacement_x = cam.pos.x - cam_start_x;
        self.offset.x = self.ratio * cam_displacement_x;

        const cam_x = cam.pos.x - self.offset.x;
        const remainder = @round(cam_x) - cam_x;
        self.cam_remainder.x = remainder;
        // const cam_offset_x = self.cam_render.x - @round(self.cam_render.x);
        // self.cam_render.x -= cam_offset_x;

        // const rounded_x = @round(cam_displacement_x);
        // self.round_remainder.x = rounded_x - cam_displacement_x;
        // self.offset.x = rounded_x * self.factor(cam.z_dist);
    }
};

pub const Camera = struct {
    pos: Vec2 = .{},
    zoom: f32 = 1,
    size: ?Vec2 = null,

    pub fn transMat(self: Camera) Mat32 {
        var half_size = if (self.size) |sz| sz else aya.window.sizeInPixels().asVec2().mul(.{ .x = 0.5, .y = 0.5 });

        var transform = Mat32.identity;
        var tmp = Mat32.identity;
        tmp.translate(-self.pos.x, -self.pos.y);
        transform = tmp.mul(transform);

        tmp = Mat32.identity;
        tmp.scale(self.zoom, self.zoom);
        transform = tmp.mul(transform);

        tmp = Mat32.identity;
        tmp.translate(half_size.x, half_size.y);
        transform = tmp.mul(transform);

        return transform;
    }

    pub fn transMatClamped(self: Camera) Mat32 {
        var half_size = if (self.size) |sz| sz else aya.window.sizeInPixels().asVec2().mul(.{ .x = 0.5, .y = 0.5 });

        var transform = Mat32.identity;
        var tmp = Mat32.identity;

        tmp.translate(@round(-self.pos.x), @round(-self.pos.y));
        transform = tmp.mul(transform);

        tmp = Mat32.identity;
        tmp.scale(self.zoom, self.zoom);
        transform = tmp.mul(transform);

        tmp = Mat32.identity;
        tmp.translate(@round(half_size.x), @round(half_size.y));
        transform = tmp.mul(transform);

        return transform;
    }

    pub fn transMatClampedToLayer(self: Camera, layer: ParallaxLayer) Mat32 {
        var half_size = if (self.size) |sz| sz else aya.window.sizeInPixels().asVec2().mul(.{ .x = 0.5, .y = 0.5 });

        var transform = Mat32.identity;
        var tmp = Mat32.identity;

        const pos_x = self.pos.x - layer.offset.x;
        tmp.translate(@round(-pos_x), @round(-self.pos.y));
        transform = tmp.mul(transform);

        tmp = Mat32.identity;
        tmp.scale(self.zoom, self.zoom);
        transform = tmp.mul(transform);

        tmp = Mat32.identity;
        tmp.translate(@round(half_size.x), @round(half_size.y));
        transform = tmp.mul(transform);

        return transform;
    }

    pub fn screenToWorld(self: Camera, pos: Vec2) Vec2 {
        var inv_trans_mat = self.transMat().invert();
        return inv_trans_mat.transformVec2(pos);
    }

    pub fn bounds(self: Camera) Rect {
        const window_size = aya.window.sizeInPixels().asVec2();
        var tl = self.screenToWorld(.{});
        var br = self.screenToWorld(.{ .x = window_size.x, .y = window_size.y });

        return Rect{ .x = tl.x, .y = tl.y, .w = br.x - tl.x, .h = br.y - tl.y };
    }
};
