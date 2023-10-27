const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const ResMut = aya.ResMut;
const Res = aya.Res;
const Input = aya.Input;
const Scancode = aya.Scancode;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, ClearColorSystem)
        .run();
}

const ClearColorSystem = struct {
    pub fn run(gfx_res: ResMut(aya.GraphicsContext), keys_res: Res(Input(Scancode))) void {
        var gfx = gfx_res.getAssertExists();
        var keys = keys_res.getAssertExists();

        if (!keys.pressed(.k)) {
            aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 400, .y = 20 }, null);
            aya.debug.drawHollowCircle(.{ .x = 600, .y = 600 }, 30, 4, aya.Color.dark_purple);
        }

        gfx.beginPass(.{});
        gfx.draw.text("fo fuck yourself", 24, 20, null);
        gfx.draw.rect(aya.Vec2.init(50, 50), 200, 400, aya.Color.lime);
        gfx.endPass();
    }
};
