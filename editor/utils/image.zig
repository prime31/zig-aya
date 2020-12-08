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
        const load_res = stb.stbi_load_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &channels, 4);
        if (load_res == null) unreachable;
        defer stb.stbi_image_free(load_res);

        var img = init(@intCast(usize, w), @intCast(usize, h));
        var pixels = std.mem.bytesAsSlice(u32, load_res[0..@intCast(usize, w * h * channels)]);
        for (pixels) |p, i| {
            img.pixels[i] = p;
        }

        return img;
    }

    pub fn deinit(self: Image) void {
        aya.mem.allocator.free(self.pixels);
    }

    pub fn fillRect(self: *Image, rect: aya.math.RectI, color: aya.math.Color) void {
        const x = @intCast(usize, rect.x);
        var y = @intCast(usize, rect.y);
        const w = @intCast(usize, rect.w);
        var h = @intCast(usize, rect.h);

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
        const scale = @intToFloat(f32, max_width_or_height) / @intToFloat(f32, std.math.max(self.w, self.h));
        self.resize(@floatToInt(usize, scale * @intToFloat(f32, self.w)), @floatToInt(usize, scale * @intToFloat(f32, self.h)));
    }

    /// extremely lossy image resizing, really useful only for quicky thumbnail creation
    pub fn resize(self: *Image, w: usize, h: usize) void {
        if (self.w == w and self.h == h) return;

        var img = init(w, h);
        const scale_w = @intToFloat(f32, self.w) / @intToFloat(f32, w);
        const scale_h = @intToFloat(f32, self.h) / @intToFloat(f32, h);

        var y: usize = 0;
        while (y < img.h) : (y += 1) {
            var x: usize = 0;
            while (x < img.w) : (x += 1) {
                const src_x = @floatToInt(usize, @intToFloat(f32, x) * scale_w);
                const src_y = @floatToInt(usize, @intToFloat(f32, y) * scale_h);
                img.pixels[x + y * img.w] = self.pixels[src_x + src_y * self.w];
            }
        }

        self.deinit();
        self.* = img;
    }

    pub fn asTexture(self: Image) Texture {
        return Texture.initWithData(u32, @intCast(i32, self.w), @intCast(i32, self.h), self.pixels);
    }

    pub fn save(self: Image, file: []const u8) void {
        var bytes = std.mem.sliceAsBytes(self.pixels);
        const file_posix = std.os.toPosixPath(file) catch unreachable;
        _ = stb.stbi_write_png(&file_posix, @intCast(c_int, self.w), @intCast(c_int, self.h), 4, bytes.ptr, @intCast(c_int, self.w * 4));
    }

    /// returns true if the image was loaded successfully
    pub fn getTextureSize(file: []const u8, w: *c_int, h: *c_int) bool {
        if (aya.fs.read(aya.mem.tmp_allocator, file)) |image_contents| {
            var comp: c_int = undefined;
            if (stb.stbi_info_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), w, h, &comp) == 1) {
                return true;
            }
        } else |err| {
            std.debug.print("fs.read failed: {}\n", .{err});
        }

        return false;
    }
};
