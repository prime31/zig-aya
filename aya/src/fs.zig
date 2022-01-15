const std = @import("std");
const fs = std.fs;
const aya = @import("../aya.zig");

/// reads the contents of a file. Returned value is owned by the caller and must be freed!
pub fn read(_: std.mem.Allocator, filename: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try aya.mem.allocator.alloc(u8, file_size);
    _ = try file.read(buffer);

    return buffer;
}

pub fn readZ(_: std.mem.Allocator, filename: []const u8) ![:0]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try aya.mem.allocator.alloc(u8, file_size + 1);
    _ = try file.read(buffer);
    buffer[file_size] = 0;

    return buffer[0..file_size :0];
}

pub fn write(filename: []const u8, data: []u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{ .write = true });
    defer file.close();

    // const file_size = try file.getEndPos();
    try file.writeAll(data);
}

/// gets a path to `filename` in the save games directory
pub fn getSaveGamesFile(app: []const u8, filename: []const u8) ![]u8 {
    const dir = try std.fs.getAppDataDir(aya.mem.tmp_allocator, app);
    try std.fs.cwd().makePath(dir);
    return try std.fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ dir, filename });
}

/// saves a serializable struct to disk
pub fn savePrefs(app: []const u8, filename: []const u8, data: anytype) !void {
    const file = try getSaveGamesFile(app, filename);
    var handle = try std.fs.cwd().createFile(file, .{});
    defer handle.close();

    var serializer = std.io.serializer(.Little, .Byte, handle.writer());
    try serializer.serialize(data);
}

pub fn readPrefs(comptime T: type, app: []const u8, filename: []const u8) !T {
    const file = try getSaveGamesFile(app, filename);
    var handle = try std.fs.cwd().openFile(file, .{});
    defer handle.close();

    var deserializer = std.io.deserializer(.Little, .Byte, handle.reader());
    return deserializer.deserialize(T);
}

pub fn savePrefsJson(app: []const u8, filename: []const u8, data: anytype) !void {
    const file = try getSaveGamesFile(app, filename);
    var handle = try std.fs.cwd().createFile(file, .{});
    defer handle.close();

    try std.json.stringify(data, .{ .whitespace = .{} }, handle.writer());
}

pub fn readPrefsJson(comptime T: type, app: []const u8, filename: []const u8) !T {
    const file = try getSaveGamesFile(app, filename);
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, file);
    var tokens = std.json.TokenStream.init(bytes);

    const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
    return try std.json.parse(T, &tokens, options);
}

/// for prefs loaded with `readPrefsJson` that have allocated fields, this must be called to free them
pub fn freePrefsJson(data: anytype) void {
    const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
    std.json.parseFree(@TypeOf(data), data, options);
}

/// returns a slice of all the files with extension. The caller owns the slice AND each path in the slice.
pub fn getAllFilesOfType(allocator: std.mem.Allocator, root_directory: []const u8, extension: []const u8, recurse: bool) [][]const u8 {
    var recursor = struct {
        fn search(directory: []const u8, recursive: bool, filelist: *std.ArrayList([]const u8), ext: []const u8) void {
            var dir = fs.cwd().openDir(directory, .{ .iterate = true }) catch unreachable;
            defer dir.close();

            var iter = dir.iterate();
            while (iter.next() catch unreachable) |entry| {
                if (entry.kind == .File) {
                    if (std.mem.endsWith(u8, entry.name, ext)) {
                        const abs_path = fs.path.join(filelist.allocator, &[_][]const u8{ directory, entry.name }) catch unreachable;
                        filelist.append(abs_path) catch unreachable;
                    }
                } else if (entry.kind == .Directory) {
                    const abs_path = fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ directory, entry.name }) catch unreachable;
                    search(abs_path, recursive, filelist, ext);
                }
            }
        }
    }.search;

    var list = std.ArrayList([]const u8).init(allocator);
    recursor(root_directory, recurse, &list, extension);

    return list.toOwnedSlice();
}

test "test fs read" {
    aya.mem.initTmpAllocator();
    std.testing.expectError(error.FileNotFound, read(std.testing.allocator, "junk.png"));
}
