const std = @import("std");
const aya = @import("../aya.zig");
const math = aya.math;
const tilemap = @import("tilemap.zig");

const Map = tilemap.Map;
const CollisionIterator = @import("collision_iterator.zig").CollisionIterator;

// the inset on the horizontal/vertical planes that the BoxCollider will be shrunk by when moving
const horiz_inset = 2;
const vert_inset = 2;

pub fn move(map: *Map, rect: math.RectI, movement: *math.Vec2) void {
    const layer = map.tile_layers[0];
    var local_rect = rect;

    if (movement.x != 0) {
        var x = moveX(map, layer, rect, @floatToInt(i32, movement.x));
        movement.x = @intToFloat(f32, x);
        local_rect.x += x;
    }

    movement.y = @intToFloat(f32, moveY(map, layer, local_rect, @floatToInt(i32, movement.y)));
}

pub fn moveX(map: *Map, layer: tilemap.TileLayer, rect: math.RectI, move_x: i32) i32 {
    var edge: math.Edge = if (move_x > 0) .right else .left;
    var bounds = rect.halfRect(edge);

    // we contract horizontally for vertical movement and vertically for horizontal movement
    bounds.contract(0, vert_inset);
    // finally expand the side in the direction of movement
    bounds.expandEdge(edge, move_x);

    // debugOverlaps(map, bounds, edge);

    // keep track of any rows with slopes. We use this info to ignore collisions that occur with tiles behind slopes (inaccessible)
    var slope_rows = [_]i32{ -1, -1, -1 };
    var last_slope_row: usize = 0;

    var iter = CollisionIterator.init(map, bounds, edge);
    while (iter.next()) |pt| {
        const tid = layer.getTileId(pt.x, pt.y);
        if (tid >= 0) {
            if (map.tryGetTilesetTile(tid)) |tileset_tile| {
                // ignore oneway platforms and slopes
                if (tileset_tile.oneway) {
                    continue;
                }
                if (tileset_tile.slope) {
                    slope_rows[last_slope_row] = pt.y;
                    last_slope_row += 1;
                    continue;
                }
            }

            if (std.mem.indexOfScalar(i32, &slope_rows, pt.y) != null) {
                continue;
            }

            // world_x is the LEFT of the tile
            const world_x = map.tileToWorldX(pt.x);
            if (move_x < 0) {
                return world_x + map.tile_size - rect.x;
            } else {
                return world_x - rect.right();
            }
        }
    }

    return move_x;
}

pub fn moveY(map: *Map, layer: tilemap.TileLayer, rect: math.RectI, move_y: i32) i32 {
    var edge: math.Edge = if (move_y >= 0) .bottom else .top;
    var bounds = rect.halfRect(edge);

    // we contract horizontally for vertical movement and vertically for horizontal movement
    bounds.contract(horiz_inset, 0);
    // finally expand the side in the direction of movement
    bounds.expandEdge(edge, move_y);

    // debugOverlaps(map, bounds, edge);

    var iter = CollisionIterator.init(map, bounds, edge);
    while (iter.next()) |pt| {
        const tid = layer.getTileId(pt.x, pt.y);
        if (tid >= 0) {
            if (map.tryGetTilesetTile(tid)) |tileset_tile| {
                if (tileset_tile.oneway) {
                    // allow movement up always and down if our bottom is not above the tile
                    if (edge == .top or map.tileToWorldY(pt.y) < rect.bottom()) {
                        continue;
                    }
                } else if (tileset_tile.slope) {
                    const perp_pos = bounds.centerX();
                    const tile_world_x = map.tileToWorldY(pt.x);

                    // only process the slope if our center is within the tiles bounds
                    if (math.between(perp_pos, tile_world_x, tile_world_x + map.tile_size)) {
                        const leading_edge_pos = bounds.side(edge);
                        const tile_world_y = map.tileToWorldY(pt.y);
                        const slope_pos_y = tileset_tile.nameMe(tid, map.tile_size, perp_pos, tile_world_x, tile_world_y);

                        if (leading_edge_pos >= slope_pos_y) {
                            return slope_pos_y - rect.bottom();
                        }
                        return move_y;
                    }
                    continue;
                }
            } // end tryGetTilesetTile

            // world_y is the TOP of the tile
            const world_y = map.tileToWorldY(pt.y);

            if (edge == .top) {
                return world_y + map.tile_size - rect.y;
            } else {
                return world_y - rect.bottom();
            }
        }
    }

    return move_y;
}

fn debugOverlaps(map: *Map, bounds: math.RectI, edge: math.Edge) void {
    var tile_cnt: i32 = 0;
    const tile_size = @intToFloat(f32, map.tile_size);

    var iter = CollisionIterator.init(map, bounds, edge);
    while (iter.next()) |pt| {
        const xw = map.tileToWorldX(pt.x);
        const yw = map.tileToWorldY(pt.y);
        const color = switch (tile_cnt) {
            0 => math.Color.yellow,
            1 => math.Color.red,
            2 => math.Color.blue,
            3 => math.Color.black,
            else => math.Color.orange,
        };
        aya.debug.drawHollowRect(.{ .x = @intToFloat(f32, xw), .y = @intToFloat(f32, yw) }, tile_size, tile_size, 1, color);
        tile_cnt += 1;
    }
}
