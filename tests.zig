const std = @import("std");
const tilemap = @import("src/utils/tilemap.zig");

test "tilemap" {
    var timer = try std.time.Timer.start();

    const buffer = @embedFile("assets/platformer.json");
    var tokens = std.json.TokenStream.init(buffer);

    const options = std.json.ParseOptions{ .allocator = std.testing.allocator };
    var map = try std.json.parse(tilemap.Map, &tokens, options);
    defer std.json.parseFree(@TypeOf(map), map, options);

    const laptime = timer.lap();
    std.debug.warn("map: {}\n", .{laptime / 1000});

    const tileset = map.tilesets[0];
    std.debug.assert(tileset.tiles[0].props[1].v.float == 3.4);
    std.debug.assert(tileset.tiles[0].props[2].v.int == 4);
}

// include all files with tests
comptime {
    _ = @import("src/main.zig");

    _ = @import("src/fs.zig");
    _ = @import("src/input.zig");

    _ = @import("src/math/vec2.zig");
    // _ = @import("src/math/color.zig"); // Zig bug: TODO buf_read_value_bytes union type
    _ = @import("src/math/mat32.zig");

    _ = @import("src/gfx/gfx.zig");
    _ = @import("src/gfx/shader.zig");
    // _ = @import("src/gfx/textures.zig"); // requires firing up a Window
    _ = @import("src/gfx/buffers.zig");
}
