const std = @import("std");
const aya = @import("../../aya.zig");

// provides methods like ArrayList making working with slices more ergonomic.
// assumes memory is managed by aya.mem.allocator.

pub fn insert(comptime T: type, slice: *[]T, n: usize, item: T) !void {
    slice.* = try aya.mem.allocator.realloc(slice.*, slice.len + 1);
    std.mem.copyBackwards(T, slice.*[n + 1 .. slice.len], slice.*[n .. slice.len - 1]);
    slice.*[n] = item;
}

pub fn append(comptime T: type, slice: *[]T, item: T) !void {
    slice.* = try aya.mem.allocator.realloc(slice.*, slice.len + 1);
    slice.*[slice.len - 1] = item;
}

pub fn orderedRemove(comptime T: type, slice: *[]T, i: usize) T {
    const newlen = slice.len - 1;
    if (newlen == i) return pop(T, slice);

    const old_item = slice.*[i];
    for (slice.*[i..newlen], 0..) |*b, j| b.* = slice.*[i + 1 + j];
    slice.* = aya.mem.allocator.shrink(slice.*, newlen);
    return old_item;
}

pub fn pop(comptime T: type, slice: *[]T) T {
    const val = slice.*[slice.len - 1];
    slice.* = aya.mem.allocator.shrink(slice.*, slice.len - 1);
    return val;
}
