const std = @import("std");
const aya = @import("aya");
const ig = aya.ig;

const Vec2 = aya.Vec2;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .render = render,
    });
}

var clear_color = aya.Color.aya;
var pass: aya.OffscreenPass = undefined;
var box_state: struct { pos: Vec2, dir: f32 } = .{ .pos = Vec2.init(30, 30), .dir = 1 };

var stencil_write: aya.rk.RenderState = .{
    .stencil = .{ .ref = 1 },
};
var stencil_read: aya.rk.RenderState = .{
    .depth = .{ .enabled = false },
    .stencil = .{
        .write_mask = 0x00,
        .compare_func = .equal,
        .ref = 1,
    },
};

fn init() !void {
    const size = aya.window.sizeInPixels();
    pass = aya.OffscreenPass.initWithStencil(size.w, size.h, .nearest, .clamp);
}

fn render() !void {
    var gfx = aya.gfx;

    aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 770, .y = 20 }, aya.Color.light_gray);

    gfx.beginPass(.{ .pass = pass, .color = clear_color, .clear_stencil = true });
    gfx.draw.text("press 'c' to toggle stencil compare func (eql, not_eql)", 5, 20, null);

    // stencil write
    {
        gfx.setRenderState(stencil_write);
        gfx.draw.rect(aya.Vec2.init(50, 50), 200, 400, aya.Color.lime);
    }

    // stencil read
    {
        if (box_state.pos.x < 20.0 or box_state.pos.x > 80.0) {
            box_state.dir = if (box_state.dir <= 0) 1 else -1;
            box_state.pos.x = std.math.clamp(box_state.pos.x, 20, 80);
            box_state.pos.y = std.math.clamp(box_state.pos.y, 20, 80);
        }

        box_state.pos = Vec2.add(box_state.pos, Vec2.init(1 * box_state.dir, 1 * box_state.dir));

        stencil_read.stencil.compare_func = if (aya.input.keys.pressed(.c)) .equal else .not_equal;
        gfx.setRenderState(stencil_read);
        gfx.draw.rect(box_state.pos, 200, 400, aya.Color.sky_blue);
        gfx.setRenderState(.{});
    }

    gfx.endPass();

    gfx.beginPass(.{});
    gfx.draw.tex(pass.color_texture, 0, 0);
    gfx.endPass();
}
