const std = @import("std");
const c = @cImport(@cInclude("stdlib.h"));

pub fn main() void {
    std.debug.warn("Hello, world!\n", .{});

    thing(.first);

    const PackedI2 = std.PackedIntArray(i2, 5);
    var arri2 = PackedI2.init([_]i2{ 0, 1, 0, 1, 0 });

    var i = @as(usize, 0);
    while (i < arri2.len()) : (i += 1) {
        std.debug.warn("{}\n", .{arri2.get(i)});
    }
}

fn thing(fart: enum { first, second }) void {
    std.debug.warn("fart: {}\n", .{fart});
}
