const std = @import("std");

// 4 MB temp allocator cleared out every frame
// TODO: make this a ring buffer so we dont even have to clear it out
pub const tmp_allocator = &tmp_allocator_instance.allocator;
var tmp_allocator_instance = std.heap.FixedBufferAllocator.init(allocator_mem[0..]);
var allocator_mem: [4 * 1024 * 1024]u8 = undefined;

// default to the c allocator for now
pub const allocator = std.heap.c_allocator;

pub fn onEndFrame() void {
    tmp_allocator_instance.reset();
}

test "test mem" {
    const result = try tmp_allocator.alloc(u8, 50);
    std.testing.expect(std.mem.len(result) == 50);
    tmp_allocator.free(result);

    const c_file = try std.cstr.addNullByte(tmp_allocator, "normal file");
    std.testing.expect(std.mem.len(c_file) == std.mem.len("normal file"));
    tmp_allocator.free(c_file);

    tmp_allocator_instance.reset();

    const c_result = try allocator.alloc(u8, 50);
    allocator.free(c_result);
}
