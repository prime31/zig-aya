const std = @import("std");
const aya = @import("../aya.zig");
const sdl = @import("sdl");
const io = std.io;

pub const SdlBufferStream = struct {
    rw: [*c]sdl.SDL_RWops,

    pub const ReadError = error{};
    pub const WriteError = error{};
    pub const Reader = io.Reader(*SdlBufferStream, ReadError, read);
    pub const Writer = io.Writer(*SdlBufferStream, WriteError, write);

    pub fn init(file: []const u8, mode: enum{read, write}) SdlBufferStream {
        const c_file = std.cstr.addNullByte(aya.mem.tmp_allocator, file) catch unreachable;
        var rw = sdl.SDL_RWFromFile(c_file, if (mode == .read) "rb" else "w");

        return .{ .rw = rw };
    }

    pub fn deinit(self: SdlBufferStream) void {
        _ = sdl.SDL_RWclose(self.rw);
    }

    pub fn reader(self: *SdlBufferStream) Reader {
        return .{ .context = self };
    }

    pub fn writer(self: *SdlBufferStream) Writer {
        return .{ .context = self };
    }

    pub fn read(self: *SdlBufferStream, dest: []u8) !usize {
        return sdl.SDL_RWread(self.rw, dest.ptr, 1, dest.len);
    }

    pub fn write(self: *SdlBufferStream, bytes: []const u8) !usize {
        return sdl.SDL_RWwrite(self.rw, bytes.ptr, 1, bytes.len);
    }
};

test "SdlBufferStream output" {
    aya.mem.initTmpAllocator();
    var buf = SdlBufferStream.init("/Users/desaro/Desktop/poop.txt", .write);
    const stream = buf.writer();

    try stream.print("{}{}!", .{ "Hello", "World" });
    buf.deinit();

    const written = try aya.fs.read(std.testing.allocator, "/Users/desaro/Desktop/poop.txt");
    std.testing.expectEqualSlices(u8, "HelloWorld!", written);
    std.testing.allocator.free(written);
}
