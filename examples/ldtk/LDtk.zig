const std = @import("std");

alloc: std.mem.Allocator,
root: Root,
parsed_root: std.json.Parsed(Root),

pub fn parse(alloc: std.mem.Allocator, ldtk_file: []const u8) !@This() {
    var this: @This() = undefined;
    this.alloc = alloc;

    this.parsed_root = try std.json.parseFromSlice(Root, alloc, ldtk_file, .{ .ignore_unknown_fields = true });
    this.root = this.parsed_root.value;

    return this;
}

pub fn deinit(this: *@This()) void {
    this.parsed_root.deinit();
}

/// 1. LDtk Json root
pub const Root = struct {
    bgColor: []const u8,
    defs: ?Definitions = null,
    externalLevels: bool,
    jsonVersion: []const u8,
    levels: []Level,
    worldGridHeight: ?i64 = null,
    worldGridWidth: ?i64 = null,
    worldLayout: ?WorldLayout = null,
    worlds: ?[]World = null,

    pub fn fromJSON(alloc: std.mem.Allocator, root_opt: ?std.json.Value) !Root {
        const root = object(root_opt) orelse return error.InvalidRoot;
        const ldtk_levels = try Level.fromJSONMany(alloc, root.get("levels"));
        var ldtk_root = Root{
            .bgColor = string(root.get("bgColor")) orelse return error.InvalidBGColor,
            // .defs = ldtk_defs,
            .externalLevels = boolean(root.get("externalLevels")) orelse return error.InvalidExternalLevels,
            .jsonVersion = string(root.get("jsonVersion")) orelse return error.InvalidJsonVersion,
            .levels = ldtk_levels,
            .worldGridHeight = integer(root.get("worldGridHeight")) orelse return error.InvalidHeight,
            .worldGridWidth = integer(root.get("worldGridWidth")) orelse return error.InvalidWidth,
            .worldLayout = enum_from_value(WorldLayout, root.get("worldLayout")) orelse return error.InvalidWorldLayout,
        };
        if (array(root.get("worlds"))) |worlds| {
            ldtk_root.worlds = try World.fromJSONMany(alloc, worlds);
        }
        return ldtk_root;
    }

    pub fn deinit(root: Root, alloc: std.mem.Allocator) void {
        if (root.defs) |defs| defs.deinit(alloc);
        if (root.worlds) |worlds| {
            for (worlds) |world| world.deinit(alloc);
            alloc.free(worlds);
        }
        for (root.levels) |level| level.deinit(alloc);
        alloc.free(root.levels);
    }
};

/// 1.1. World
pub const World = struct {
    identifier: []const u8,
    iid: []const u8,
    levels: []Level,
    worldGridHeight: i64,
    worldGridWidth: i64,
    worldLayout: WorldLayout,

    pub fn fromJSON(alloc: std.mem.Allocator, world_value: ?std.json.Value) !World {
        const world_obj = object(world_value) orelse return error.InvalidWorld;
        const levels_obj = world_obj.get("levels") orelse return error.InvalidWorldLevels;
        const levels = try Level.fromJSONMany(alloc, levels_obj);
        return World{
            .identifier = string(world_obj.get("identifier")) orelse return error.InvalidIdentifier,
            .iid = string(world_obj.get("iid")) orelse return error.InvalidIID,
            .levels = levels,
            .worldGridHeight = integer(world_obj.get("worldGridHeight")) orelse return error.InvalidWorldGridHeight,
            .worldGridWidth = integer(world_obj.get("worldGridHeight")) orelse return error.InvalidWorldGridHeight,
            .worldLayout = enum_from_value(WorldLayout, world_obj.get("worldLayout")) orelse return error.InvalidWorldLayout,
        };
    }

    pub fn fromJSONMany(alloc: std.mem.Allocator, worlds: std.json.Array) ![]World {
        var ldtk_worlds = try std.ArrayList(World).initCapacity(alloc, worlds.items.len);
        for (worlds.items) |world_value| {
            ldtk_worlds.appendAssumeCapacity(try fromJSON(alloc, world_value));
        }
        return ldtk_worlds.toOwnedSlice();
    }

    pub fn deinit(world: World, alloc: std.mem.Allocator) void {
        for (world.levels) |level| level.deinit(alloc);
        alloc.free(world.levels);
    }
};

