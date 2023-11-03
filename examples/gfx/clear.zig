const std = @import("std");
const aya = @import("aya");

pub const GPUInterface = @import("zgpu").wgpu.dawn.Interface;

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
    pub fn run(clear_color_res: ResMut(ClearColor)) void {
        var clear_color = clear_color_res.getAssertExists();

        clear_color.r += 0.005;
        clear_color.r = if (clear_color.r > 1) 0 else clear_color.r;
    }
};
