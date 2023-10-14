const std = @import("std");

// add any files as pub imports with tests in them
pub const assets = @import("asset/assets.zig");
pub const trait = @import("trait.zig");

test {
    std.testing.refAllDecls(@This());
}
