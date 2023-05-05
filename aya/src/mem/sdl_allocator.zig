const std = @import("std");
const sdl = @import("sdl");

pub const sdl_allocator = std.mem.Allocator{
    .ptr = undefined,
    .vtable = &sdlAllocator_vtable,
};

const sdlAllocator_vtable = std.mem.Allocator.VTable{
    .alloc = sdlAlloc,
    .resize = sdlResize,
    .free = sdlFree,
};

fn sdlAlloc(_: *anyopaque, len: usize, ptr_align: u8, len_align: usize) ?[*]u8 {
    std.debug.assert(ptr_align <= @alignOf(c_longdouble));
    const ptr = @ptrCast([*]u8, sdl.SDL_malloc(len));

    if (len_align == 0) {
        return ptr;
    }

    return ptr;
}

fn sdlResize(_: *anyopaque, old_mem: []u8, _: u8, new_len: usize, len_align: usize) bool {
    _ = len_align;
    if (new_len == 0) {
        sdl.SDL_free(old_mem.ptr);
        return false;
    }

    if (new_len <= old_mem.len) {
        //std.mem.alignAllocLen(old_mem.len, new_len, len_align);
        return true;
    }

    return false;
}

fn sdlFree(_: *anyopaque, buf: []u8, _: u8, _: usize) void {
    sdl.SDL_free(buf.ptr);
}

test "sdl allocator" {
    var slice = try sdl_allocator.alloc(*i32, 100);
    std.testing.expect(slice.len == 100);

    var float = try sdl_allocator.create(f32);
    float.* = 666.66;
    std.testing.expectEqual(float.*, 666.66);
    sdl_allocator.destroy(float);
}
