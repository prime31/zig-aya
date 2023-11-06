const std = @import("std");
const watcher = @import("watcher");
const aya = @import("aya.zig");
const rk = aya.rk;

const Texture = aya.render.Texture;

fn RefCounted(comptime T: type) type {
    return struct {
        obj: T,
        cnt: u8 = 1,
    };
}

const asset_path = "examples/assets";

pub const Assets = struct {
    textures: std.StringHashMap(RefCounted(Texture)),

    pub fn init() Assets {
        watcher.watchPath(asset_path, onFileChanged);
        return .{
            .textures = std.StringHashMap(RefCounted(Texture)).init(aya.mem.allocator),
        };
    }

    pub fn deinit(self: *Assets) void {
        self.textures.deinit();
    }

    // Textures
    pub fn loadTexture(self: *Assets, file: []const u8, filter: rk.TextureFilter) Texture {
        if (self.textures.getPtr(file)) |rc| {
            rc.cnt += 1;
            return rc.obj;
        }

        const texture = Texture.initFromFile(file, filter);
        self.textures.put(file, .{ .obj = texture }) catch unreachable;
        return texture;
    }

    pub fn releaseTexture(self: *Assets, tex: Texture) void {
        var iter = self.textures.iterator();
        while (iter.next()) |*entry| {
            if (entry.value_ptr.obj.img == tex.img) {
                entry.value_ptr.cnt -= 1;
                if (entry.value_ptr.cnt == 0)
                    _ = self.textures.removeByPtr(entry.key_ptr);
                return;
            }
        }
    }

    fn hotReloadTexture(self: *Assets, path: []const u8) void {
        if (self.textures.getPtr(path)) |rc| {
            var wh: usize = 0;
            const new_img = Texture.dataFromFile(path, &wh, &wh) catch unreachable;
            rc.obj.setData(u8, new_img);
        }
    }

    fn onFileChanged(path: [*c]const u8) callconv(.C) void {
        const path_span = std.mem.span(path);
        if (std.mem.indexOf(u8, path_span, asset_path)) |index| {
            const ext = std.fs.path.extension(path_span);
            if (std.mem.eql(u8, ext, ".png"))
                aya.assets.hotReloadTexture(path_span[index..]);
        }
    }
};
