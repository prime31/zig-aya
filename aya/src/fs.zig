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
    return sdl.SDL_GetPrefPath(&org[0], &app[0]);
}

/// gets a path to `filename` in the save games directory
pub fn getSaveGamesFile(app: []const u8, filename: []const u8) ![]u8 {
    const dir = try std.fs.getAppDataDir(aya.mem.tmp_allocator, app);
    try std.fs.cwd().makePath(dir);
    return try std.fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ dir, filename });
}

/// saves a serializable struct to disk
pub fn savePrefs(app: []const u8, filename: []const u8, data: var) !void {
    const file = try getSaveGamesFile(app, filename);
    var buf = aya.mem.SdlBufferStream.init(file, .write);
    defer buf.deinit();

    var serializer = std.io.serializer(.Little, .Byte, buf.writer());
    try serializer.serialize(data);
}

pub fn readPrefs(comptime T: type, app: []const u8, filename: []const u8) !T {
    const file = try getSaveGamesFile(app, filename);
    var buf = aya.mem.SdlBufferStream.init(file, .read);
    defer buf.deinit();

    var deserializer = std.io.deserializer(.Little, .Byte, buf.reader());
    return deserializer.deserialize(T);
}

pub fn savePrefsJson(app: []const u8, filename: []const u8, data: var) !void {
    const file = try getSaveGamesFile(app, filename);
    var buf = aya.mem.SdlBufferStream.init(file, .write);

    try std.json.stringify(data, .{.whitespace = .{}}, buf.writer());
}

pub fn readPrefsJson(comptime T: type, app: []const u8, filename: []const u8) !T {
    const file = try getSaveGamesFile(app, filename);
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, file);
    var tokens = std.json.TokenStream.init(bytes);

    const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
    return try std.json.parse(T, &tokens, options);
}

/// for prefs loaded with `readPrefsJson` that have allocated fields, this must be called to free them
pub fn freePrefsJson(data: var) void {
    const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
    std.json.parseFree(@TypeOf(data), data, options);
}

test "test fs read" {
    aya.mem.initTmpAllocator();
    std.testing.expectError(error.FileNotFound, read(std.testing.allocator, "junk.png"));
    var bytes = try read(std.testing.allocator, "assets/font.png");
    std.testing.allocator.free(bytes);
}
