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

pub const Assets = struct {
    textures: std.StringHashMap(RefCounted(Texture)),

    pub fn init() Assets {
        watcher.watchPath("examples/assets", onFileChanged);
        return .{
            .textures = std.StringHashMap(RefCounted(Texture)).init(aya.mem.allocator),
        };
    }

    pub fn deinit(self: *Assets) void {
        self.textures.deinit();
    }

    pub fn loadTexture(self: *Assets, file: []const u8, filter: rk.TextureFilter) Texture {
        if (self.textures.getPtr(file)) |rc| {
            rc.cnt += 1;
            std.debug.print("--- fuck me man\n", .{});
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

    fn onFileChanged(path: [*c]const u8) callconv(.C) void {
        std.debug.print("hot reload me: {s}\n", .{path});
    }
};