pub const WorldLayout = enum {
    Free,
    GridVania,
    LinearHorizontal,
    LinearVertical,
};

/// 2. Level
pub const Level = struct {
    __bgColor: []const u8,
    __bgPos: ?struct {
        cropRect: [4]f64,
        scale: [2]f64,
        topLeftPx: [2]i64,
    },
    __neighbours: []Neighbour,
    bgRelPath: ?[]const u8,
    externalRelPath: ?[]const u8,
    fieldInstances: []FieldInstance,
    identifier: []const u8,
    iid: []const u8,
    layerInstances: ?[]LayerInstance,
    pxHei: i64,
    pxWid: i64,
    uid: i64,
    worldDepth: i64,
    worldX: i64,
    worldY: i64,

    pub fn fromJSON(alloc: std.mem.Allocator, level_opt: ?std.json.Value) !Level {
        const level_obj = object(level_opt) orelse return error.InvalidLevel;
        const layer_instances = if (level_obj.get("layerInstances")) |layerInstances| try LayerInstance.fromJSONMany(alloc, layerInstances) else null;
        return Level{
            .__bgColor = string(level_obj.get("__bgColor")) orelse return error.Invalid__bgColor,
            // TODO
            .__bgPos = null,
            // TODO
            .__neighbours = &[_]Neighbour{},
            .bgRelPath = string(level_obj.get("bgRelPath")),
            .externalRelPath = string(level_obj.get("externalRelPath")),
            // TODO
            .fieldInstances = &[_]FieldInstance{},
            .identifier = string(level_obj.get("identifier")) orelse return error.InvalidIdentifier,
            .iid = string(level_obj.get("iid")) orelse return error.InvalidIID,
            .layerInstances = layer_instances,
            .pxHei = integer(level_obj.get("pxHei")) orelse return error.InvalidPxHei,
            .pxWid = integer(level_obj.get("pxWid")) orelse return error.InvalidPxWid,
            .uid = integer(level_obj.get("uid")) orelse return error.InvalidUID,
            .worldDepth = integer(level_obj.get("worldDepth")) orelse return error.InvalidWorldDepth,
            .worldX = integer(level_obj.get("worldX")) orelse return error.InvalidWorldX,
            .worldY = integer(level_obj.get("worldY")) orelse return error.InvalidWorldY,
        };
    }

    pub fn fromJSONMany(alloc: std.mem.Allocator, levels_opt: ?std.json.Value) ![]Level {
        const levels = array(levels_opt) orelse return error.InvalidLevels;
        var ldtk_levels = try std.ArrayList(Level).initCapacity(alloc, levels.items.len);
        defer ldtk_levels.deinit(); // levels will be returned using toOwnedSlice
        for (levels.items) |level_value| {
            ldtk_levels.appendAssumeCapacity(try fromJSON(alloc, level_value));
        }
        return ldtk_levels.toOwnedSlice();
    }

    pub fn deinit(level: Level, alloc: std.mem.Allocator) void {
        alloc.free(level.__neighbours);
        alloc.free(level.fieldInstances);
        if (level.layerInstances) |layerInstances| {
            for (layerInstances) |layerInstance| layerInstance.deinit(alloc);
            alloc.free(layerInstances);
        }
    }
};

pub const Neighbour = struct {
    dir: []const u8,
    levelIid: []const u8,
    levelUid: ?i64 = null,
};

