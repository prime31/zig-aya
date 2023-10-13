const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

const SuperEvent = struct {};

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addEvent(SuperEvent)
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
