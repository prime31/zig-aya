const std = @import("std");
const fs = std.fs;
const aya = @import("aya");
usingnamespace @import("imgui");
const root = @import("main.zig");
const Atlas = @import("utils/texture_packer.zig").Atlas;

/// takes ownership of the Atlas passed in!
const ThumbnailAtlas = struct {
    tex: aya.gfx.Texture = undefined,
    names: [][:0]const u8,
    uvs: []Uv,

    const Uv = struct {
        tl: ImVec2,
        br: ImVec2,
    };

    pub fn init(atlas: Atlas) ThumbnailAtlas {
        var uvs = aya.mem.allocator.alloc(Uv, atlas.rects.len) catch unreachable;
        for (uvs) |*uv, i| {
            const rect = atlas.rects[i];
            uv.tl.x = @intToFloat(f32, rect.x) / @intToFloat(f32, atlas.image.w);
            uv.tl.y = @intToFloat(f32, rect.y) / @intToFloat(f32, atlas.image.h);
            uv.br.x = uv.tl.x + @intToFloat(f32, rect.w) / @intToFloat(f32, atlas.image.w);
            uv.br.y = uv.tl.y + @intToFloat(f32, rect.h) / @intToFloat(f32, atlas.image.h); 
        }

        defer aya.mem.allocator.free(atlas.rects);
        defer atlas.image.deinit();
        return .{
            .tex = aya.gfx.Texture.initWithData(u32, atlas.w, atlas.h, atlas.image.pixels), 
            .names = atlas.names,
            .uvs = uvs,
        };
    }

    pub fn deinit(self: @This()) void {
        self.tex.deinit();
        for (self.names) |name| {
            aya.mem.allocator.free(name);
        }
        aya.mem.allocator.free(self.names);
        aya.mem.allocator.free(self.uvs);
    }
};

pub const AssetManager = struct {
    root_path: [:0]const u8 = "",
    thumbnails: ThumbnailAtlas = undefined,
    tilesets: [][:0]const u8 = &[_][:0]u8{},

    pub fn init() AssetManager {
        return .{};
    }

    pub fn deinit(self: @This()) void {
        if (self.root_path.len > 0) aya.mem.allocator.free(self.root_path);
        self.thumbnails.deinit();
    }

    pub fn getUvsForThumbnailAtIndex(self: @This(), index: usize) ThumbnailAtlas.Uv {
        return self.thumbnails.uvs[index];
    }

    /// sets the root project path and starts a scan of the subfolders to load up the asset state
    pub fn setRootPath(self: *@This(), path: []const u8) void {
        if (self.root_path.len > 0) aya.mem.allocator.free(self.root_path);
        self.root_path = aya.mem.allocator.dupeZ(u8, path) catch unreachable;
        self.generateThumbnailAtlas();
        self.loadTilesets();
    }

    fn generateThumbnailAtlas(self: *@This()) void {
        const tex_folder = fs.path.join(aya.mem.allocator, &[_][]const u8{ self.root_path, "textures" }) catch unreachable;
        defer aya.mem.allocator.free(tex_folder);

        const thumb_atlas = root.utils.texture_packer.packThumbnails(tex_folder, 90) catch unreachable;
        self.thumbnails = ThumbnailAtlas.init(thumb_atlas);
    }

    fn loadTilesets(self: *@This()) void {
        const src_folder = fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ self.root_path, "tilesets" }) catch unreachable;
        const pngs = aya.fs.getAllFilesOfType(aya.mem.allocator, src_folder, ".png", true);
        defer aya.mem.allocator.free(pngs);

        self.tilesets = aya.mem.allocator.alloc([:0]u8, pngs.len) catch unreachable;
        for (pngs) |png, i| self.tilesets[i] = aya.mem.allocator.dupeZ(u8, std.fs.path.basename(png)) catch unreachable;
    }
};
