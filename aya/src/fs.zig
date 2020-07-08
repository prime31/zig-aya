const std = @import("std");
const aya = @import("aya.zig");
const sdl = aya.sdl;

/// reads the contents of a file. Returned value is owned by the caller and must be freed!
pub fn read(allocator: *std.mem.Allocator, file: []const u8) ![]u8 {
    const c_file = try std.cstr.addNullByte(aya.mem.tmp_allocator, file);
    var rw = sdl.SDL_RWFromFile(c_file, "rb");
    if (rw == null) return error.FileNotFound;

    const file_size = sdl.SDL_RWsize(rw);
    if (file_size == 0) {
        return error.ZeroSizeFile;
    }

    const bytes = try allocator.alloc(u8, @intCast(usize, file_size));
    const read_len = sdl.SDL_RWread(rw, @ptrCast(*c_void, bytes), 1, @intCast(usize, file_size));
    _ = sdl.SDL_RWclose(rw);

    return bytes;
}

pub fn write(file: []const u8, data: []u8) !void {
    const c_file = try std.cstr.addNullByte(aya.mem.tmp_allocator, file);
    var rw = sdl.SDL_RWFromFile(c_file, "w");
    _ = sdl.SDL_RWwrite(rw, data.ptr, data.len, 1);
    _ = sdl.SDL_RWclose(rw);
}

pub fn getSaveGamesDir(org: []const u8, app: []const u8) [*c]u8 {
    return sdl.SDL_GetPrefPath(org, app);
}

test "test fs read" {
    std.testing.expectError(error.FileNotFound, read(std.testing.allocator, "junk.png"));
    var bytes = try read(std.testing.allocator, "assets/font.png");
    std.testing.allocator.free(bytes);
}
