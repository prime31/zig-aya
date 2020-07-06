const std = @import("std");
const aya = @import("../aya.zig");

pub const renderer = @import("renderer.zig");

pub const move = @import("collision.zig").move;

const flipped_h: i32 = 0x08000000;
const flipped_v: i32 = 0x04000000;
const flipped_d: i32 = 0x02000000;

pub const Map = struct {
    width: i32,
    height: i32,
    tile_size: i32,
    tilesets: []Tileset,
    tile_layers: []TileLayer,
    object_layers: []ObjectLayer = &[_]ObjectLayer{},
    group_layers: []GroupLayer = &[_]GroupLayer{},
    image_layers: []ImageLayer = &[_]ImageLayer{},

    pub fn initFromFile(file: []const u8) *Map {
        var bytes = aya.fs.read(aya.mem.tmp_allocator, file) catch unreachable;
        var tokens = std.json.TokenStream.init(bytes);

        const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
        const map = std.json.parse(*Map, &tokens, options) catch unreachable;
        for (map.tilesets) |ts| {
            ts.initializeTiles();
        }
        return map;
    }

    pub fn deinit(self: *Map) void {
        const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
        std.json.parseFree(*Map, self, options);
    }

    /// currently loads just the first Tileset's image until multiple Tilesets are supported
    pub fn loadTexture(self: *Map, map_folder: []const u8) aya.gfx.Texture {
        const image_path = std.fmt.allocPrint(aya.mem.tmp_allocator, "{}/{}", .{ map_folder, self.tilesets[0].image }) catch unreachable;
        return aya.gfx.Texture.initFromFile(image_path) catch unreachable;
    }

    pub fn worldToTileX(self: Map, x: f32) i32 {
        const tile_x = aya.math.ifloor(x / @intToFloat(f32, self.tile_size));
        return aya.math.iclamp(tile_x, 0, self.width - 1);
    }

    pub fn worldToTileY(self: Map, y: f32) i32 {
        const tile_y = aya.math.ifloor(y / @intToFloat(f32, self.tile_size));
        return aya.math.iclamp(tile_y, 0, self.height - 1);
    }

    pub fn tileToWorldX(self: Map, x: i32) i32 {
        return self.tile_size * x;
    }

    pub fn tileToWorldY(self: Map, y: i32) i32 {
        return self.tile_size * y;
    }

    /// attempts to find a Tileset tile for the tid. Note that tid is the raw tile id.
    pub fn tryGetTilesetTile(self: Map, tid: TileId) ?*TilesetTile {
        const id = tid & ~(flipped_h | flipped_v | flipped_d);
        return self.tilesets[0].tryGetTilesetTile(id);
    }
};

pub const Tileset = struct {
    tile_size: i32,
    spacing: i32,
    margin: i32,
    image: []const u8,
    image_columns: i32,
    tiles: []TilesetTile,

    pub fn initializeTiles(self: Tileset) void {
        for (self.tiles) |*tile| {
            tile.initialize();
        }
    }

    // id is the index of the tile (with the flipped bits stripped off) in this tileset image
    pub fn viewportForTile(self: Tileset, id: i32) aya.math.RectI {
        const x = @mod(id, self.image_columns);
        const y = @divTrunc(id, self.image_columns);

        return .{
            .x = x * (self.tile_size + self.spacing) + self.margin,
            .y = y * (self.tile_size + self.spacing) + self.margin,
            .w = self.tile_size,
            .h = self.tile_size,
        };
    }

    pub fn tryGetTilesetTile(self: Tileset, tid: TileId) ?*TilesetTile {
        for (self.tiles) |*tile| {
            if (tile.id == tid) {
                return tile;
            }
        }
        return null;
    }
};

pub const TilesetTile = struct {
    id: i32,
    oneway: bool = false,
    slope: bool = false,
    slope_tl: i32 = 0,
    slope_tr: i32 = 0,
    props: []KeyValue,

    pub fn initialize(self: *TilesetTile) void {
        for (self.props) |prop| {
            if (std.mem.eql(u8, prop.k, "nez:isOneWayPlatform")) {
                self.oneway = true;
            } else if (std.mem.eql(u8, prop.k, "nez:isSlope")) {
                self.slope = true;
            } else if (std.mem.eql(u8, prop.k, "nez:slopeTopLeft")) {
                self.slope_tl = prop.v.int;
            } else if (std.mem.eql(u8, prop.k, "nez:slopeTopRight")) {
                self.slope_tr = prop.v.int;
            }
        }
    }

    pub fn nameMe(self: TilesetTile, tid: TileId, tile_size: i32, perp_pos: i32, tile_world_x: i32, tile_world_y: i32) i32 {
        // rise over run
        const flip_h = (tid & flipped_h) != 0;
        const s_tr = if (flip_h) self.slope_tl else self.slope_tr;
        const s_tl = if (flip_h) self.slope_tr else self.slope_tl;
        const s = @intToFloat(f32, s_tr - s_tl) / @intToFloat(f32, tile_size);

        // s_tl is the slope position on the left side of the tile. b in the y = mx + b equation
        const y = s * @intToFloat(f32, perp_pos - tile_world_x) + @intToFloat(f32, s_tl + tile_world_y);
        return @floatToInt(i32, y);
    }
};

pub const KeyValue = struct {
    k: []const u8,
    v: PropValue,
};

pub const PropValue = union(enum) {
    bool: bool,
    int: i32,
    float: f32,
    string: []const u8,
};

pub const TileLayer = struct {
    name: []const u8,
    visible: bool,
    width: i32,
    height: i32,
    tiles: []TileId,

    /// used by the MapRenderer to optimize the AtlasBatch size
    pub fn totalNonEmptyTiles(self: TileLayer) i32 {
        var cnt = @as(i32, 0);

        for (self.tiles) |t| {
            if (t >= 0) {
                cnt += 1;
            }
        }

        return cnt;
    }

    pub fn hasTile(self: TileLayer, x: i32, y: i32) bool {
        return self.tiles[@intCast(usize, x + y * self.width)] >= 0;
    }

    pub fn getTileId(self: TileLayer, x: i32, y: i32) TileId {
        return self.tiles[@intCast(usize, x + y * self.width)];
    }
};

pub const ObjectLayer = struct {
    name: []const u8,
    visible: bool,
    objects: []Object,

    pub fn getObject(self: ObjectLayer, name: []const u8) Object {
        for (self.objects) |obj| {
            if (std.mem.eql(u8, obj.name, name)) {
                return obj;
            }
        }
        unreachable;
    }
};

pub const ImageLayer = struct {
    name: []const u8,
    visible: bool,
    source: []const u8,
};

pub const GroupLayer = struct {
    name: []const u8,
    visible: bool,
    tile_layers: []TileLayer,
    object_layers: []ObjectLayer,
    // group_layers: []GroupLayer, // JSON cant handle this
};

pub const ObjectShape = enum(i32) {
    box = 0,
    circle = 1,
    ellipse = 3,
    point = 5,
    polygon = 11,
};

pub const Object = struct {
    id: i32,
    name: []const u8,
    shape: ObjectShape,
    x: f32,
    y: f32,
    w: f32,
    h: f32,
};

pub const TileId = i32;
