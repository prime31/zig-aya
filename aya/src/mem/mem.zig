const std = @import("std");
const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

pub const SdlBufferStream = @import("sdl_stream.zig").SdlBufferStream;

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: *std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

// default to the SDL c allocator for now
pub const allocator = @import("sdl_allocator.zig").sdl_allocator;

pub fn initTmpAllocator() void {
    tmp_allocator_instance = ScratchAllocator.init(allocator);
    tmp_allocator = &tmp_allocator_instance.allocator;
}

test "test mem" {
    const result = try tmp_allocator.alloc(u8, 50);
    std.testing.expect(std.mem.len(result) == 50);
    tmp_allocator.free(result);

    const c_file = try std.cstr.addNullByte(tmp_allocator, "normal file");
    std.testing.expect(std.mem.len(c_file) == std.mem.len("normal file"));
    tmp_allocator.free(c_file);

    const c_result = try allocator.alloc(u8, 50);
    allocator.free(c_result);
}
