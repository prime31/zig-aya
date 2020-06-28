const std = @import("std");
const sdl = @import("../deps/sdl/sdl.zig");

pub const sdl_allocator = &sdl_allocator_state;
var sdl_allocator_state = std.mem.Allocator{
    .allocFn = sdlRealloc,
    .resizeFn = sdlResize,
};

fn sdlRealloc(allocator: *std.mem.Allocator, n: usize, ptr_align: u29, len_align: u29) ![]u8 {
    std.debug.assert(ptr_align <= @alignOf(c_longdouble));
    const buf = sdl.SDL_malloc(n) orelse return error.OutOfMemory;
    return @ptrCast([*]u8, buf)[0..n];
}

fn sdlResize(allocator: *std.mem.Allocator, old_mem: []u8, new_len: usize, len_align: u29) std.mem.Allocator.Error!usize {
    const old_ptr = @ptrCast(*c_void, old_mem.ptr);
    const buf = sdl.SDL_realloc(old_ptr, new_len) orelse return old_mem.len;
    // return @ptrCast([*]u8, buf)[0..new_size];
    return new_len;
}

// fn sdlResize(allocator: *std.mem.Allocator, old_mem: []u8, old_align: u29, new_size: usize, new_align: u29) []u8 {
//     const old_ptr = @ptrCast(*c_void, old_mem.ptr);
//     const buf = sdl.SDL_realloc(old_ptr, new_size) orelse return old_mem[0..new_size];
//     return @ptrCast([*]u8, buf)[0..new_size];
// }

test "sdl allocator" {
    var slice = try sdl_allocator.alloc(*i32, 100);
    std.testing.expect(slice.len == 100);

    var float = try sdl_allocator.create(f32);
    float.* = 666.66;
    std.testing.expectEqual(float.*, 666.66);
    sdl_allocator.destroy(float);
}
