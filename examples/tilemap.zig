const std = @import("std");
const aya = @import("aya");
const Map = aya.tilemap.Map;
const MapRenderer = aya.tilemap.MapRenderer;

// var map: *Map = undefined;
var renderer: MapRenderer = undefined;
var batch: aya.gfx.AtlasBatch = undefined;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .gfx = .{
            .resolution_policy = .show_all_pixel_perfect,
        }
    });
}

fn init() void {
    var bytes = aya.fs.read(aya.mem.tmp_allocator, "assets/platformer.json") catch unreachable;
    var tokens = std.json.TokenStream.init(bytes);

    const map = Map.initFromFile("assets/platformer.json");
    defer map.deinit();

    renderer = MapRenderer.init(map, "assets");
    batch = renderer.renderTileLayerIntoAtlasBatch(map.tile_layers[0]);
}

fn update() void {}

fn render() void {
    aya.gfx.beginPass(.{});
    batch.draw();
    aya.gfx.endPass();
}