/// 2.1. Layer instance
pub const LayerInstance = struct {
    /// Grid-based height
    __cHei: i64,
    /// Grid-based width
    __cWid: i64,
    /// Grid size
    __gridSize: i64,
    /// Layer definition identifier
    __identifier: []const u8,
    /// Layer opacity as Float [0-1]
    __opacity: f64,
    /// Total layer X pixel offset, including both instance and definition offsets
    __pxTotalOffsetX: i64,
    /// Total layer Y pixel offset, including both instance and definition offsets
    __pxTotalOffsetY: i64,
    /// The definition UID of corresponding Tileset, if any
    __tilesetDefUid: ?i64,
    /// The relative path to corresponding Tileset, if any
    __tilesetRelPath: ?[]const u8,
    /// Layer type (possible values: IntGrid, Entities, Tiles, or AutoLayer)
    __type: LayerType,
    /// An array containing all tiles generated by Auto-layer rules. The array is laready sorted in display order (ie. 1st tile is beneath 2nd, which is beneath 3rd etc.).
    /// Note: if multiple tiles are stacked in the same cell as the result of rules, all tiles behind opaque ones will be discarded.
    autoLayerTiles: []TileInstance,
    entityInstances: []EntityInstance,
    gridTiles: []TileInstance,
    iid: []const u8,
    intGridCsv: []const i64,
    layerDefUid: i64,
    levelId: i64,
    overrideTilesetUid: ?i64,
    pxOffsetX: i64,
    pxOffsetY: i64,
    visible: bool,
    /// WARNING: this deprecated value is no longer exported since version 1.0.0
    /// Replaced by: intGridCsv
    intGrid: ?[][]const u8 = null,

    pub fn fromJSON(alloc: std.mem.Allocator, layer_value: std.json.Value) !LayerInstance {
        const layer_obj = object(layer_value) orelse return error.InvalidLayer;
        const __type = enum_from_value(LayerType, layer_obj.get("__type")) orelse return error.InvalidType;
        var grid = grid: {
            if (__type == .IntGrid) {
                if (array(layer_obj.get("intGridCsv"))) |intGridCsv| {
                    var grid_list = try std.ArrayList(i64).initCapacity(alloc, intGridCsv.items.len);
                    defer grid_list.deinit();

                    for (intGridCsv.items) |int| {
                        grid_list.appendAssumeCapacity(integer(int) orelse return error.InvalidInt);
                    }

                    break :grid grid_list.toOwnedSlice();
                }
            }
            break :grid &[0]i64{};
        };
        return LayerInstance{
            .__cHei = integer(layer_obj.get("__cHei")) orelse return error.InvalidCHei,
            .__cWid = integer(layer_obj.get("__cWid")) orelse return error.InvalidCWid,
            .__gridSize = integer(layer_obj.get("__gridSize")) orelse return error.InvalidGridSize,
            .__identifier = string(layer_obj.get("__identifier")) orelse return error.InvalidIdentifier,
            .__opacity = float(layer_obj.get("__opacity")) orelse return error.InvalidOpacity,
            .__pxTotalOffsetX = integer(layer_obj.get("__pxTotalOffsetX")) orelse return error.InvalidTotalOffsetX,
            .__pxTotalOffsetY = integer(layer_obj.get("__pxTotalOffsetY")) orelse return error.InvalidTotalOffsetY,
            .__tilesetDefUid = integer(layer_obj.get("__tilesetDefUid")),
            .__tilesetRelPath = string(layer_obj.get("__tilesetRelPath")),
            .__type = __type,
            .autoLayerTiles = try TileInstance.fromJSONMany(alloc, layer_obj.get("autoLayerTiles")),
            .entityInstances = try EntityInstance.fromJSONMany(alloc, layer_obj.get("entityInstances")),
            .gridTiles = try TileInstance.fromJSONMany(alloc, layer_obj.get("gridTiles")),
            .iid = string(layer_obj.get("iid")) orelse return error.InvalidIID,
            .intGridCsv = try grid,
            .layerDefUid = integer(layer_obj.get("layerDefUid")) orelse return error.InvalidLayerDefUid,
            .levelId = integer(layer_obj.get("levelId")) orelse return error.InvalidLevelId,
            .overrideTilesetUid = integer(layer_obj.get("overrideTilesetUid")),
            .pxOffsetX = integer(layer_obj.get("pxOffsetX")) orelse return error.InvalidPxOffsetX,
            .pxOffsetY = integer(layer_obj.get("pxOffsetY")) orelse return error.InvalidPxOffsetY,
            .visible = boolean(layer_obj.get("visible")) orelse return error.InvalidVisible,
        };
    }

    pub fn fromJSONMany(alloc: std.mem.Allocator, layers_opt: ?std.json.Value) ![]LayerInstance {
        const layers = array(layers_opt) orelse return &[_]LayerInstance{};
        var ldtk_layers = try std.ArrayList(LayerInstance).initCapacity(alloc, layers.items.len);
        defer ldtk_layers.deinit(); // levels will be returned using toOwnedSlice
        for (layers.items) |layer_value| {
            ldtk_layers.appendAssumeCapacity(try fromJSON(alloc, layer_value));
        }
        return ldtk_layers.toOwnedSlice();
    }

    pub fn deinit(layerInstance: LayerInstance, alloc: std.mem.Allocator) void {
        alloc.free(layerInstance.autoLayerTiles);
        alloc.free(layerInstance.gridTiles);
        for (layerInstance.entityInstances) |entityInstance| {
            entityInstance.deinit(alloc);
        }
        alloc.free(layerInstance.entityInstances);
        if (layerInstance.intGridCsv.len != 0) {
            alloc.free(layerInstance.intGridCsv);
        }
    }
};

