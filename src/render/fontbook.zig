const std = @import("std");
const aya = @import("../aya.zig");
const wgpu = aya.wgpu;
const fons = @import("fontstash");

// TODO: https://github.com/Beyley/ztyping/blob/master/game/fontstash_impl.zig
pub const FontBook = struct {
    pub const Quad = fons.Quad;

    stash: *fons.Context,
    texture: aya.render.TextureHandle,
    width: i32 = 0,
    height: i32 = 0,
    tex_dirty: bool = false,
    last_update: u32 = 0,

    pub const Align = fons.Align;

    pub fn init(width: i32, height: i32) *FontBook {
        var book = aya.mem.create(FontBook);

        var params = fons.Params{
            .width = width,
            .height = height,
            .flags = fons.Flags.top_left,
            .user_ptr = book,
            .renderCreate = renderCreate,
            .renderResize = renderResize,
            .renderUpdate = renderUpdate,
        };

        book.texture = aya.render.TextureHandle.nil;
        book.width = width;
        book.height = height;
        book.stash = fons.Context.init(&params) catch unreachable;

        fons.fonsSetErrorCallback(book.stash, errorCallback, book);

        return book;
    }

    pub fn deinit(self: *FontBook) void {
        self.stash.deinit();
        if (self.texture.id != aya.render.TextureHandle.nil.id) {
            aya.gctx.releaseResource(self.texture);
        }
        aya.mem.destroy(self);
    }

    // add fonts
    pub fn addFont(self: *FontBook, path: []const u8) c_int {
        const c_file = aya.mem.tmp_allocator.dupeZ(u8, path) catch unreachable;

        const file = std.fs.cwd().openFile(path, .{}) catch unreachable;
        defer file.close();

        const file_size = file.getEndPos() catch unreachable;
        const buffer = std.heap.c_allocator.alloc(u8, file_size) catch unreachable;
        _ = file.read(buffer) catch unreachable;

        // we can let FONS free the data since we are using the c_allocator here
        return fons.fonsAddFontMem(self.stash, c_file, @as([*c]const u8, @ptrCast(buffer)), @as(i32, @intCast(buffer.len)), 1);
    }

    pub fn addFontMem(self: *FontBook, name: [:0]const u8, data: []const u8, free_data: bool) c_int {
        const free: c_int = if (free_data) 1 else 0;
        return fons.fonsAddFontMem(self.stash, name, @as([*c]const u8, @ptrCast(data)), @as(i32, @intCast(data.len)), free);
    }

    // state setting
    pub fn setAlign(self: *FontBook, alignment: Align) void {
        fons.fonsSetAlign(self.stash, alignment);
    }

    pub fn setSize(self: FontBook, size: f32) void {
        fons.fonsSetSize(self.stash, size);
    }

    pub fn setColor(self: FontBook, color: aya.math.Color) void {
        fons.fonsSetColor(self.stash, color.value);
    }

    pub fn setSpacing(self: FontBook, spacing: f32) void {
        fons.fonsSetSpacing(self.stash, spacing);
    }

    pub fn setBlur(self: FontBook, blur: f32) void {
        fons.fonsSetBlur(self.stash, blur);
    }

    pub fn setFont(self: FontBook, font: c_int) void {
        fons.fonsSetFont(self.stash, font);
    }

    // state handling
    pub fn pushState(self: *FontBook) void {
        fons.fonsPushState(self.stash);
    }

    pub fn popState(self: *FontBook) void {
        fons.fonsPopState(self.stash);
    }

    pub fn clearState(self: *FontBook) void {
        fons.fonsClearState(self.stash);
    }

    // measure text
    pub fn getTextBounds(self: *FontBook, x: f32, y: f32, str: []const u8) struct { width: f32, bounds: f32 } {
        var bounds: f32 = undefined;
        const width = fons.fonsTextBounds(self.stash, x, y, str.ptr, null, &bounds);
        return .{ .width = width, .bounds = bounds };
    }

    pub fn getLineBounds(self: *FontBook, y: f32) struct { min_y: f32, max_y: f32 } {
        var min_y: f32 = undefined;
        var max_y: f32 = undefined;
        fons.fonsLineBounds(self.stash, y, &min_y, &max_y);
        return .{ .min_y = min_y, .max_y = max_y };
    }

    pub fn getVertMetrics(self: *FontBook) struct { ascender: f32, descender: f32, line_h: f32 } {
        var ascender: f32 = undefined;
        var descender: f32 = undefined;
        var line_h: f32 = undefined;
        fons.fonsVertMetrics(self.stash, &ascender, &descender, &line_h);
        return .{ .ascender = ascender, .descender = descender, .line_h = line_h };
    }

    // text iter
    pub fn getTextIterator(self: *FontBook, str: []const u8) fons.TextIter {
        var iter = std.mem.zeroes(fons.TextIter);
        const res = fons.fonsTextIterInit(self.stash, &iter, 0, 0, str.ptr, @as(c_int, @intCast(str.len)));
        if (res == 0) std.debug.print("getTextIterator failed! Make sure you have added a font.\n", .{});
        return iter;
    }

    pub fn textIterNext(self: *FontBook, iter: *fons.TextIter, quad: *fons.Quad) bool {
        return fons.fonsTextIterNext(self.stash, iter, quad) == 1;
    }

    fn errorCallback(_: ?*anyopaque, err: c_int, value: c_int) callconv(.C) void {
        std.debug.print("FontStash error: {}, value: {}\n", .{ err, value });
    }

    fn renderCreate(ctx: ?*anyopaque, width: c_int, height: c_int) callconv(.C) c_int {
        var self = @as(*FontBook, @ptrCast(@alignCast(ctx)));

        const tex_info = aya.gctx.lookupResourceInfo(self.texture);
        if (self.texture.id != aya.render.TextureHandle.nil.id and (tex_info.?.size.width != @as(u32, @intCast(width)) or tex_info.?.size.height != @as(u32, @intCast(height)))) {
            aya.gctx.releaseResource(self.texture);
            self.texture = aya.render.TextureHandle.nil;
        }

        if (self.texture.id == aya.render.TextureHandle.nil.id) {
            self.texture = aya.gctx.createTexture(@intCast(width), @intCast(height), aya.render.GraphicsContext.swapchain_format);
        }

        self.width = width;
        self.height = height;

        return 1;
    }

    fn renderResize(ctx: ?*anyopaque, width: c_int, height: c_int) callconv(.C) c_int {
        return renderCreate(ctx, width, height);
    }

    fn renderUpdate(ctx: ?*anyopaque, rect: [*c]c_int, data: [*c]const u8) callconv(.C) c_int {
        var self = @as(*FontBook, @ptrCast(@alignCast(ctx)));
        if (!self.tex_dirty or self.last_update == aya.time.frames()) {
            self.tex_dirty = true;
            return 0;
        }

        const rect_x: usize = @intCast(rect[0]);
        const rect_y: usize = @intCast(rect[1]);
        const rect_w: usize = @intCast(rect[2]);
        const rect_h: usize = @intCast(rect[3]);

        var pixel_rect = aya.mem.tmp_allocator.alloc(u8, @intCast(rect_w * rect_h * 4)) catch unreachable;
        const tex_width = aya.gctx.lookupResourceInfo(self.texture).?.size.width;

        for (0..rect_h) |y| {
            for (0..rect_w) |x| {
                const i = y * rect_w + x;
                pixel_rect[i * 4 + 0] = 255;
                pixel_rect[i * 4 + 1] = 255;
                pixel_rect[i * 4 + 2] = 255;
                pixel_rect[i * 4 + 3] = data[(rect_y + y) * tex_width + x + rect_x];
            }
        }

        const texture_info = aya.gctx.lookupResourceInfo(self.texture).?;
        aya.gctx.queue.writeTexture(
            &.{ .texture = texture_info.gpuobj.?, .origin = .{ .x = @intCast(rect_x), .y = @intCast(rect_y) } },
            @as(*const anyopaque, @ptrCast(pixel_rect.ptr)),
            @as(usize, @intCast(pixel_rect.len)) * @sizeOf(u8),
            &.{
                .bytes_per_row = @intCast(rect_w * 4),
                .rows_per_image = texture_info.size.height,
            },
            &.{ .width = @intCast(rect_w), .height = @intCast(rect_h) },
        );

        self.tex_dirty = false;
        self.last_update = aya.time.frames();
        return 1;
    }
};
