const std = @import("std");
const aya = @import("aya");
const sdl = @import("sdl");
const Map = aya.tilemap.Map;

var map: *Map = undefined;
var texture: aya.gfx.Texture = undefined;
var batch: aya.gfx.AtlasBatch = undefined;
var player: aya.math.RectI = undefined;
var speed: f32 = 3;

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

    map = Map.initFromFile("assets/platformer.json");
    texture = map.loadTexture("assets");
    batch = aya.tilemap.renderer.renderTileLayerIntoAtlasBatch(map, map.tile_layers[0], texture);

    const spawn = map.object_layers[0].getObject("spawn");
    player = aya.math.RectI{.x = @floatToInt(i32, spawn.x), .y = @floatToInt(i32, spawn.y), .w = @floatToInt(i32, spawn.w), .h = @floatToInt(i32, spawn.h)};
}

fn update() void {
    var move = aya.math.Vec2{};

    if (aya.input.keyDown(sdl.SDL_Scancode.SDL_SCANCODE_RIGHT)) {
        move.x += speed;
    } else if (aya.input.keyDown(sdl.SDL_Scancode.SDL_SCANCODE_LEFT)) {
        move.x -= speed;
    }

    if (aya.input.keyDown(sdl.SDL_Scancode.SDL_SCANCODE_UP)) {
        move.y -= speed;
    } else if (aya.input.keyDown(sdl.SDL_Scancode.SDL_SCANCODE_DOWN)) {
        move.y += speed;
    }

    if (move.x != 0 or move.y != 0) {
        aya.tilemap.move(map, player, &move);
        player.x += @floatToInt(i32, move.x);
        player.y += @floatToInt(i32, move.y);
    }
}

fn render() void {
    aya.gfx.beginPass(.{});
    batch.draw();
    aya.draw.hollowRect(.{.x = @intToFloat(f32, player.x), .y = @intToFloat(f32, player.y)}, @intToFloat(f32, player.w), @intToFloat(f32, player.h), 1, aya.math.Color.white);
    aya.gfx.endPass();
}
