const std = @import("std");
const aya = @import("aya");
const sokol = @import("sokol");
const Map = aya.tilemap.Map;

var map: *Map = undefined;
var texture: aya.gfx.Texture = undefined;
var batch: aya.gfx.AtlasBatch = undefined;
var player: aya.math.RectI = undefined;
var speed: f32 = 1.0;

pub fn main() anyerror!void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .gfx = .{
            .resolution_policy = .show_all_pixel_perfect,
            .design_width = 640,
            .design_height = 480,
        },
    });
}

fn init() !void {
    map = Map.initFromFile("examples/assets/platformer.json");
    texture = map.loadTexture("examples/assets", .nearest);
    batch = aya.tilemap.renderer.renderTileLayerIntoAtlasBatch(map, map.tile_layers[0], texture);

    const spawn = map.object_layers[0].getObject("spawn");
    player = aya.math.RectI{ .x = @as(i32, @intFromFloat(spawn.x)), .y = @as(i32, @intFromFloat(spawn.y)), .w = @as(i32, @intFromFloat(spawn.w)), .h = @as(i32, @intFromFloat(spawn.h)) };
}

fn update() !void {
    var move = aya.math.Vec2{};

    if (aya.input.keyDown(.right)) {
        move.x += speed;
    } else if (aya.input.keyDown(.left)) {
        move.x -= speed;
    }

    if (aya.input.keyDown(.up)) {
        move.y -= speed;
    } else if (aya.input.keyDown(.down)) {
        move.y += speed;
    }

    if (move.x != 0 or move.y != 0) {
        aya.tilemap.move(map, player, &move);
        player.x += @as(i32, @intFromFloat(move.x));
        player.y += @as(i32, @intFromFloat(move.y));
    }
}

fn render() !void {
    aya.gfx.beginPass(.{});
    batch.draw();
    aya.draw.hollowRect(.{ .x = @as(f32, @floatFromInt(player.x)), .y = @as(f32, @floatFromInt(player.y)) }, @as(f32, @floatFromInt(player.w)), @as(f32, @floatFromInt(player.h)), 1, aya.math.Color.white);
    aya.gfx.endPass();
}
