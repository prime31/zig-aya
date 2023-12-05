const std = @import("std");
const aya = @import("aya.zig");

const Assets = @import("assets.zig").Assets;
const EventWriters = @import("events/event_writers.zig").EventWriters;

// internal to avoid API confusion
pub var assets: Assets = undefined;
pub var event_writers: EventWriters = undefined;

pub fn init() void {
    assets = Assets.init();
    event_writers = EventWriters.init();
}

pub fn deinit() void {
    assets.deinit();
}