const LayerType = enum {
    IntGrid,
    Entities,
    Tiles,
    AutoLayer,
};

/// 2.2. Tile instance
const TileInstance = struct {
    /// "Flip bits", a 2-bits integer to represent the mirror transformations of the tile.
    /// - Bit 0 = X flip
    /// - Bit 1 = Y flip
    f: FlipBits,
    /// Pixel coordinates of the tile in the layer ([x, y] format). Don't forget optional layer offsets, if they exist!
    px: [2]i64,
    /// Pixel coordinates of the tile in the tileset ([x, y] format)
    src: [2]i64,
    /// The Tile ID in the corresponding tileset
    t: i64,

    pub fn fromJSON(tile_opt: ?std.json.Value) !TileInstance {
        const tile = object(tile_opt) orelse return error.InvalidTileInstance;

        const f = @as(FlipBits, @intFromEnum(integer(tile.get("f"))) orelse return error.InvalidFlipBits);
        const px = pos_from_value(tile.get("px")) orelse return error.InvalidPx;
        const src = pos_from_value(tile.get("src")) orelse return error.InvalidSrc;
        const t = integer(tile.get("t")) orelse return error.InvalidT;
        return TileInstance{
            .f = f,
            .px = px,
            .src = src,
            .t = t,
        };
    }

    pub fn fromJSONMany(alloc: std.mem.Allocator, tiles_opt: ?std.json.Value) ![]TileInstance {
        const tiles = array(tiles_opt) orelse return &[_]TileInstance{};
        var ldtk_tiles = try std.ArrayList(TileInstance).initCapacity(alloc, tiles.items.len);
        defer ldtk_tiles.deinit(); // levels will be returned using toOwnedSlice
        for (tiles.items) |tile_value| {
            ldtk_tiles.appendAssumeCapacity(try fromJSON(tile_value));
        }
        return ldtk_tiles.toOwnedSlice();
    }
};

const FlipBits = enum(u4) {
    NoFlip = 0,
    XFlip = 1,
    YFlip = 2,
    XYFlip = 3,
};

