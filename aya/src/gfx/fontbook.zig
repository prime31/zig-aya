const std = @import("std");
const aya = @import("../aya.zig");
const fna = @import("../deps/fna/fna.zig");
const fons = @import("../deps/fontstash/fontstash.zig");

pub const FontBook = struct {
    stash: *fons.Context,
    texture: ?aya.gfx.Texture,
    tex_filter: fna.TextureFilter,
    width: i32 = 0,
    height: i32 = 0,
    allocator: *std.mem.Allocator,

    pub const Align = fons.Align;

    pub fn init(allocator: ?*std.mem.Allocator, width: i32, height: i32, filter: fna.TextureFilter) !*FontBook {
        const alloc = allocator orelse aya.mem.allocator;
        var book = try alloc.create(FontBook);
        errdefer alloc.destroy(book);

        var params = fons.Params{
            .width = width,
            .height = height,
            .user_ptr = book,
            .renderCreate = renderCreate,
            .renderResize = renderResize,
            .renderUpdate = renderUpdate,
        };

        book.texture = null;
        book.tex_filter = filter;
        book.width = width;
        book.height = height;
        book.allocator = alloc;
        book.stash = try fons.Context.init(&params);

        return book;
    }

    pub fn deinit(self: *FontBook) void {
        self.stash.deinit();
        if (self.texture != null) self.texture.?.deinit();
        self.allocator.destroy(self);
    }

    pub fn addFont(self: *FontBook, file: []const u8) c_int {
        const c_file = std.cstr.addNullByte(aya.mem.tmp_allocator, file) catch unreachable;
        const data = aya.fs.read(self.allocator, file) catch unreachable;

        // we can let FONS free the data since we are using the c_allocator here
        return fons.fonsAddFontMem(self.stash, c_file, @ptrCast([*c]const u8, data), @intCast(i32, data.len), 1);
    }

    pub fn addFontMem(self: *FontBook, name: [:0]const u8, data: []const u8, free_data: bool) c_int {
        const free: c_int = if (free_data) 1 else 0;
        return fons.fonsAddFontMem(self.stash, name, @ptrCast([*c]const u8, data), @intCast(i32, data.len), free);
    }

    pub fn setAlign(self: *FontBook, alignment: Align) void {
        fons.fonsSetAlign(self.stash, alignment);
    }

    pub fn getTextIterator(self: *FontBook, str: []const u8) fons.TextIter {
        var iter = std.mem.zeroes(fons.TextIter);
        const res = fons.fonsTextIterInit(self.stash, &iter, 0, 0, str.ptr, @intCast(c_int, str.len));
        if (res == 0) std.debug.warn("getTextIterator failed! Make sure you have added a font.\n", .{});
        return iter;
    }

    pub fn textIterNext(self: *FontBook, iter: *fons.TextIter, quad: *fons.Quad) bool {
        return fons.fonsTextIterNext(self.stash, iter, quad) == 1;
    }

    pub fn getQuad(self: FontBook) fons.Quad {
        return std.mem.zeroes(fons.Quad);
    }

    pub fn setSize(self: FontBook, size: f32) void {
        fons.fonsSetSize(self.stash, size);
    }

    fn renderCreate(ctx: ?*c_void, width: c_int, height: c_int) callconv(.C) c_int {
        var self = @ptrCast(*FontBook, @alignCast(@alignOf(FontBook), ctx));

        if (self.texture != null and (self.texture.?.width != width or self.texture.?.height != height)) {
            self.texture.?.deinit();
            self.texture = null;
        }

        if (self.texture == null) {
            self.texture = aya.gfx.Texture.init(width, height);
            self.texture.?.setSamplerState(fna.SamplerState{ .filter = self.tex_filter });
        }

        self.width = width;
        self.height = height;

        return 1;
    }

    fn renderResize(ctx: ?*c_void, width: c_int, height: c_int) callconv(.C) c_int {
        return renderCreate(ctx, width, height);
    }

    fn renderUpdate(ctx: ?*c_void, rect: [*c]c_int, data: [*c]const u8) callconv(.C) void {
        // TODO: only update the rect that changed
        var self = @ptrCast(*FontBook, @alignCast(@alignOf(FontBook), ctx));

        const tex_area = @intCast(usize, self.width * self.height);
        var pixels = aya.mem.tmp_allocator.alloc(u8, tex_area * 4) catch |err| {
            std.debug.warn("failed to allocate texture data: {}\n", .{err});
            return;
        };
        const source = data[0..tex_area];

        for (source) |alpha, i| {
            pixels[i * 4 + 0] = 255;
            pixels[i * 4 + 1] = 255;
            pixels[i * 4 + 2] = 255;
            pixels[i * 4 + 3] = alpha;
        }

        self.texture.?.setData(pixels);
    }
};
