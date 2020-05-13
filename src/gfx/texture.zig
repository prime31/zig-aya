const std = @import("std");
const fna = @import("../deps/fna/fna.zig");
// const aya = @import("../aya.zig");
// const fs = aya.fs;
// const gfx = aya.gfx;

pub const Texture = extern struct {
    tex: ?*fna.Texture = null,
    width: i32 = 0,
    height: i32 = 0,

    pub fn initFromFile(file: []const u8) !Texture {
        var texture = Texture{
            .tex = fna.img.load(device, file),
        };
        std.debug.warn("loaded tex: {}\n", .{tex});

        return texture;
    }

    pub fn deinit(self: Texture) void {
        fna.FNA3D_AddDisposeTexture(gfx.device, self.tex);
    }
};

test "test texture" {
    _ = try Texture.initFromFile("assets/font.png");
}
