const std = @import("std");
const watcher = @import("watcher");
const ma = @import("zaudio");
const internal = @import("internal.zig");
const aya = @import("aya.zig");
const audio = aya.audio;

// const Texture = aya.render.Texture;
const Sound = aya.audio.Sound;

fn RefCounted(comptime T: type) type {
    return struct {
        obj: T,
        cnt: u8 = 1,
    };
}

const asset_path = "examples/assets";

pub const Assets = struct {
    // textures: std.StringHashMap(RefCounted(Texture)),
    // shaders: std.StringHashMap(RefCounted(ShaderInfo)),
    sounds: std.StringHashMap(RefCounted(Sound)),

    pub fn init() Assets {
        // disable hot reload if the FileWatcher is disbled
        if (watcher.enabled)
            watcher.watchPath(asset_path, onFileChanged);

        return .{
            // .textures = std.StringHashMap(RefCounted(Texture)).init(aya.mem.allocator),
            // .shaders = std.StringHashMap(RefCounted(ShaderInfo)).init(aya.mem.allocator),
            .sounds = std.StringHashMap(RefCounted(Sound)).init(aya.mem.allocator),
        };
    }

    pub fn deinit(self: *Assets) void {
        // var texture_iter = self.textures.valueIterator();
        // while (texture_iter.next()) |rc| rc.obj.deinit();
        // self.textures.deinit();

        var sound_iter = self.sounds.valueIterator();
        while (sound_iter.next()) |rc| rc.obj.src.destroy();
        self.sounds.deinit();
    }

    // // Textures
    // pub fn tryGetTexture(self: *Assets, filepath: [:0]const u8) ?Texture {
    //     if (self.textures.getPtr(filepath)) |rc| {
    //         rc.cnt += 1;
    //         return rc.obj;
    //     }
    //     return null;
    // }

    // pub fn putTexture(self: *Assets, filepath: [:0]const u8, texture: Texture) void {
    //     self.textures.put(filepath, .{ .obj = texture }) catch unreachable;
    // }

    // /// increases the ref count on the texture
    // pub fn cloneTexture(self: *Assets, texture: Texture) void {
    //     var iter = self.textures.valueIterator();
    //     while (iter.next()) |rc| {
    //         if (rc.obj.img == texture.img) {
    //             rc.cnt += 1;
    //             return;
    //         }
    //     }
    // }

    // /// returns true if the ref count reached 0 and the asset should be destroyed
    // pub fn releaseTexture(self: *Assets, tex: *const Texture) bool {
    //     var iter = self.textures.iterator();
    //     while (iter.next()) |*entry| {
    //         if (entry.value_ptr.obj.img == tex.img) {
    //             entry.value_ptr.cnt -= 1;
    //             if (entry.value_ptr.cnt == 0) {
    //                 _ = self.textures.removeByPtr(entry.key_ptr);
    //                 return true;
    //             }
    //         }
    //     }
    //     return false;
    // }

    // fn hotReloadTexture(self: *Assets, path: []const u8) void {
    //     if (self.textures.getPtr(path)) |rc| {
    //         var wh: usize = 0;
    //         const new_img = Texture.dataFromFile(path, &wh, &wh) catch unreachable;
    //         rc.obj.setData(u8, new_img);
    //     }
    // }

    // Sounds
    pub fn tryGetSound(self: *Assets, filepath: [:0]const u8) ?Sound {
        if (self.sounds.getPtr(filepath)) |rc| {
            rc.cnt += 1;
            return rc.obj;
        }
        return null;
    }

    pub fn putSound(self: *Assets, filepath: [:0]const u8, sound: Sound) void {
        self.sounds.put(filepath, .{ .obj = sound }) catch unreachable;
    }

    /// increases the ref count on the Sound
    pub fn cloneSound(self: *Assets, sound: Sound) void {
        var iter = self.sounds.valueIterator();
        while (iter.next()) |rc| {
            if (rc.obj.src == sound.src) {
                rc.cnt += 1;
                return;
            }
        }
    }

    /// returns true if the ref count reached 0 and the asset should be destroyed
    pub fn releaseSound(self: *Assets, sound: Sound) bool {
        var iter = self.sounds.iterator();
        while (iter.next()) |*entry| {
            if (entry.value_ptr.obj.src == sound.src) {
                entry.value_ptr.cnt -= 1;
                if (entry.value_ptr.cnt == 0) {
                    _ = self.sounds.removeByPtr(entry.key_ptr);
                    return true;
                }
            }
        }

        return false;
    }
};

// hot reload handler
fn onFileChanged(path: [*c]const u8) callconv(.C) void {
    const path_span = std.mem.span(path);
    if (std.mem.indexOf(u8, path_span, asset_path)) |index| {
        _ = index;
        const ext = std.fs.path.extension(path_span);
        _ = ext;
        // if (std.mem.eql(u8, ext, ".png"))
        //     internal.assets.hotReloadTexture(path_span[index..]);
    }
}
