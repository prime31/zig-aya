const std = @import("std");
const aya = @import("../../aya.zig");
const gfx = aya.gfx;
const tilemap = @import("tilemap.zig");

const Map = tilemap.Map;

const flipped_h: i32 = 0x08000000;
const flipped_v: i32 = 0x04000000;
const flipped_d: i32 = 0x02000000;

const TileRenderInfo = struct {
    id: i32,
    rot: f32 = 0,
    sx: f32 = 1,
    sy: f32 = 1,
    ox: f32 = 0,
    oy: f32 = 0,

    pub fn init(id: tilemap.TileId, tile_size: i32) TileRenderInfo {
        var info = TileRenderInfo{ .id = id & ~(flipped_h | flipped_v | flipped_d) };

        const flip_h = (id & flipped_h) != 0;
        const flip_v = (id & flipped_v) != 0;

        // deal with flipping/rotating if necessary
        if (id > flipped_d) {
            // set the origin based on the tile_size if we are rotated
            info.ox = @as(f32, @floatFromInt(tile_size)) / 2.0;
            info.oy = @as(f32, @floatFromInt(tile_size)) / 2.0;

            if (flip_h) info.sx *= -1;
            if (flip_v) info.sy *= -1;

            if ((id & flipped_d) != 0) {
                if (flip_h and flip_v) {
                    info.rot = aya.math.pi_over_2;
                    info.sy *= -1;
                } else if (flip_h) {
                    info.rot = -aya.math.pi_over_2;
                    info.sy *= -1;
                } else if (flip_v) {
                    info.rot = aya.math.pi_over_2;
                    info.sx *= -1;
                } else {
                    info.rot = -aya.math.pi_over_2;
                    info.sx *= -1;
                }
            }
        }

        return info;
    }

    pub fn transformMatrix(self: TileRenderInfo, x: f32, y: f32) aya.math.Mat32 {
        return aya.math.Mat32.initTransform(.{ .x = x, .y = y, .angle = self.rot, .sx = self.sx, .sy = self.sy, .ox = self.ox, .oy = self.oy });
    }
};

/// Renders a layer into an AtlasBatch and returns it
pub fn renderTileLayerIntoAtlasBatch(map: *Map, layer: tilemap.TileLayer, texture: gfx.Texture) gfx.AtlasBatch {
    var batch = gfx.AtlasBatch.init(null, texture, layer.totalNonEmptyTiles()) catch unreachable;
    renderTileLayer(map, layer, texture, &batch);
    return batch;
}

/// Renders all visible Tile and Object layers
pub fn render(map: *Map, texture: gfx.Texture) void {
    for (map.tile_layers) |tl| {
        if (tl.visible) {
            renderTileLayer(map, tl, texture, null);
        }
    }

    for (map.object_layers) |ol| {
        if (ol.visible) {
            renderObjectLayer(ol);
        }
    }
}

pub fn renderTileLayer(map: *Map, layer: tilemap.TileLayer, texture: gfx.Texture, atlas_batch: ?*gfx.AtlasBatch) void {
    var i: usize = 0;
    var y: usize = 0;
    while (y < layer.height) : (y += 1) {
        var x: usize = 0;
        while (x < layer.width) : (x += 1) {
            var tile_id = layer.tiles[i];
            i += 1;
            if (tile_id >= 0) {
                const info = TileRenderInfo.init(tile_id, map.tile_size);
                const vp = map.tilesets[0].viewportForTile(info.id);

                const tx = @as(f32, @floatFromInt(@as(i32, @intCast(x)) * map.tile_size)) + info.ox;
                const ty = @as(f32, @floatFromInt(@as(i32, @intCast(y)) * map.tile_size)) + info.oy;
                const mat = info.transformMatrix(tx, ty);

                if (atlas_batch) |batch| {
                    _ = batch.addViewport(vp, mat, aya.math.Color.white);
                } else {
                    aya.draw.texViewport(texture, vp, mat);
                }
            }
        }
    }
}

pub fn renderObjectLayer(layer: tilemap.ObjectLayer) void {
    for (layer.objects) |obj| {
        switch (obj.shape) {
            .box => aya.draw.hollowRect(.{ .x = obj.x, .y = obj.y }, obj.w, obj.h, 1, aya.math.Color.yellow),
            .circle, .ellipse => {
                const rad = obj.w / 2;
                aya.draw.circle(.{ .x = obj.x + rad, .y = obj.y + rad }, rad, 5, 1, aya.math.Color.yellow);
            },
            .point => aya.draw.point(.{ .x = obj.x, .y = obj.y }, 6, aya.math.Color.yellow),
            .polygon => std.debug.print("polygon draw not implemented\n", .{}),
        }
    }
}
