const std = @import("std");
const aya = @import("aya");

pub const Bootstrap = aya.Bootstrap;

const App = aya.App;
const ResMut = aya.ResMut;
const ClearColor = aya.ClearColor;

pub fn run(app: *App) void {
    std.debug.print("\n", .{});

    app.addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, ClearColorSystem)
        .run();
}

const ClearColorSystem = struct {
    pub fn run(clear_color_res: ResMut(ClearColor)) void {
        var clear_color = clear_color_res.getAssertExists();

        clear_color.r += 0.005;
        clear_color.r = if (clear_color.r > 1) 0 else clear_color.r;
    }
};
