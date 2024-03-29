const std = @import("std");
const fs = std.fs;
const aya = @import("aya");
const math = aya.math;
const stb = @import("stb");
const Image = @import("image.zig").Image;

const Size = struct {
    width: u16,
    height: u16,
};

pub const Atlas = struct {
    names: [][:0]const u8,
    rects: []math.RectI,
    w: u16,
    h: u16,
    image: Image = undefined,

    pub fn init(frames: []stb.stbrp_rect, files: [][]const u8, size: Size) Atlas {
        std.debug.assert(frames.len == files.len);
        var res_atlas = Atlas{
            .names = aya.mem.allocator.alloc([:0]const u8, files.len) catch unreachable,
            .rects = aya.mem.allocator.alloc(math.RectI, frames.len) catch unreachable,
            .w = size.width,
            .h = size.height,
        };

        // convert to aya rects
        for (frames, 0..) |frame, i| {
            res_atlas.rects[i] = .{ .x = frame.x, .y = frame.y, .w = frame.w, .h = frame.h };
        }

        for (files, 0..) |file, i| {
            res_atlas.names[i] = aya.mem.allocator.dupeZ(u8, fs.path.basename(file)) catch unreachable;
        }

        // generate the atlas
        var image = Image.init(size.width, size.height);
        image.fillRect(.{ .w = size.width, .h = size.height }, aya.math.Color.transparent);

        for (files, 0..) |file, i| {
            var sub_image = Image.initFromFile(file);
            defer sub_image.deinit();

            // if the frame is smaller we are working with thumbnails so resize the image
            if (sub_image.w > frames[i].w or sub_image.h > frames[i].h)
                sub_image.resize(frames[i].w, frames[i].h);
            image.blit(sub_image, frames[i].x, frames[i].y);
        }

        res_atlas.image = image;
        return res_atlas;
    }

    pub fn deinit(self: Atlas) void {
        for (self.names) |name| {
            aya.mem.allocator.free(name);
        }
        aya.mem.allocator.free(self.names);
        aya.mem.allocator.free(self.rects);
        self.image.deinit();
    }

    /// saves the atlas image and a json file with the atlas details. filename should be only the name with no extension.
    pub fn save(self: Atlas, folder: []const u8, filename: []const u8) void {
        const img_filename = std.mem.concat(aya.mem.allocator, u8, &[_][]const u8{ filename, ".png" }) catch unreachable;
        const atlas_filename = std.mem.concat(aya.mem.allocator, u8, &[_][]const u8{ filename, ".json" }) catch unreachable;

        var out_file = fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ folder, img_filename }) catch unreachable;
        self.image.save(out_file);

        out_file = fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ folder, atlas_filename }) catch unreachable;
        var handle = std.fs.cwd().createFile(out_file, .{}) catch unreachable;
        defer handle.close();

        const out_stream = handle.writer();
        const options = std.json.StringifyOptions{ .whitespace = .{} };

        std.json.stringify(.{ .names = self.names, .rects = self.rects }, options, out_stream) catch unreachable;
    }
};

pub fn pack(folder: []const u8) !Atlas {
    const pngs = aya.fs.getAllFilesOfType(aya.mem.allocator, folder, ".png", true);
    const frames = getFramesForPngs(pngs);

    if (runRectPacker(frames)) |atlas_size| {
        return Atlas.init(frames, pngs, atlas_size);
    } else {
        return error.NotEnoughRoom;
    }
}

/// same as pack except this will constrain all images to some size
pub fn packThumbnails(folder: []const u8, max_width_or_height: usize) !Atlas {
    const pngs = aya.fs.getAllFilesOfType(aya.mem.allocator, folder, ".png", true);
    const frames = getFramesForPngs(pngs);

    // process the frames so they fit our constraints
    for (frames) |*frame| {
        const scale = @as(f32, @floatFromInt(max_width_or_height)) / @as(f32, @floatFromInt(@max(frame.w, frame.h)));
        if (scale < 1) {
            frame.w = @as(c_ushort, @intFromFloat(scale * @as(f32, @floatFromInt(frame.w))));
            frame.h = @as(c_ushort, @intFromFloat(scale * @as(f32, @floatFromInt(frame.h))));
        }
    }

    if (runRectPacker(frames)) |atlas_size| {
        return Atlas.init(frames, pngs, atlas_size);
    } else {
        return error.NotEnoughRoom;
    }
}

fn getFramesForPngs(pngs: [][]const u8) []stb.stbrp_rect {
    var frames = std.ArrayList(stb.stbrp_rect).init(aya.mem.allocator);
    for (pngs, 0..) |png, i| {
        // TODO: why the fuck is this memory all jacked up?
        if (std.mem.indexOfScalar(u8, png, 0) != null) @panic("------ wtf man");
        var w: c_int = undefined;
        var h: c_int = undefined;
        _ = Image.getTextureSize(png, &w, &h);
        frames.append(.{
            .id = @as(c_int, @intCast(i)),
            .w = @as(u16, @intCast(w)),
            .h = @as(u16, @intCast(h)),
        }) catch unreachable;
    }

    return frames.toOwnedSlice() catch unreachable;
}

fn runRectPacker(frames: []stb.stbrp_rect) ?Size {
    if (frames.len == 0) return Size{ .width = 0, .height = 0 };

    var ctx: stb.stbrp_context = undefined;
    // const rects_size = @sizeOf(stb.stbrp_rect) * frames.len;
    const node_count = 4096 * 2;
    var nodes: [node_count]stb.stbrp_node = undefined;

    const texture_sizes = [_][2]c_int{
        [_]c_int{ 256, 256 },   [_]c_int{ 512, 256 },   [_]c_int{ 256, 512 },
        [_]c_int{ 512, 512 },   [_]c_int{ 1024, 512 },  [_]c_int{ 512, 1024 },
        [_]c_int{ 1024, 1024 }, [_]c_int{ 2048, 1024 }, [_]c_int{ 1024, 2048 },
        [_]c_int{ 2048, 2048 }, [_]c_int{ 4096, 2048 }, [_]c_int{ 2048, 4096 },
        [_]c_int{ 4096, 4096 }, [_]c_int{ 8192, 4096 }, [_]c_int{ 4096, 8192 },
    };

    for (texture_sizes) |tex_size| {
        stb.stbrp_init_target(&ctx, tex_size[0], tex_size[1], &nodes, node_count);
        stb.stbrp_setup_heuristic(&ctx, stb.STBRP_HEURISTIC_Skyline_default);
        if (stb.stbrp_pack_rects(&ctx, frames.ptr, @as(c_int, @intCast(frames.len))) == 1) {
            return Size{ .width = @as(u16, @intCast(tex_size[0])), .height = @as(u16, @intCast(tex_size[1])) };
        }
    }

    return null;
}
