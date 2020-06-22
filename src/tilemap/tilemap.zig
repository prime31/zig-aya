const std = @import("std");
const aya = @import("../aya.zig");

pub const MapRenderer = @import("map_renderer.zig").MapRenderer;

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
        return map;
    }

    pub fn deinit(self: *Map) void {
        const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
        std.json.parseFree(*Map, self, options);
    }
};

pub const Tileset = struct {
    tile_size: i32,
    spacing: i32,
    margin: i32,
    image: []const u8,
    image_columns: i32,
    tiles: []TilesetTile,

    // id is the index of the tile (with the flipped bits stripped off) in this tileset image
    pub fn viewportForTile(self: Tileset, id: i32) aya.math.RectI {
        const x = @mod(id, self.image_columns);
        const y = @rem(id, self.image_columns);

        return .{
            .x = x * (self.tile_size + self.spacing) + self.margin,
            .y = y * (self.tile_size + self.spacing) + self.margin,
            .w = self.tile_size,
            .h = self.tile_size,
        };
    }
};

pub const TilesetTile = struct {
    id: i32,
    oneway: bool = false,
    slope: bool = false,
    slope_tl: i32 = 0,
    slope_tr: i32 = 0,
    props: []KeyValue,
};

pub const KeyValue = struct {
    k: []const u8,
    v: PropValue,
};

pub const PropValue = union(enum) {
    bool: bool,
    int: i64,
    float: f64,
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
        return l.tiles[x + y * l.width] >= 0;
    }

    pub fn getTileId(self: TileLayer, x: i32, y: i32) TileId {
        return l.tiles[x + y * l.width];
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
