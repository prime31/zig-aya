const std = @import("std");
const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

// temp allocator is a ring buffer so memory doesnt need to be freed
pub const tmp_allocator = &tmp_allocator_instance.allocator;
var tmp_allocator_instance = ScratchAllocator.init(allocator_mem[0..]);
var allocator_mem: [2 * 1024 * 1024]u8 = undefined;

// default to the c allocator for now
pub const allocator = std.heap.c_allocator;

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
