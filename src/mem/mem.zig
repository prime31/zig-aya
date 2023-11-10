const std = @import("std");
const aya = @import("../aya.zig");

const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

// temp allocator is a ring buffer so memory doesnt need to be freed
var tmp_allocator_instance: ScratchAllocator = undefined;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub var allocator: std.mem.Allocator = undefined;
pub var tmp_allocator: std.mem.Allocator = undefined;

pub fn init() void {
    allocator = gpa.allocator();
    tmp_allocator_instance = ScratchAllocator.init(allocator);
    tmp_allocator = tmp_allocator_instance.allocator();
}

pub fn deinit() void {
    tmp_allocator_instance.deinit();
    _ = gpa.deinit();
}

pub fn create(comptime T: type) *T {
    return allocator.create(T) catch unreachable;
}

pub fn destroy(ptr: anytype) void {
    allocator.destroy(ptr);
}

pub fn alloc(comptime T: type, n: usize) []T {
    return allocator.alloc(T, n) catch unreachable;
}

pub fn free(memory: anytype) void {
    allocator.free(memory);
}
