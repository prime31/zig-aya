const std = @import("std");
const aya = @import("../aya.zig");

const ScratchAllocator = @import("scratch_allocator.zig").ScratchAllocator;

// temp allocator is a ring buffer so memory doesnt need to be freed
var tmp_allocator_instance: ScratchAllocator = undefined;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub const Mem = struct {
    allocator: std.mem.Allocator,
    tmp_allocator: std.mem.Allocator,

    pub fn init() Mem {
        const allocator = gpa.allocator();
        tmp_allocator_instance = ScratchAllocator.init(allocator);

        return .{
            .allocator = allocator,
            .tmp_allocator = tmp_allocator_instance.allocator(),
        };
    }

    pub fn deinit(_: Mem) void {
        tmp_allocator_instance.deinit();
        _ = gpa.deinit();
    }

    pub fn create(self: Mem, comptime T: type) *T {
        return self.allocator.create(T) catch unreachable;
    }

    pub fn destroy(self: Mem, ptr: anytype) void {
        self.allocator.destroy(ptr);
    }

    pub fn alloc(self: Mem, comptime T: type, n: usize) []T {
        return self.allocator.alloc(T, n) catch unreachable;
    }

    pub fn free(self: Mem, memory: anytype) void {
        self.allocator.free(memory);
    }
};
