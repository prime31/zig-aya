const std = @import("std");
const aya = @import("aya");
const ig = @import("imgui");

const App = aya.App;
const ResMut = aya.ResMut;
const Res = aya.Res;
const Local = aya.Local;
const Vec2 = aya.Vec2;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Startup, StartupSystem)
        .addSystems(aya.Update, ClearColorSystem)
        .run();
}

var clear_color = aya.Color.aya;
var pass: aya.OffscreenPass = undefined;
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

const StartupSystem = struct {
    pub fn run() void {
        const size = aya.window.sizeInPixels();
        pass = aya.OffscreenPass.initWithStencil(size.w, size.h, .nearest, .clamp);
    }
};

const ClearColorSystem = struct {
    pub fn run(gfx_res: ResMut(aya.GraphicsContext), box_state: Local(struct { pos: Vec2, dir: f32 })) void {
        _ = gfx_res;
        // var gfx = gfx_res.getAssertExists();
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
            var state = box_state.get();
            if (state.pos.x < 20.0 or state.pos.x > 80.0) {
                state.dir = if (state.dir <= 0) 1 else -1;
                state.pos.x = std.math.clamp(state.pos.x, 20, 80);
                state.pos.y = std.math.clamp(state.pos.y, 20, 80);
            }

            state.pos = Vec2.add(state.pos, Vec2.init(1 * state.dir, 1 * state.dir));

            stencil_read.stencil.compare_func = if (aya.input.keys.pressed(.c)) .equal else .not_equal;
            gfx.setRenderState(stencil_read);
            gfx.draw.rect(state.pos, 200, 400, aya.Color.sky_blue);
            gfx.setRenderState(.{});
        }

        gfx.endPass();

        gfx.beginPass(.{});
        gfx.draw.tex(pass.color_texture, 0, 0);
        gfx.endPass();
    }
};
