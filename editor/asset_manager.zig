const std = @import("std");
const fs = std.fs;
const aya = @import("aya");
const root = @import("main.zig");

pub const AssetManager = struct {
    root_path: [:0]const u8 = "",

    pub fn init() AssetManager {
        return .{};
    }

    pub fn deinit(self: @This()) void {
        aya.mem.allocator.free(self.root_path);
    }

    /// sets the root project path and starts a scan of the subfolders to load up the asset state
    pub fn setRootPath(self: *@This(), path: []const u8) void {
        if (self.root_path.len > 0) aya.mem.allocator.free(self.root_path);
        self.root_path = aya.mem.allocator.dupeZ(u8, path) catch unreachable;
        self.generateThumbnailAtlas();
    }

    fn generateThumbnailAtlas(self: @This()) void {
        const tex_folder = fs.path.join(aya.mem.allocator, &[_][]const u8{self.root_path, "textures"}) catch unreachable;
        defer aya.mem.allocator.free(tex_folder);
        const atlas = root.utils.texture_packer.packThumbnails(tex_folder, 50) catch unreachable;
        // const atlas = root.utils.texture_packer.pack(tex_folder) catch unreachable;
        std.debug.print("atlas: {}\n", .{atlas});
    }
};
