const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const ResMut = aya.ResMut;
const ClearColor = aya.ClearColor;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, ClearColorSystem)
        .run();
}

const ClearColorSystem = struct {
    pub fn run(clear_color_res: ResMut(ClearColor), gfx_res: ResMut(aya.GraphicsContext)) void {
        var clear_color = clear_color_res.getAssertExists();
        var gfx = gfx_res.getAssertExists();

        clear_color.r += 0.005;
        clear_color.r = if (clear_color.r > 1) 0 else clear_color.r;

        gfx.beginFrame();
        gfx.beginPass(.{});
        gfx.endPass();
        gfx.commitFrame();
    }
};
