const sdl = @import("../sdl/sdl.zig");
const fna = @import("fna.zig");
const fna_image = @import("fna_image.zig");
const std = @import("std");

pub fn load(device: ?*fna.Device, file: []const u8, w: *i32, h: *i32) []u8 {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();

    var handle = std.fs.cwd().openFile(file, .{}) catch unreachable;
    defer handle.close();

    var len: i32 = undefined;
    const data = fna_image.FNA3D_Image_Load(readFunc, skipFunc, eofFunc, @ptrCast(*c_void, &handle), w, h, &len, -1, -1, 0);

    return data[0..@intCast(usize, len)];
}

fn readFunc(ctx: ?*c_void, data: [*c]u8, size: i32) callconv(.C) i32 {
    var file = @ptrCast(*std.fs.File, @alignCast(@alignOf(std.fs.File), ctx));
    const read = file.read(data[0..@intCast(usize, size)]) catch unreachable;
    return @intCast(i32, read);
}

fn skipFunc(ctx: ?*c_void, len: i32) callconv(.C) void {
    var file = @ptrCast(*std.fs.File, @alignCast(@alignOf(std.fs.File), ctx));
    _ = file.seekBy(@intCast(i64, len)) catch unreachable;
}

fn eofFunc(ctx: ?*c_void) callconv(.C) i32 {
    var file = @ptrCast(*std.fs.File, @alignCast(@alignOf(std.fs.File), ctx));

    const pos = file.getPos() catch unreachable;
    const end_pos = file.getEndPos() catch unreachable;

    return if (pos == end_pos) 1 else 0;
}
