const std = @import("std");
const aya = @import("../aya.zig");

/// Resource
pub fn Events(comptime T: type) type {
    return struct {
        pub var event_type = T;
        const Self = @This();

        events: std.ArrayList(T),

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .events = std.ArrayList(T).init(allocator) };
        }

        pub fn deinit(self: *Self) void {
            self.events.deinit();
        }

        pub fn send(self: Self, event: T) void {
            self.events.send(event);
        }

        pub fn sendDefault(self: Self) void {
            self.events.send(T{});
        }
    };
}

/// Sends events of type `T`
pub fn EventWriter(comptime T: type) type {
    return struct {
        const Self = @This();

        events: Events(T),

        pub fn send(self: Self, event: T) void {
            self.events.send(event);
        }

        pub fn sendDefault(self: Self) void {
            self.events.sendDefault();
        }
    };
}

pub fn EventReader(comptime T: type) type {
    return struct {
        const Self = @This();

        events: Events(T),

        /// Gets an iterator over the events this `EventReader` has not seen yet
        pub fn iter(self: Self) EventIterator(T) {
            return EventIterator(T).init(self.events);
        }

        /// Consumes all available events
        pub fn clear(self: Self) void {
            _ = self;
        }
    };
}

fn EventIterator(comptime T: type) type {
    return struct {
        const Self = @This();

        events: Events(T),

        pub fn init(events: Events(T)) Self {
            return .{ .events = events };
        }

        pub inline fn next(self: *Self) ?T {
            _ = self;
            return null;
        }
    };
}
