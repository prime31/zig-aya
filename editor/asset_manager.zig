const std = @import("std");
const fs = std.fs;
const aya = @import("aya");
const root = @import("main.zig");
const Atlas = @import("utils/texture_packer.zig").Atlas;

pub const AssetManager = struct {
    root_path: [:0]const u8 = "",
    thumbnail_atlas: Atlas = undefined,
    tilesets: [][:0]const u8 = &[_][:0]u8{},

    pub fn init() AssetManager {
        return .{};
    }

    pub fn deinit(self: @This()) void {
        if (self.root_path.len > 0) aya.mem.allocator.free(self.root_path);
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
        self.thumbnail_atlas = root.utils.texture_packer.packThumbnails(tex_folder, 50) catch unreachable;
    }

    fn loadTilesets(self: *@This()) void {
        const src_folder = fs.path.join(aya.mem.tmp_allocator, &[_][]const u8{ self.root_path, "tilesets" }) catch unreachable;
        const pngs = aya.fs.getAllFilesOfType(aya.mem.allocator, src_folder, ".png", true);
        defer aya.mem.allocator.free(pngs);

        self.tilesets = aya.mem.allocator.alloc([:0]u8, pngs.len) catch unreachable;
        for (pngs) |png, i| self.tilesets[i] = aya.mem.allocator.dupeZ(u8, std.fs.path.basename(png)) catch unreachable;
    }
};
