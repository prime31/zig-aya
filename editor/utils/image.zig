const std = @import("std");
const aya = @import("aya");
const stb = @import("stb");
const Texture = aya.gfx.Texture;

/// Image is a CPU side array of color data with some helper methods that can be used to prep data
/// before creating a Texture
pub const Image = struct {
    w: usize = 0,
    h: usize = 0,
    pixels: []u32,

    pub fn init(width: usize, height: usize) Image {
        return .{ .w = width, .h = height, .pixels = aya.mem.allocator.alloc(u32, width * height) catch unreachable };
    }

    pub fn initFromFile(file: []const u8) Image {
        const image_contents = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;

        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = stb.stbi_load_from_memory(image_contents.ptr, @as(c_int, @intCast(image_contents.len)), &w, &h, &channels, 4);
        if (load_res == null) unreachable;
        defer stb.stbi_image_free(load_res);

        var img = init(@as(usize, @intCast(w)), @as(usize, @intCast(h)));
        var pixels = std.mem.bytesAsSlice(u32, load_res[0..@as(usize, @intCast(w * h * channels))]);
        for (pixels, 0..) |p, i| {
            img.pixels[i] = p;
        }

        return img;
    }

    pub fn deinit(self: Image) void {
        aya.mem.allocator.free(self.pixels);
    }

    pub fn fillRect(self: *Image, rect: aya.math.RectI, color: aya.math.Color) void {
        const x = @as(usize, @intCast(rect.x));
        var y = @as(usize, @intCast(rect.y));
        const w = @as(usize, @intCast(rect.w));
        var h = @as(usize, @intCast(rect.h));

        var data = self.pixels[x + y * self.w ..];
        while (h > 0) : (h -= 1) {
            var i: usize = 0;
            while (i < w) : (i += 1) {
                data[i] = color.value;
            }

            y += 1;
            data = self.pixels[x + y * self.w ..];
        }
    }

    pub fn blit(self: *Image, src: Image, x: usize, y: usize) void {
        var yy = y;
        var h = src.h;

        var data = self.pixels[x + yy * self.w ..];
        var src_y: usize = 0;
        while (h > 0) : (h -= 1) {
            const src_row = src.pixels[src_y * src.w .. (src_y * src.w) + src.w];
            std.mem.copy(u32, data, src_row);

            // next row and move our slice to it as well
            src_y += 1;
            yy += 1;
            data = self.pixels[x + yy * self.w ..];
        }
    }

    /// resizes the Image taking the max dimension and constraining it to max_width_or_height
    pub fn resizeConstrainedToMaxSize(self: *Image, max_width_or_height: usize) void {
        const scale = @as(f32, @floatFromInt(max_width_or_height)) / @as(f32, @floatFromInt(@max(self.w, self.h)));
        self.resize(@as(usize, @intFromFloat(scale * @as(f32, @floatFromInt(self.w)))), @as(usize, @intFromFloat(scale * @as(f32, @floatFromInt(self.h)))));
    }

    /// extremely lossy image resizing, really useful only for quicky thumbnail creation
    pub fn resize(self: *Image, w: usize, h: usize) void {
        if (self.w == w and self.h == h) return;

        var img = init(w, h);
        const scale_w = @as(f32, @floatFromInt(self.w)) / @as(f32, @floatFromInt(w));
        const scale_h = @as(f32, @floatFromInt(self.h)) / @as(f32, @floatFromInt(h));

        var y: usize = 0;
        while (y < img.h) : (y += 1) {
            var x: usize = 0;
            while (x < img.w) : (x += 1) {
                const src_x = @as(usize, @intFromFloat(@as(f32, @floatFromInt(x)) * scale_w));
                const src_y = @as(usize, @intFromFloat(@as(f32, @floatFromInt(y)) * scale_h));
                img.pixels[x + y * img.w] = self.pixels[src_x + src_y * self.w];
            }
        }

        self.deinit();
        self.* = img;
    }

    pub fn asTexture(self: Image) Texture {
        return Texture.initWithData(u32, @as(i32, @intCast(self.w)), @as(i32, @intCast(self.h)), self.pixels);
    }

    pub fn save(self: Image, file: []const u8) void {
        var bytes = std.mem.sliceAsBytes(self.pixels);
        const file_posix = std.os.toPosixPath(file) catch unreachable;
        _ = stb.stbi_write_png(&file_posix, @as(c_int, @intCast(self.w)), @as(c_int, @intCast(self.h)), 4, bytes.ptr, @as(c_int, @intCast(self.w * 4)));
    }

    /// returns true if the image was loaded successfully
    pub fn getTextureSize(file: []const u8, w: *c_int, h: *c_int) bool {
        if (aya.fs.read(aya.mem.tmp_allocator, file)) |image_contents| {
            var comp: c_int = undefined;
            if (stb.stbi_info_from_memory(image_contents.ptr, @as(c_int, @intCast(image_contents.len)), w, h, &comp) == 1) {
                return true;
            }
        } else |err| {
            std.debug.print("fs.read failed: {}\n", .{err});
        }

        return false;
    }
};
