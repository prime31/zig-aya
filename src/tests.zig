const std = @import("std");

// add any files as pub imports with tests in them
pub const assets = @import("assets/assets.zig");

test {
    std.testing.refAllDecls(@This());
}
