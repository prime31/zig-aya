const std = @import("std");
const sdl = @import("../deps/sdl/sdl.zig");

pub const sdl_allocator = &sdl_allocator_state;
var sdl_allocator_state = std.mem.Allocator{
    .reallocFn = sdlRealloc,
    .shrinkFn = sdlShrink,
};

fn sdlRealloc(self: *std.mem.Allocator, old_mem: []u8, old_align: u29, new_size: usize, new_align: u29) ![]u8 {
    std.debug.assert(new_align <= @alignOf(c_longdouble));
    const old_ptr = if (old_mem.len == 0) null else @ptrCast(*c_void, old_mem.ptr);
    const buf = sdl.SDL_realloc(old_ptr, new_size) orelse return error.OutOfMemory;
    return @ptrCast([*]u8, buf)[0..new_size];
}

fn sdlShrink(self: *std.mem.Allocator, old_mem: []u8, old_align: u29, new_size: usize, new_align: u29) []u8 {
    const old_ptr = @ptrCast(*c_void, old_mem.ptr);
    const buf = sdl.SDL_realloc(old_ptr, new_size) orelse return old_mem[0..new_size];
    return @ptrCast([*]u8, buf)[0..new_size];
}

test "sdl allocator" {
    var slice = try sdl_allocator.alloc(*i32, 100);
    std.testing.expect(slice.len == 100);

    var float = try sdl_allocator.create(f32);
    float.* = 666.66;
    std.testing.expectEqual(float.*, 666.66);
    sdl_allocator.destroy(float);
}
