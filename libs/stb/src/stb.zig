const std = @import("std");

pub usingnamespace @import("stb_image.zig");
pub usingnamespace @import("stb_image_write.zig");
pub usingnamespace @import("stb_rect_pack.zig");

pub const Image = struct {
    const stb = @import("stb_image.zig");

    allocator: std.mem.Allocator = undefined,
    stb_allocation: [*c]u8,
    w: u32,
    h: u32,
    channels: u32,
    bytes_per_component: u32,
    is_hdr: bool = false,

    pub fn init(path: [:0]const u8) !Image {
        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = stb.stbi_load(path.ptr, &w, &h, &channels, 4);
        if (load_res == null) return error.ImageLoadFailed;

        return .{
            .stb_allocation = load_res,
            .channels = @intCast(channels),
            .w = @intCast(w),
            .h = @intCast(h),
            .bytes_per_component = 1, // 8bit, if 16bit is added it will be 2
        };
    }

    pub fn deinit(self: Image) void {
        stb.stbi_image_free(self.stb_allocation);
    }

    pub fn getImageData(self: Image) []u8 {
        return self.stb_allocation[0..@as(usize, @intCast(self.w * self.h * self.channels))];
    }

    pub fn bytesPerRow(self: Image) u32 {
        return self.w * self.bytes_per_component * self.channels;
    }
};
