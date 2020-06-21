const std = @import("std");
const aya = @import("aya");
const Map = aya.tilemap.Map;
const MapRenderer = aya.tilemap.MapRenderer;

var map: *Map = undefined;
var renderer: MapRenderer = undefined;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() void {
    var bytes = aya.fs.read(aya.mem.tmp_allocator, "assets/platformer.json") catch unreachable;
    var tokens = std.json.TokenStream.init(bytes);

    const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
    map = std.json.parse(*Map, &tokens, options) catch unreachable;
    // defer std.json.parseFree(Map, map, options);

    std.debug.warn("image {}\n", .{map.tilesets[0].image});
    std.debug.warn("spawn {}\n", .{map.object_layers[0].getObject("spawn")});
    std.debug.warn("non-empties {}\n", .{map.tile_layers[0].totalNonEmptyTiles()});

    renderer = MapRenderer.init(map, "assets");
    std.debug.warn("renderer {}\n", .{renderer});
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{});
    renderer.render();
    aya.gfx.endPass();
}
