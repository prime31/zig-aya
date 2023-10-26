const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const ResMut = aya.ResMut;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, ClearColorSystem)
        .run();
}

const ClearColorSystem = struct {
    pub fn run(gfx_res: ResMut(aya.GraphicsContext)) void {
        var gfx = gfx_res.getAssertExists();

        aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 400, .y = 20 }, null);
        aya.debug.drawHollowCircle(.{ .x = 600, .y = 600 }, 30, 4, aya.Color.dark_purple);

        gfx.beginPass(.{});
        gfx.draw.text("fo fuck yourself", 24, 20, null);
        gfx.draw.rect(aya.Vec2.init(50, 50), 200, 400, aya.Color.lime);
        gfx.endPass();
    }
};
