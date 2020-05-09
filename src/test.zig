const std = @import("std");
const tilemap = @import("utils/tilemap.zig");

test "tilemap" {
    var timer = try std.time.Timer.start();

    const buffer = @embedFile("../assets/platformer.json");
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
    _ = @import("main.zig");
}
