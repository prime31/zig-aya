const std = @import("std");
const sdl = @import("deps/sdl/sdl.zig");

// TODO: leaks
/// reads the contents of a file. Returned value must be freed.
pub fn read(file: []const u8) ![]u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    const allocator = &arena.allocator;

    const c_file = try std.cstr.addNullByte(allocator, file);
    var rw = sdl.SDL_RWFromFile(c_file, "rb");
    if (rw == null) return error.FileNotFound;

    const file_size = sdl.SDL_RWsize(rw);
    const bytes = try allocator.alloc(u8, @intCast(usize, file_size));
    const read_len = sdl.SDL_RWread(rw, @ptrCast(*c_void, bytes), 1, @intCast(usize, file_size));
    _ = sdl.SDL_RWclose(rw);

    return bytes;
}

test "test fs read" {
    std.testing.expectError(error.FileNotFound, read("junk.png"));
    _ = try read("assets/font.png");
}
