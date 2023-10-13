const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const EventWriter = aya.EventWriter;
const EventReader = aya.EventReader;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, AppExitEventSystem)
        .run();
}

const AppExitEventSystem = struct {
    pub fn run(ticks: aya.Local(u32), exit_events: EventWriter(aya.AppExitEvent), resize_events: EventReader(aya.WindowResized)) void {
        ticks.get().* += 1;

        if (ticks.get().* == 250000) {
            std.debug.print("-- sending AppExitEvent\n", .{});
            exit_events.send(aya.AppExitEvent{});
        }

        for (resize_events.read()) |evt| std.debug.print("WindowResizedEvent: {}\n", .{evt});
    }
};