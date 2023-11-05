const std = @import("std");
const aya = @import("../aya.zig");
const app = @import("mod.zig");

const ResMut = app.ResMut;

/// Resource, manages two ArrayLists of events that are swapped each frame. Events are available to read
/// for one full frame before they are swapped. There is always a one frame delay when reading events.
pub fn Events(comptime T: type) type {
    return struct {
        const Self = @This();

        events: std.ArrayList(T),
        events_next_frame: std.ArrayList(T),

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .events = std.ArrayList(T).init(allocator),
                .events_next_frame = std.ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.events.deinit();
            self.events_next_frame.deinit();
        }

        pub fn update(self: *Self) void {
            self.events.clearRetainingCapacity();
            std.mem.swap(std.ArrayList(T), &self.events, &self.events_next_frame);
        }

        pub fn send(self: *Self, event: T) void {
            self.events_next_frame.append(event) catch unreachable;
        }

        pub fn sendBatch(self: *Self, events: []T) void {
            self.events_next_frame.appendSlice(events) catch unreachable;
        }

        pub fn sendDefault(self: *Self) void {
            self.send(T{});
        }
    };
}

/// Sends events of type `T`
pub fn EventWriter(comptime T: type) type {
    return struct {
        pub const event_type = T;
        const Self = @This();

        events: *Events(T),

        pub fn send(self: Self, event: T) void {
            self.events.send(event);
        }

        pub fn sendBatch(self: Self, events: []T) void {
            self.events.sendBatch(events);
        }

        pub fn sendDefault(self: Self) void {
            self.events.sendDefault();
        }
    };
}

pub fn EventReader(comptime T: type) type {
    return struct {
        pub const event_type = T;
        const Self = @This();

        events: *Events(T),

        /// Gets all the events that are available to be read
        pub fn read(self: Self) []const T {
            return self.events.events.items;
        }
    };
}

pub fn EventUpdateSystem(comptime T: type) type {
    return struct {
        pub const name = "aya.systems.events.EventUpdateSystem_" ++ aya.utils.typeNameLastComponent(T);

        pub fn run(state: ResMut(Events(T))) void {
            state.getAssertExists().update();
        }
    };
}