/// 2.3. Entity instance
const EntityInstance = struct {
    __grid: [2]i64,
    __identifier: []const u8,
    __pivot: [2]f64,
    __smartColor: []const u8,
    __tags: [][]const u8,
    __tile: ?TilesetRectangle,
    defUid: i64,
    fieldInstances: []FieldInstance,
    height: i64,
    iid: []const u8,
    px: [2]i64,
    width: i64,

    pub fn fromJSON(alloc: std.mem.Allocator, entity_opt: std.json.Value) !EntityInstance {
        const entity = object(entity_opt) orelse return error.InvalidEntityInstance;
        const __grid = pos_from_value(entity.get("__grid")) orelse return error.InvalidGrid;
        const __identifier = string(entity.get("__identifier")) orelse return error.InvalidIdentifier;
        const __pivot = posf_from_value(entity.get("__pivot")) orelse return error.InvalidPivot;
        const __smartColor = string(entity.get("__smartColor")) orelse return error.InvalidSmartColor;
        const __tags = try string_list(alloc, entity.get("__tags"));
        const __tile = try TilesetRectangle.fromJSON(entity.get("__tile"));
        const defUid = integer(entity.get("defUid")) orelse return error.InvalidDefUid;
        const fieldInstances = try FieldInstance.fromJSONMany(alloc, entity.get("fieldInstances"));
        const height = integer(entity.get("height")) orelse return error.InvalidHeight;
        const iid = string(entity.get("iid")) orelse return error.InvalidIid;
        const px = pos_from_value(entity.get("px")) orelse return error.InvalidPx;
        const width = integer(entity.get("width")) orelse return error.InvalidWidth;

        return EntityInstance{
            .__grid = __grid,
            .__identifier = __identifier,
            .__pivot = __pivot,
            .__smartColor = __smartColor,
            .__tags = __tags,
            .__tile = __tile,
            .defUid = defUid,
            .fieldInstances = fieldInstances,
            .height = height,
            .iid = iid,
            .px = px,
            .width = width,
        };
    }

    pub fn fromJSONMany(alloc: std.mem.Allocator, entities_opt: ?std.json.Value) ![]EntityInstance {
        const entities = array(entities_opt) orelse return &[_]EntityInstance{};
        var ldtk_entities = try std.ArrayList(EntityInstance).initCapacity(alloc, entities.items.len);
        defer ldtk_entities.deinit(); // levels will be returned using toOwnedSlice
        for (entities.items) |entity_value| {
            ldtk_entities.appendAssumeCapacity(try fromJSON(alloc, entity_value));
        }
        return ldtk_entities.toOwnedSlice();
    }

    pub fn deinit(entityInstance: EntityInstance, alloc: std.mem.Allocator) void {
        alloc.free(entityInstance.fieldInstances);
        alloc.free(entityInstance.__tags);
    }
};

/// 2.4. Field Instance
pub const FieldInstance = struct {
    __identifier: []const u8,
    __tile: ?TilesetRectangle,
    // TODO: type and value have many possible values and are not always strings.
    // Figure out if we can use JSON.parse for this
    __type: []const u8,
    __value: std.json.Value,
    defUid: i64,

    pub fn fromJSON(field_value: ?std.json.Value) !?FieldInstance {
        const field = object(field_value) orelse return error.InvalidFieldInstance;
        const __identifier = string(field.get("__identifier")) orelse return error.InvalidIdentifier;
        const __tile = try TilesetRectangle.fromJSON(field.get("__tile"));
        const __type = string(field.get("__type")) orelse return error.InvalidType;
        const __value = field.get("__value") orelse return error.InvalidValue;
        const defUid = integer(field.get("defUid")) orelse return error.InvalidIDefUid;
        return FieldInstance{
            .__identifier = __identifier,
            .__tile = __tile,
            .__type = __type,
            .__value = __value,
            .defUid = defUid,
        };
    }

    pub fn fromJSONMany(alloc: std.mem.Allocator, fields_opt: ?std.json.Value) ![]FieldInstance {
        const fields = array(fields_opt) orelse return &[_]FieldInstance{};
        var ldtk_fields = try std.ArrayList(FieldInstance).initCapacity(alloc, fields.items.len);
        defer ldtk_fields.deinit(); // levels will be returned using toOwnedSlice
        for (fields.items) |field_value| {
            if (try fromJSON(field_value)) |field| {
                ldtk_fields.appendAssumeCapacity(field);
            }
        }
        return ldtk_fields.toOwnedSlice();
    }
};

const FieldType = union(enum) {
    Int,
    Float,
    String,
    Enum: []const u8,
    Bool,
};

