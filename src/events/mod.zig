const Events = @import("events.zig").Events;

/// event
pub const FileDropped = struct { file: []const u8 };

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
