const std = @import("std");
const c = @cImport(@cInclude("stdlib.h"));

pub fn main() void {
    std.debug.warn("Hello, world!\n", .{});
    c.printf("fucker\n");
}
