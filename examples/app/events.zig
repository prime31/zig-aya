const std = @import("std");
const aya = @import("aya");

pub const Bootstrap = aya.Bootstrap;

const App = aya.App;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

const SuperEvent = struct {};

pub fn run(app: *App) void {
    std.debug.print("\n", .{});

    app.addEvent(SuperEvent)
        .addSystems(aya.Startup, WriteEventSystem)
        .addSystems(aya.First, ReadEventSystem)
        .run();
}

const WriteEventSystem = struct {
    pub fn run(events: EventWriter(SuperEvent)) void {
        std.debug.print("-- EmitEventSystem\n", .{});
        events.sendDefault();
    }
};

const ReadEventSystem = struct {
    pub fn run(events: EventReader(SuperEvent)) void {
        std.debug.print("-- ReadEventSystem. total events: {}\n", .{events.read().len});

        for (events.read()) |evt| {
            std.debug.print("-- --- read event: {}\n", .{evt});
        }
    }
};
