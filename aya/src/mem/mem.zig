const std = @import("std");
const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

pub const SdlBufferStream = @import("sdl_stream.zig").SdlBufferStream;

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: *std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

pub const allocator = @import("sdl_allocator.zig").sdl_allocator;

// optionally use the GPA
// var gpa = std.heap.GeneralPurposeAllocator(.{}){};
// pub const allocator = &gpa.allocator;

pub fn initTmpAllocator() void {
    tmp_allocator_instance = ScratchAllocator.init(allocator);
    tmp_allocator = &tmp_allocator_instance.allocator;
}

/// Compares two slices and returns whether they are equal up to the index of the smallest slice.
pub fn eqlSub(comptime T: type, base: []const T, b: []const T) bool {
    if (base.ptr == b.ptr) return true;
    for (base) |item, index| {
        if (b[index] != item) return false;
    }
    return true;
}

/// Copy all of source into dest at position 0. dest.len must be >= source.len + 1.
pub fn copyZ(comptime T: type, dest: []T, source: []const T) void {
    @setRuntimeSafety(false);
    std.debug.assert(dest.len >= source.len);
    for (source) |s, i|
        dest[i] = s;
    dest[source.len] = 0;
}