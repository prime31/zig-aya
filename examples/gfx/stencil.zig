const std = @import("std");
const aya = @import("aya");
const ig = @import("imgui");

const App = aya.App;
const ResMut = aya.ResMut;
const Res = aya.Res;
const Local = aya.Local;
const Input = aya.Input;
const Scancode = aya.Scancode;
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

const StartupSystem = struct {
    pub fn run() void {
        const size = aya.window.sizeInPixels();
        pass = aya.OffscreenPass.initWithStencil(size.w, size.h, .nearest, .clamp);
    }
};

const ClearColorSystem = struct {
    pub fn run(gfx_res: ResMut(aya.GraphicsContext), keys_res: Res(Input(Scancode)), box_state: Local(struct { pos: Vec2, dir: f32 })) void {
        var gfx = gfx_res.getAssertExists();
        var keys = keys_res.getAssertExists();

        aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 770, .y = 20 }, aya.Color.light_gray);

        gfx.beginPass(.{ .pass = pass, .color = clear_color, .clear_stencil = true });

        gfx.draw.text("press 'c' to toggle stencil compare func (eql, not_eql)", 5, 20, null);
        {
            gfx.setRenderState(.{
                .stencil = .{
                    .enabled = true,
                    .write_mask = 0xFF,
                    .compare_func = .always,
                    .ref = 1,
                },
            });
            gfx.draw.rect(aya.Vec2.init(50, 50), 200, 400, aya.Color.lime);
        }

        {
            var state = box_state.get();
            if (state.pos.x < 20.0 or state.pos.x > 80.0) {
                state.dir = if (state.dir <= 0) 1 else -1;
                state.pos.x = std.math.clamp(state.pos.x, 20, 80);
                state.pos.y = std.math.clamp(state.pos.y, 20, 80);
            }

            state.pos = Vec2.add(state.pos, Vec2.init(1 * state.dir, 1 * state.dir));

            const compare_func: aya.rk.CompareFunc = if (keys.pressed(.c)) .equal else .not_equal;
            gfx.setRenderState(.{
                .depth = .{ .enabled = false },
                .stencil = .{
                    .write_mask = 0x00,
                    .compare_func = compare_func,
                    .ref = 1,
                },
            });
            gfx.draw.rect(state.pos, 200, 400, aya.Color.sky_blue);
            gfx.setRenderState(.{});
        }

        gfx.endPass();

        gfx.beginPass(.{});
        gfx.draw.tex(pass.color_texture, 0, 0);
        gfx.endPass();
    }
};