/// 2.4.2 Field instance entity reference
const FieldInstanceRef = struct {
    entityIid: []const u8,
    layerIid: []const u8,
    levelIid: []const u8,
    worldIid: []const u8,
};

/// 2.4.3 Field instance grid point
const FiledInstanceGridPoint = struct {
    cx: i64,
    cy: i64,
};

/// 3. Definitions
/// Only 2 definitions you might need here are Tilesets and Enums
const Definitions = struct {
    entities: []EntityDefinition,
    enums: []EnumDefinition,
    /// Same as enums, excepts they have a relPath to point to an external source file
    externalEnums: []EnumDefinition,
    layers: []LayerDefinition,
    /// All custom fields available to all levels
    levelFields: []FieldDefinition,
    /// All tilesets
    tilesets: []TilesetDefinition,

    pub fn deinit(defs: Definitions, alloc: std.mem.Allocator) void {
        _ = defs;
        _ = alloc;
        // TODO
    }
};

/// 3.1. Layer definition
const LayerDefinition = struct {
    __type: enum {
        IntGrid,
        Entities,
        Tiles,
        AutoLayer,
    },
    autoSourceLayerDefUid: ?i64,
    displayOpacity: f64,
    gridSize: i64,
    identifier: []const u8,
    intGridValues: []struct { color: []const u8, identifier: ?[]const u8, value: i64 },
    parallaxFactorX: f64,
    parallaxFactorY: f64,
    parallaxScaling: bool,
    pxOffsetX: i64,
    pxOffsetY: i64,
    /// Reference to the default Tileset UID used by this layer definition.
    /// WARNING: some layer instances might use a different tileset. So most of the time, you should probably use the __tilesetDefUid value found in layer instances.
    /// NOTE: since version 1.0.0, the old autoTilesetDefUid was removed and merged into this value.
    tilesetDefUid: ?i64,
    /// Unique Int identifier
    uid: i64,
    /// WARNING: this deprecated value will be removed completely on version 1.2.0+
    /// Replaced by: tilesetDefUid
    autoTilesetDefUid: ?i64 = null,
};

/// 3.1.1. Auto-layer rule definition
const AutoLayerRuleDefinition = opaque {};

/// 3.2. Entity definition
const EntityDefinition = struct {
    color: []const u8,
    height: i64,
    identifier: []const u8,
    nineSliceBorders: []i64,
    pivotX: f64,
    pivotY: f64,
    tileRect: TilesetRectangle,
    tileRenderMode: enum { Cover, FitInside, Repeat, Stretch, FullSizeCropped, FullSizeUncropped, NineSlice },
    tilesetId: ?i64,
    uid: i64,
    width: i64,
    /// WARNING: this deprecated value will be removed completely on version 1.2.0+
    /// Replaced by tileRect
    tileId: ?i64 = null,
};

/// 3.2.1. Field definition
const FieldDefinition = []const u8;

/// 3.2.2. Tileset rectangle
pub const TilesetRectangle = struct {
    tilesetUid: i64,
    w: i64,
    h: i64,
    x: i64,
    y: i64,

    pub fn fromJSON(tile_rect_opt: ?std.json.Value) !?TilesetRectangle {
        const tile_rect = object(tile_rect_opt) orelse return null;
        return TilesetRectangle{
            .tilesetUid = integer(tile_rect.get("tilesetUid")) orelse return error.InvalidTilesetUid,
            .w = integer(tile_rect.get("w")) orelse return error.InvalidW,
            .h = integer(tile_rect.get("h")) orelse return error.InvalidH,
            .x = integer(tile_rect.get("x")) orelse return error.InvalidX,
            .y = integer(tile_rect.get("y")) orelse return error.InvalidY,
        };
    }
};

/// 3.3. Tileset definition
const TilesetDefinition = struct {
    __cHei: i64,
    __cWid: i64,
    customData: []struct {
        data: []const u8,
        tileId: i64,
    },
    embedAtlas: ?enum { LdtkIcons },
    enumTags: []struct {
        enumValueId: []const u8,
        tileIds: []i64,
    },
    identifier: []const u8,
    padding: i64,
    pxHei: i64,
    pxWid: i64,
    relPath: ?[]const u8,
    spacing: i64,
    tags: [][]const u8,
    tagsSourceEnumUid: ?i64,
    tileGridSize: i64,
    uid: i64,
};

