const std = @import("std");
const sdl = @import("sdl");
const fna = @import("fna.zig");
const win_hack = @import("win_img_load_hack.zig");

pub const ReadFunc = ?fn (?*c_void, [*c]u8, i32) callconv(.C) i32;
pub const SkipFunc = ?fn (?*c_void, i32) callconv(.C) void;
pub const EOFFunc = ?fn (?*c_void) callconv(.C) i32;
pub const WriteFunc = ?fn (?*c_void, ?*c_void, i32) callconv(.C) void;

pub extern fn FNA3D_Image_Load(readFunc: ReadFunc, skipFunc: SkipFunc, eofFunc: EOFFunc, context: ?*c_void, w: *i32, h: *i32, len: [*c]i32, forceW: i32, forceH: i32, zoom: u8) [*c]u8;
pub extern fn FNA3D_Image_Free(mem: [*c]u8) void;
pub extern fn FNA3D_Image_SavePNG(writeFunc: WriteFunc, context: ?*c_void, srcW: i32, srcH: i32, dstW: i32, dstH: i32, data: [*c]u8) void;
pub extern fn FNA3D_Image_SaveJPG(writeFunc: WriteFunc, context: ?*c_void, srcW: i32, srcH: i32, dstW: i32, dstH: i32, data: [*c]u8, quality: i32) void;

const warn = @import("std").debug.warn;

/// Loads an image file then creates a Texture with it. Caller must free the returned data with FNA3D_AddDisposeTexture.
pub fn loadTexture(device: ?*fna.Device, file: [*c]const u8, w: *i32, h: *i32) ?*fna.Texture {
    // windows poops itself compiling SDL_RWFromFile so we just avoid it and use File
    if (std.Target.current.os.tag == .windows) {
        const data = win_hack.loadTexture(device, std.mem.span(file), w, h);
        defer FNA3D_Image_Free(data.ptr);

        var texture = fna.FNA3D_CreateTexture2D(device, .color, w, h, 1, 0);
        fna.FNA3D_SetTextureData2D(device, texture, .color, 0, 0, w, h, 0, data, len);

        return texture;
    } else {
        const data = load(file, w, h);
        defer FNA3D_Image_Free(data.ptr);

        var texture = fna.FNA3D_CreateTexture2D(device, .color, w, h, 1, 0);
        fna.FNA3D_SetTextureData2D(device, texture, .color, 0, 0, w, h, 0, data, len);

        return texture;
    }
}

/// Loads an image file. Caller must free the returned data.ptr with FNA3D_Image_Free.
pub fn load(file: [*c]const u8, w: *i32, h: *i32) []u8 {
    // windows poops itself compiling SDL_RWFromFile so we just avoid it and use File
    if (std.Target.current.os.tag == .windows) {
        return win_hack.load(std.mem.span(file), w, h);
    } else {
        var rw = sdl.SDL_RWFromFile(file, "rb");
        defer std.debug.assert(sdl.SDL_RWclose(rw) == 0);

        var len: i32 = undefined;
        const data = FNA3D_Image_Load(readFunc, skipFunc, eofFunc, rw, w, h, &len, -1, -1, 0);

        return data[0..@intCast(usize, len)];
    }
}

fn readFunc(ctx: ?*c_void, data: [*c]u8, size: i32) callconv(.C) i32 {
    var rw = @ptrCast(*sdl.SDL_RWops, @alignCast(@alignOf(sdl.SDL_RWops), ctx));
    const read = sdl.SDL_RWread(rw, data, 1, @intCast(usize, size));
    return @intCast(i32, read);
}

fn skipFunc(ctx: ?*c_void, len: i32) callconv(.C) void {
    var rw = @ptrCast(*sdl.SDL_RWops, @alignCast(@alignOf(sdl.SDL_RWops), ctx));
    _ = sdl.SDL_RWseek(rw, len, sdl.RW_SEEK_CUR);
}

fn eofFunc(ctx: ?*c_void) callconv(.C) i32 {
    var rw = @ptrCast(*sdl.SDL_RWops, @alignCast(@alignOf(sdl.SDL_RWops), ctx));
    _ = sdl.SDL_RWseek(rw, 0, sdl.RW_SEEK_CUR);
    return 0;
}
