const std = @import("std");
const aya = @import("aya");
const sdl = @import("sdl");
const math = aya.math;

var checker_tex: aya.gfx.Texture = undefined;
var font_tex: aya.gfx.Texture = undefined;
var pass: aya.gfx.OffscreenPass = undefined;
var stack: aya.gfx.PostProcessStack = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .gfx = .{
            .resolution_policy = .show_all_pixel_perfect,
        },
    });
}

fn init() void {
    checker_tex = aya.gfx.Texture.initCheckerboard();
    font_tex = aya.gfx.Texture.initFromFile("assets/font.png", .linear) catch unreachable;
    pass = aya.gfx.OffscreenPass.init(52, 52, .nearest);

    stack = aya.gfx.createPostProcessStack();
    _ = stack.add(aya.gfx.Sepia, {});
}

fn shutdown() void {
    checker_tex.deinit();
    font_tex.deinit();
    pass.deinit();
    stack.deinit();
}

fn update() void {
    // if (aya.input.keyUp(.SDL_SCANCODE_K)) {
    //     var w: i32 = 0;
    //     var h: i32 = 0;
    //     aya.window.size(&w, &h);

    //     if (w < 1280) {
    //         aya.window.setSize(1280, 960);
    //     } else {
    //         aya.window.setSize(640, 480);
    //     }
    // }
}

fn render() void {
    // render offscreen
    aya.gfx.beginPass(.{ .pass = pass, .color = aya.math.Color.lime });
    var i = @as(usize, 0);
    while (i <= @divFloor(pass.color_tex.width, checker_tex.width)) : (i += 1) {
        aya.draw.tex(checker_tex, @intToFloat(f32, i * 4), @intToFloat(f32, i * 2 + 10));
    }
    aya.gfx.endPass();

    // render into our default render target
    aya.gfx.beginPass(.{});
    aya.draw.texScale(checker_tex, 5, 5, 10);
    aya.draw.texScale(checker_tex, 55, 55, 2);
    // aya.gfx.flush();

    aya.draw.texScale(font_tex, 200, 100, 0.2);
    aya.draw.texScale(font_tex, 300, 200, 0.2);
    // aya.gfx.flush();

    aya.draw.line(.{ .x = 0, .y = 0 }, aya.math.Vec2.init(640, 480), 2, aya.math.Color.blue);
    aya.draw.point(.{ .x = 350, .y = 350 }, 10, math.Color.sky_blue);
    aya.draw.point(.{ .x = 380, .y = 380 }, 15, math.Color.magenta);
    aya.draw.rect(.{ .x = 387, .y = 372 }, 40, 15, math.Color.dark_brown);
    aya.draw.hollowRect(.{ .x = 430, .y = 372 }, 40, 15, 2, math.Color.yellow);
    aya.draw.circle(.{ .x = 100, .y = 350 }, 20, 1, 12, math.Color.orange);

    const poly = [_]math.Vec2{ .{ .x = 400, .y = 30 }, .{ .x = 420, .y = 10 }, .{ .x = 430, .y = 80 }, .{ .x = 410, .y = 60 }, .{ .x = 375, .y = 40 } };
    aya.draw.hollowPolygon(poly[0..], 2, math.Color.gold);
    aya.gfx.endPass();

    // blit the default render target to the screen
    aya.gfx.postProcess(&stack);
    aya.gfx.blitToScreen(aya.math.Color.black);

    // now render directly to the backbuffer
    aya.gfx.beginPass(.{ .color_action = .SG_ACTION_DONTCARE });
    aya.debug.drawPoint(.{ .x = 30, .y = 400 }, 60, aya.math.Color.yellow);
    aya.draw.texScale(pass.color_tex, 0, 200, 2);
    aya.gfx.endPass();
}
