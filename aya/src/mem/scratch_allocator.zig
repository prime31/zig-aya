const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

pub const ScratchAllocator = struct {
    backup_allocator: Allocator,
    end_index: usize,
    buffer: []u8,

    pub fn init(backing_allocator: Allocator) ScratchAllocator {
        const scratch_buffer = backing_allocator.alloc(u8, 2 * 1024 * 1024) catch unreachable;

        return ScratchAllocator{
            .backup_allocator = backing_allocator,
            .buffer = scratch_buffer,
            .end_index = 0,
        };
    }

    pub fn allocator(self: *ScratchAllocator) Allocator {
        return Allocator.init(self, alloc, Allocator.NoResize(ScratchAllocator).noResize, Allocator.NoOpFree(ScratchAllocator).noOpFree);
    }

    fn alloc(self: *ScratchAllocator, n: usize, ptr_align: u29, _: u29, _: usize) std.mem.Allocator.Error![]u8 {
        const addr = @ptrToInt(self.buffer.ptr) + self.end_index;
        const adjusted_addr = mem.alignForward(addr, ptr_align);
        const adjusted_index = self.end_index + (adjusted_addr - addr);
        const new_end_index = adjusted_index + n;

        if (new_end_index > self.buffer.len) {
            // if more memory is requested then we have in our buffer leak like a sieve!
            if (n > self.buffer.len) {
                std.debug.print("\n---------\nwarning: tmp allocated more than is in our temp allocator. This memory WILL leak!\n--------\n", .{});
                // return self.backup_allocator.alloc(allocator, n, ptr_align, len_align, ret_addr);
                return std.mem.Allocator.Error.OutOfMemory;
            }

            const result = self.buffer[0..n];
            self.end_index = n;
            return result;
        }
        const result = self.buffer[adjusted_index..new_end_index];
        self.end_index = new_end_index;

        return result;
    }
};

test "scratch allocator" {
    var allocator_instance = ScratchAllocator.init(@import("mem.zig").allocator);

    var slice = try allocator_instance.allocator.alloc(*i32, 100);
    std.testing.expect(slice.len == 100);

    _ = try allocator_instance.allocator.create(i32);

    slice = try allocator_instance.allocator.realloc(slice, 20000);
    std.testing.expect(slice.len == 20000);
    allocator_instance.allocator.free(slice);
}
