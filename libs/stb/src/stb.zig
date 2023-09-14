const std = @import("std");

pub usingnamespace @import("stb_image.zig");
pub usingnamespace @import("stb_image_write.zig");
pub usingnamespace @import("stb_rect_pack.zig");

pub const Image = struct {
    const stb = @import("stb_image.zig");

    allocator: std.mem.Allocator = undefined,
    stb_allocation: [*c]u8,
    channels: u32,
    w: u32,
    h: u32,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Image {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        var buffer = try allocator.alloc(u8, file_size);
        defer allocator.free(buffer);
        _ = try file.read(buffer);

        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = stb.stbi_load_from_memory(buffer.ptr, @as(c_int, @intCast(buffer.len)), &w, &h, &channels, 4);
        if (load_res == null) return error.ImageLoadFailed;

        defer stb.stbi_image_free(load_res);

        return .{
            .stb_allocation = load_res,
            .channels = @intCast(channels),
            .w = @intCast(w),
            .h = @intCast(h),
        };
    }

    pub fn getImageData(self: Image) []u8 {
        return self.stb_allocation[0..@as(usize, @intCast(self.w * self.h * self.channels))];
    }
};
