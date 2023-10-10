const std = @import("std");
const aya = @import("aya");

const App = aya.App;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .run();
}
