const sdl = @cImport(@cInclude("SDL2/SDL.h"));
const fna = @import("fna.zig");
const std = @import("std");

pub const ReadFunc = ?fn (?*c_void, [*c]u8, i32) callconv(.C) i32;
pub const SkipFunc = ?fn (?*c_void, i32) callconv(.C) void;
pub const EOFFunc = ?fn (?*c_void) callconv(.C) i32;
pub const WriteFunc = ?fn (?*c_void, ?*c_void, i32) callconv(.C) void;

pub extern fn FNA3D_Image_Load(readFunc: ReadFunc, skipFunc: SkipFunc, eofFunc: EOFFunc, context: ?*c_void, w: [*c]i32, h: [*c]i32, len: [*c]i32, forceW: i32, forceH: i32, zoom: u8) [*c]u8;
pub extern fn FNA3D_Image_Free(mem: [*c]u8) void;
pub extern fn FNA3D_Image_SavePNG(writeFunc: WriteFunc, context: ?*c_void, srcW: i32, srcH: i32, dstW: i32, dstH: i32, data: [*c]u8) void;
pub extern fn FNA3D_Image_SaveJPG(writeFunc: WriteFunc, context: ?*c_void, srcW: i32, srcH: i32, dstW: i32, dstH: i32, data: [*c]u8, quality: i32) void;

const warn = @import("std").debug.warn;

pub fn load(device: ?*fna.Device, file: [*c]const u8) ?*fna.Texture {
    var rw = sdl.SDL_RWFromFile(file, "rb");
    defer std.debug.assert(sdl.SDL_RWclose(rw) == 0);

    var w: i32 = undefined;
    var h: i32 = undefined;
    var len: i32 = undefined;
    const data = FNA3D_Image_Load(readFunc, skipFunc, eofFunc, rw, &w, &h, &len, -1, -1, 0);
    defer FNA3D_Image_Free(data);

    var texture = fna.FNA3D_CreateTexture2D(device, .color, w, h, 1, 0);
    fna.FNA3D_SetTextureData2D(device, texture, .color, 0, 0, w, h, 0, data, len);

    warn("data: {}, size: {},{}, len: {}, tex: {}\n", .{ data, w, h, len, texture });
    return texture;
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
    std.debug.warn("---- eof\n", .{});
    return 0;
}
