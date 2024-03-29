const std = @import("std");
const aya = @import("../../aya.zig");
const stb_image = @import("stb");
const renderkit = @import("renderkit");
const fs = aya.fs;

pub const Texture = struct {
    img: renderkit.Image,
    width: f32 = 0,
    height: f32 = 0,

    pub fn init(width: i32, height: i32) Texture {
        return initWithOptions(width, height, .nearest, .clamp);
    }

    pub fn initWithOptions(width: i32, height: i32, filter: renderkit.TextureFilter, wrap: renderkit.TextureWrap) Texture {
        return initWithDataOptions(u8, width, height, &[_]u8{}, filter, wrap);
    }

    pub fn initDynamic(width: i32, height: i32, filter: renderkit.TextureFilter, wrap: renderkit.TextureWrap) Texture {
        const img = renderkit.createImage(.{
            .width = width,
            .height = height,
            .usage = .dynamic,
            .min_filter = filter,
            .mag_filter = filter,
            .wrap_u = wrap,
            .wrap_v = wrap,
            .content = null,
        });
        return .{
            .img = img,
            .width = @as(f32, @floatFromInt(width)),
            .height = @as(f32, @floatFromInt(height)),
        };
    }

    pub fn initFromFile(file: []const u8, filter: renderkit.TextureFilter) !Texture {
        const image_contents = try fs.read(aya.mem.tmp_allocator, file);

        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = stb_image.stbi_load_from_memory(image_contents.ptr, @as(c_int, @intCast(image_contents.len)), &w, &h, &channels, 4);
        if (load_res == null) return error.ImageLoadFailed;
        defer stb_image.stbi_image_free(load_res);

        return initWithDataOptions(u8, w, h, load_res[0..@as(usize, @intCast(w * h * channels))], filter, .clamp);
    }

    pub fn initWithData(comptime T: type, width: i32, height: i32, pixels: []T) Texture {
        return initWithDataOptions(T, width, height, pixels, .nearest, .clamp);
    }

    pub fn initWithDataOptions(comptime T: type, width: i32, height: i32, pixels: []T, filter: renderkit.TextureFilter, wrap: renderkit.TextureWrap) Texture {
        const img = renderkit.createImage(.{
            .width = width,
            .height = height,
            .min_filter = filter,
            .mag_filter = filter,
            .wrap_u = wrap,
            .wrap_v = wrap,
            .content = std.mem.sliceAsBytes(pixels).ptr,
        });
        return .{
            .img = img,
            .width = @as(f32, @floatFromInt(width)),
            .height = @as(f32, @floatFromInt(height)),
        };
    }

    pub fn initCheckerTexture(comptime scale: usize) Texture {
        const colors = [_]u32{
            0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
            0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
            0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
            0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF,
        };

        var pixels: [4 * scale * 4 * scale]u32 = undefined;
        var y: usize = 0;
        while (y < 4 * scale) : (y += 1) {
            var x: usize = 0;
            while (x < 4 * scale) : (x += 1) {
                pixels[y + x * 4 * scale] = colors[@mod(x / scale, 4) + @mod(y / scale, 4) * 4];
            }
        }

        return initWithData(u32, 4 * @as(i32, @intCast(scale)), 4 * @as(i32, @intCast(scale)), &pixels);
    }

    pub fn initSingleColor(color: u32) Texture {
        var pixels: [16]u32 = undefined;
        @memset(&pixels, color);
        return initWithData(u32, 4, 4, pixels[0..]);
    }

    pub fn initOffscreen(width: i32, height: i32, filter: renderkit.TextureFilter, wrap: renderkit.TextureWrap) Texture {
        const img = renderkit.createImage(.{
            .render_target = true,
            .width = width,
            .height = height,
            .min_filter = filter,
            .mag_filter = filter,
            .wrap_u = wrap,
            .wrap_v = wrap,
        });
        return .{
            .img = img,
            .width = @as(f32, @floatFromInt(width)),
            .height = @as(f32, @floatFromInt(height)),
        };
    }

    pub fn initStencil(width: i32, height: i32, filter: renderkit.TextureFilter, wrap: renderkit.TextureWrap) Texture {
        const img = renderkit.createImage(.{
            .render_target = true,
            .pixel_format = .stencil,
            .width = width,
            .height = height,
            .min_filter = filter,
            .mag_filter = filter,
            .wrap_u = wrap,
            .wrap_v = wrap,
        });
        return .{
            .img = img,
            .width = @as(f32, @floatFromInt(width)),
            .height = @as(f32, @floatFromInt(height)),
        };
    }

    /// loads an image file and returns the raw data. The data returned must be freed with stb.stbi_image_free.
    pub fn dataFromFile(file: []const u8, width: *usize, height: *usize) ![]u8 {
        const image_contents = try aya.fs.read(aya.mem.tmp_allocator, file);

        var w: c_int = undefined;
        var h: c_int = undefined;
        var channels: c_int = undefined;
        const load_res = stb_image.stbi_load_from_memory(image_contents.ptr, @as(c_int, @intCast(image_contents.len)), &w, &h, &channels, 4);
        if (load_res == null) return error.ImageLoadFailed;

        width.* = @as(usize, @intCast(w));
        height.* = @as(usize, @intCast(h));
        return load_res[0 .. width.* * height.* * 4];
    }

    /// returns true if the image was loaded successfully
    pub fn getTextureSize(file: []const u8, w: *c_int, h: *c_int) bool {
        const image_contents = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;
        var comp: c_int = undefined;
        if (stb_image.stbi_info_from_memory(image_contents.ptr, @as(c_int, @intCast(image_contents.len)), w, h, &comp) == 1) {
            return true;
        }

        return false;
    }

    pub fn deinit(self: *const Texture) void {
        renderkit.destroyImage(self.img);
    }

    pub fn setData(self: *Texture, comptime T: type, data: []T) void {
        renderkit.updateImage(T, self.img, data);
    }

    pub fn resize(self: *Texture, width: i32, height: i32) void {
        self.deinit();
        self.* = Texture.init(width, height);
        std.debug.print("----- TODO: recreate render textures correctly with depth/stencil\n", .{});
    }

    /// if openGL, returns the tid else returns the Image as a ptr
    pub fn imTextureID(self: Texture) *anyopaque {
        return @as(*anyopaque, @ptrFromInt(renderkit.getNativeTid(self.img)));
    }
};
