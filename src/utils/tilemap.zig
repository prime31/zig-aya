const std = @import("std");

const FLIPPED_H: i32 = 0x08000000;
const FLIPPED_V: i32 = 0x04000000;
const FLIPPED_D: i32 = 0x02000000;

pub const Map = struct {
    width: i32,
    height: i32,
    tile_size: i32,
    tilesets: []Tileset,
    tile_layers: []TileLayer,
    object_layers: []ObjectLayer,
    group_layers: []GroupLayer,
    image_layers: []ImageLayer,
};

pub const Tileset = struct {
    tile_size: i32,
    spacing: i32,
    margin: i32,
    image: []const u8,
    image_columns: i32,
    tiles: []TilesetTile,
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
};

pub const ObjectLayer = struct {
    name: []const u8,
    visible: bool,
    objects: []Object,
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

pub const Object = struct {
    id: i32,
    name: []const u8,
    shape: i32,
    x: f32,
    y: f32,
    w: f32,
    h: f32,
};

pub const TileId = i32;
