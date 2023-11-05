const std = @import("std");
const aya = @import("../aya.zig");

const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub var allocator = gpa.allocator();

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

pub fn create(comptime T: type) *T {
    return aya.allocator.create(T) catch unreachable;
}

pub fn destroy(ptr: anytype) void {
    aya.allocator.destroy(ptr);
}

pub fn alloc(comptime T: type, n: usize) []T {
    return aya.allocator.alloc(T, n) catch unreachable;
}

pub fn free(memory: anytype) void {
    aya.allocator.free(memory);
}