/// 3.4. Enum definition
const EnumDefinition = struct {
    externalRelPath: ?[]const u8,
    externalFileChecksum: ?u64,
    iconTilesetUid: ?i64,
    identifier: []const u8,
    tags: [][]const u8,
    uid: i64,
    values: []EnumValueDefinition,
};

/// 3.4.1. Enum value definition
const EnumValueDefinition = struct {
    id: []const u8,
    tileRect: TilesetRectangle,
    color: ?i64,
};

// Utility functions
/// Takes std.json.Value and returns std.json.ObjectMap or null
pub fn object(value_opt: ?std.json.Value) ?std.json.ObjectMap {
    const value = value_opt orelse return null;
    return switch (value) {
        .object => |obj| obj,
        else => null,
    };
}

/// Takes std.json.Value and returns std.json.Array or null
pub fn array(value_opt: ?std.json.Value) ?std.json.Array {
    const value = value_opt orelse return null;
    return switch (value) {
        .array => |arr| arr,
        else => null,
    };
}

/// Takes std.json.Value and returns []const u8 or null
pub fn string(value_opt: ?std.json.Value) ?[]const u8 {
    const value = value_opt orelse return null;
    return switch (value) {
        .string => |str| str,
        else => null,
    };
}

/// Takes std.json.Value and returns an error, [][]const u8, or null
pub fn string_list(alloc: std.mem.Allocator, array_opt: ?std.json.Value) ![][]const u8 {
    const arr = array(array_opt) orelse return &[_][]const u8{};
    var list = try std.ArrayList([]const u8).initCapacity(alloc, arr.items.len);
    defer list.deinit();
    for (arr.items) |value| {
        list.appendAssumeCapacity(string(value) orelse return error.InvalidString);
    }
    return list.toOwnedSlice();
}

/// Takes std.json.Value and returns bool or null
pub fn boolean(value_opt: ?std.json.Value) ?bool {
    const value = value_opt orelse return null;
    return switch (value) {
        .bool => |b| b,
        else => null,
    };
}

/// Takes std.json.Value and returns i64 or null
pub fn integer(value_opt: ?std.json.Value) ?i64 {
    const value = value_opt orelse return null;
    return switch (value) {
        .integer => |int| int,
        else => null,
    };
}

/// Takes std.json.Value and returns f64 or null
fn float(value_opt: ?std.json.Value) ?f64 {
    const value = value_opt orelse return null;
    return switch (value) {
        .float => |a_float| a_float,
        // Integers are valid floats
        .integer => |int| @as(f64, @floatFromInt(int)),
        else => null,
    };
}

/// Takes an enum and std.json.Value.
/// Return values:
/// - If the Value is a String it will attempt to convert it into an enum
///     - If the String is not in the enum, null is returned
/// - If the Value is not a String, null is returned
pub fn enum_from_value(comptime T: type, value_opt: ?std.json.Value) ?T {
    const value = value_opt orelse return null;
    return switch (value) {
        .string => |str| std.meta.stringToEnum(T, str),
        else => null,
    };
}

/// Takes std.json.Value and returns [2]i64 or null
pub fn pos_from_value(value_opt: ?std.json.Value) ?[2]i64 {
    const value = array(value_opt) orelse return null;
    const x = integer(value.items[0]) orelse return null;
    const y = integer(value.items[1]) orelse return null;
    return [2]i64{ x, y };
}

/// Takes std.json.Value and returns [2]f64 or null
pub fn posf_from_value(value_opt: ?std.json.Value) ?[2]f64 {
    const value = array(value_opt) orelse return null;
    const x = float(value.items[0]) orelse return null;
    const y = float(value.items[1]) orelse return null;
    return [2]f64{ x, y };
}
