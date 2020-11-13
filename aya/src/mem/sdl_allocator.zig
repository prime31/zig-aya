const std = @import("std");
const sdl = @import("sdl");

pub const sdl_allocator = &sdl_allocator_state;
var sdl_allocator_state = std.mem.Allocator{
    .allocFn = sdlAlloc,
    .resizeFn = sdlResize,
};

fn sdlAlloc(allocator: *std.mem.Allocator, len: usize, ptr_align: u29, len_align: u29, ret_addr: usize) ![]u8 {
    std.debug.assert(ptr_align <= @alignOf(c_longdouble));
    const ptr = @ptrCast([*]u8, sdl.SDL_malloc(len) orelse return error.OutOfMemory);

    if (len_align == 0) {
        return ptr[0..len];
    }

    return ptr[0..std.mem.alignBackwardAnyAlign(len, len_align)];
}

fn sdlResize(self: *std.mem.Allocator, old_mem: []u8, buf_align: u29, new_len: usize, len_align: u29, ret_addr: usize) std.mem.Allocator.Error!usize {
    if (new_len == 0) {
        sdl.SDL_free(old_mem.ptr);
        return 0;
    }

    if (new_len <= old_mem.len) {
        _ = sdl.SDL_realloc(old_mem.ptr, new_len) orelse return error.OutOfMemory;
        return std.mem.alignAllocLen(old_mem.len, new_len, len_align);
    }

    return error.OutOfMemory;
}

test "sdl allocator" {
    var slice = try sdl_allocator.alloc(*i32, 100);
    std.testing.expect(slice.len == 100);

    var float = try sdl_allocator.create(f32);
    float.* = 666.66;
    std.testing.expectEqual(float.*, 666.66);
    sdl_allocator.destroy(float);
}