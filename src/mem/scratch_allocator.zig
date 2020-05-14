const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

// TODO: take in a backup_allocator and any allocation larger than our buffer gets done there. track the leaked_allocations
// and free them periodically.
pub const ScratchAllocator = struct {
    allocator: Allocator,
    // backup_allocator: *Allocator,
    end_index: usize,
    buffer: []u8,

    pub fn init(buffer: []u8) ScratchAllocator {
        return ScratchAllocator{
            .allocator = Allocator{
                .reallocFn = realloc,
                .shrinkFn = shrink,
            },
            // .backup_allocator = backup_allocator,
            .buffer = buffer,
            .end_index = 0,
        };
    }

    fn alloc(allocator: *Allocator, n: usize, alignment: u29) ![]u8 {
        const self = @fieldParentPtr(ScratchAllocator, "allocator", allocator);
        const addr = @ptrToInt(self.buffer.ptr) + self.end_index;
        const adjusted_addr = mem.alignForward(addr, alignment);
        const adjusted_index = self.end_index + (adjusted_addr - addr);
        const new_end_index = adjusted_index + n;

        if (new_end_index > self.buffer.len) {
            // irrecoverable if more memory is requested then we have in our buffer.
            if (n > self.buffer.len) return error.OutOfMemory;

            const result = self.buffer[0..new_end_index];
            self.end_index = n;
            return result;
        }
        const result = self.buffer[adjusted_index..new_end_index];
        self.end_index = new_end_index;

        return result;
    }

    fn realloc(allocator: *Allocator, old_mem: []u8, old_align: u29, new_size: usize, new_align: u29) ![]u8 {
        const self = @fieldParentPtr(ScratchAllocator, "allocator", allocator);
        std.debug.assert(old_mem.len <= self.end_index);

        // TODO: if the last allocation is being resized just extend the end_index
        if (old_mem.ptr == self.buffer.ptr + self.end_index - old_mem.len and
            mem.alignForward(@ptrToInt(old_mem.ptr), new_align) == @ptrToInt(old_mem.ptr))
        {
            const start_index = self.end_index - old_mem.len;
            const new_end_index = start_index + new_size;

            // not enough room so we reset the buffer and do an alloc
            if (new_end_index > self.buffer.len) {
                self.end_index = 0;
                return alloc(allocator, new_size, new_align);
            }

            const result = self.buffer[start_index..new_end_index];
            self.end_index = new_end_index;
            return result;
        } else if (new_size <= old_mem.len and new_align <= old_align) {
            // We can't do anything with the memory, so tell the client to keep it.
            return error.OutOfMemory;
        } else {
            const result = try alloc(allocator, new_size, new_align);
            @memcpy(result.ptr, old_mem.ptr, std.math.min(old_mem.len, result.len));
            return result;
        }
    }

    fn shrink(allocator: *Allocator, old_mem: []u8, old_align: u29, new_size: usize, new_align: u29) []u8 {
        return old_mem[0..new_size];
    }
};

test "scratch allocator tests" {
    var allocator_memory: [800000 * @sizeOf(u64)]u8 = undefined;
    var allocator_instance = ScratchAllocator.init(allocator_memory[0..]);

    var slice = try allocator_instance.allocator.alloc(*i32, 100);
    std.testing.expect(slice.len == 100);

    _ = try allocator_instance.allocator.create(i32);

    slice = try allocator_instance.allocator.realloc(slice, 20000);
    std.testing.expect(slice.len == 20000);
    allocator_instance.allocator.free(slice);
}
