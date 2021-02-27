const std = @import("std");
const aya = @import("aya");
const root = @import("main.zig");
const data = @import("data/data.zig");
const components = @import("data/components.zig");
const AppState = data.AppState;

/// AppState mirror that contains just the fields that should be persisted
const AppStateJson = struct {
    tile_size: usize,
    snap_size: u8,
    clear_color: u32,
    bg_color: u32,
    components: []components.Component,
    next_component_id: u8 = 0,
    selected_layer_index: usize = 0,

    pub fn init(state: *AppState) AppStateJson {
        return .{
            .tile_size = state.tile_size,
            .snap_size = state.snap_size,
            .clear_color = state.clear_color.value,
            .bg_color = state.bg_color.value,
            .components = state.components.items,
            .next_component_id = state.next_component_id,
            .selected_layer_index = state.selected_layer_index,
        };
    }
};

const LevelJson = struct {
    name: []const u8,
    map_size: data.Size,
    layers: []LayerJson,

    pub fn init(level: data.Level) LevelJson {
        var layers = aya.mem.tmp_allocator.alloc(LayerJson, level.layers.items.len) catch unreachable;
        for (level.layers.items) |src_level, i| {
            layers[i] = switch (src_level) {
                .tilemap => |layer| .{ .tilemap = TilemapLayerJson.init(layer) },
                .auto_tilemap => |layer| .{ .auto_tilemap = AutoTilemapLayerJson.init(layer) },
                .entity => |layer| .{ .entity = EntityLayerJson.init(layer) },
            };
        }

        return .{
            .name = level.name,
            .map_size = level.map_size,
            .layers = layers,
        };
    }
};

const LayerJson = union(root.layers.LayerType) {
    tilemap: TilemapLayerJson,
    auto_tilemap: AutoTilemapLayerJson,
    entity: EntityLayerJson,
};

const TilemapLayerJson = struct {
    name: []u8 = undefined,
    visible: bool,
    tilemap: data.Tilemap,
    tileset: []const u8,

    pub fn init(tilemap: root.layers.TilemapLayer) TilemapLayerJson {
        return .{
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.spanZ(&tilemap.name)) catch unreachable,
            .visible = tilemap.visible,
            .tilemap = tilemap.tilemap,
            .tileset = aya.mem.tmp_allocator.dupe(u8, std.mem.span(tilemap.tileset.tex_name)) catch unreachable,
        };
    }
};

const AutoTilemapLayerJson = struct {
    name: []u8 = undefined,
    visible: bool = true,
    tilemap: data.Tilemap,
    tileset: []const u8,
    ruleset: RuleSetJson,
    // ruleset_groups: std.AutoHashMap(u8, []const u8),

    pub fn init(layer: root.layers.AutoTilemapLayer) AutoTilemapLayerJson {
        return .{
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.spanZ(&layer.name)) catch unreachable,
            .visible = layer.visible,
            .tilemap = layer.tilemap,
            .tileset = layer.tileset.tex_name,
            .ruleset = RuleSetJson.init(layer.ruleset),
            // .rulseset_groups = BBB,
        };
    }
};

const RuleSetJson = struct {
    seed: u64,

    pub fn init(ruleset: data.RuleSet) RuleSetJson {
        return .{
            .seed = ruleset.seed,
        };
    }
};

const EntityLayerJson = struct {
    name: []u8,
    visible: bool,
    entities: []EntityJson,
    id_counter: u8,

    pub fn init(layer: root.layers.EntityLayer) EntityLayerJson {
        var entities = aya.mem.tmp_allocator.alloc(EntityJson, layer.entities.items.len) catch unreachable;
        for (layer.entities.items) |entity, i| entities[i] = EntityJson.init(entity);

        return .{
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.spanZ(&layer.name)) catch unreachable,
            .visible = layer.visible,
            .entities = entities,
            .id_counter = layer.id_counter,
        };
    }
};

const SpriteJson = struct {
    rect: aya.math.RectI,
    tex_name: []u8,
    origin: aya.math.Vec2,

    pub fn init(sprite: data.Sprite) SpriteJson {
        return .{
            .rect = sprite.rect,
            .tex_name = aya.mem.tmp_allocator.dupe(u8, sprite.tex_name) catch unreachable,
            .origin = sprite.origin,
        };
    }
};

const EntityJson = struct {
    id: u8 = 0,
    name: []u8 = undefined,
    selectable: bool = true,
    // components: std.ArrayList(ComponentInstance),
    transform: data.Transform,
    sprite: ?SpriteJson = null,
    collider: ?data.Collider = null,

    pub fn init(entity: data.Entity) EntityJson {
        return .{
            .id = entity.id,
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.spanZ(&entity.name)) catch unreachable,
            .selectable = entity.selectable,
            // .components = ,
            .transform = entity.transform,
            .sprite = if (entity.sprite) |sprite| SpriteJson.init(sprite) else null,
            .collider = entity.collider,
        };
    }
};

fn fart(state: *AppState) !void {
    var handle = try std.fs.cwd().createFile("project2.json", .{});

    const state_json = AppStateJson.init(state);
    try std.json.stringify(state_json, .{}, handle.writer());
    handle.close();

    // and back
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, "project2.json");
    var res = try std.json.parse(AppStateJson, &std.json.TokenStream.init(bytes), .{ .allocator = aya.mem.allocator });

    for (res.components) |comp| {
        std.log.info("{s}", .{comp.name});
        for (comp.props) |prop| {
            std.log.info("    name: {s}, val: {s}", .{ prop.name, prop.value });
        }
    }
}

pub fn saveLevelFart(level: data.Level) !void {
    const filename = try std.fmt.allocPrint(aya.mem.tmp_allocator, "levels/{s}_2.json", .{std.mem.span(level.name)});

    var handle = try std.fs.cwd().createFile(filename, .{});
    const level_json = LevelJson.init(level);
    try std.json.stringify(level_json, .{}, handle.writer());
    handle.close();
    
    // and back
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, filename);
    var res = try std.json.parse(LevelJson, &std.json.TokenStream.init(bytes), .{ .allocator = aya.mem.allocator });

    std.log.info("{any}", .{res});

    for (res.layers) |layer| {
        if (layer == .entity) {
            std.log.info("{any}", .{layer.entity});
            for (layer.entity.entities) |e| std.log.info("{any}", .{e.collider});
        } else {
            std.log.info("name: {s}, layer: {any}", .{ layer, std.meta.activeTag(layer) });
        }
    }
}

pub fn saveProject(state: *AppState) !void {
    try fart(state);

    var handle = try std.fs.cwd().createFile("project.json", .{});
    defer handle.close();
    const out_stream = handle.writer();

    var jw = std.json.writeStream(out_stream, 10);
    try jw.beginObject();

    try writeNumber(&jw, "tile_size", state.tile_size);
    try writeNumber(&jw, "snap_size", state.snap_size);
    try writeNumber(&jw, "clear_color", state.clear_color.value);
    try writeNumber(&jw, "bg_color", state.bg_color.value);
    try writeNumber(&jw, "next_component_id", state.next_component_id);

    try jw.objectField("components");
    try jw.beginArray();
    for (state.components.items) |component| {
        try jw.arrayElem();
        try jw.beginObject();

        try writeNumber(&jw, "id", component.id);
        try writeString(&jw, "name", &component.name);
        try writeNumber(&jw, "next_property_id", component.next_property_id);

        try jw.objectField("props");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (component.props) |prop| {
                try jw.arrayElem();
                try jw.beginObject();

                try writeNumber(&jw, "id", prop.id);
                try writeString(&jw, "name", &prop.name);
                try writePropertyValue(&jw, prop.value);

                try jw.endObject();
            }
        }

        try jw.endObject();
    }
    try jw.endArray();

    try jw.endObject();
}

fn writeValue(value: anytype, writer: anytype) !void {
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        .Float, .Int, .ComptimeInt, .ComptimeFloat => try writer.emitNumber(value),
        .Bool => try writer.emitBool(value),
        .Struct => |S| {
            if (T == aya.math.Vec2) {
                try writer.beginObject();
                try writer.objectField("x");
                try writer.emitNumber(value.x);
                try writer.objectField("y");
                try writer.emitNumber(value.y);
                try writer.endObject();
            } else {
                @compileError("Unable to write struct type " ++ @typeName(T));
            }
        },
        else => @compileError("Unable to write type " ++ @typeName(T)),
    }
}

fn writeNumber(writer: anytype, field_name: []const u8, value: anytype) !void {
    try writer.objectField(field_name);
    try writeValue(value, writer);
}

fn writeBool(writer: anytype, field_name: []const u8, value: bool) !void {
    try writer.objectField(field_name);
    try writeValue(value, writer);
}

fn writeString(writer: anytype, field_name: []const u8, string: [:0]const u8) !void {
    const sentinel = std.mem.indexOfScalar(u8, string, 0) orelse string.len;
    const str = string[0..sentinel];
    try writer.objectField(field_name);
    try writer.emitString(str);
}

fn writePropertyValue(writer: anytype, value: components.PropertyValue) !void {
    try writer.objectField("property");
    try writer.beginObject();

    const tag = std.meta.activeTag(value);
    try writer.objectField("type");
    try writer.emitString(@tagName(tag));

    try writer.objectField("value");
    switch (value) {
        .string => |str| {
            const sentinel = std.mem.indexOfScalar(u8, &str, 0) orelse str.len;
            try writer.emitString(str[0..sentinel]);
        },
        .int => |i| try writeValue(i, writer),
        .float => |f| try writeValue(f, writer),
        .bool => |b| try writeValue(b, writer),
        .vec2 => |v| try writeValue(v, writer),
        .enum_values => |vals| {
            try writer.beginArray();
            for (vals) |val| {
                try writer.arrayElem();
                const sentinel = std.mem.indexOfScalar(u8, &val, 0) orelse val.len;
                try writer.emitString(val[0..sentinel]);
            }
            try writer.endArray();
        },
        .entity_link => |l| try writeValue(l, writer),
    }

    try writer.endObject();
}

pub fn loadProject(path: []const u8) !AppState {
    var state = AppState.init();

    return state;
}

// level save/load
pub fn saveLevel(level: data.Level) !void {
    try saveLevelFart(level);
    const filename = try std.fmt.allocPrint(aya.mem.tmp_allocator, "levels/{s}.json", .{std.mem.span(level.name)});

    var handle = try std.fs.cwd().createFile(filename, .{});
    defer handle.close();
    const out_stream = handle.writer();
    var jw = std.json.writeStream(out_stream, 10);

    try jw.beginObject();
    try writeNumber(&jw, "width", level.map_size.w);
    try writeNumber(&jw, "height", level.map_size.h);

    try jw.objectField("layers");
    try jw.beginArray();

    for (level.layers.items) |layer| {
        try jw.arrayElem();
        try jw.beginObject();

        try jw.objectField("type");
        try jw.emitString(@tagName(std.meta.activeTag(layer)));
        try writeString(&jw, "name", &layer.name());
        try writeBool(&jw, "visible", layer.visible());

        try switch (layer) {
            .tilemap => |tilemap| writeTilemapLayer(&jw, tilemap),
            .auto_tilemap => |auto_tilemap| writeAutoTilemapLayer(&jw, auto_tilemap),
            .entity => |entity| writeEntityLayer(&jw, entity),
        };
        try jw.endObject();
    }

    try jw.endArray();
    try jw.endObject();
}

fn writeTilemapLayer(writer: anytype, layer: root.layers.TilemapLayer) !void {
    try writer.objectField("tilemap");
    try writeTilemap(writer, layer.tilemap);

    try writer.objectField("tileset");
    try writeTileset(writer, layer.tileset);
}

fn writeAutoTilemapLayer(writer: anytype, layer: root.layers.AutoTilemapLayer) !void {}

fn writeEntityLayer(writer: anytype, layer: root.layers.EntityLayer) !void {}

fn writeTilemap(writer: anytype, tilemap: data.Tilemap) !void {
    try writer.beginObject();
    try writer.objectField("data");
    try writer.beginArray();

    for (tilemap.data) |tile| {
        try writer.arrayElem();
        try writer.emitNumber(tile);
    }

    try writer.endArray();
    try writer.endObject();
}

fn writeTileset(writer: anytype, tileset: data.Tileset) !void {
    try writer.beginObject();

    try writer.objectField("tex_name");
    try writer.emitString(tileset.tex_name);

    try writer.objectField("tile_definitions");
    try writer.beginObject();
    inline for (std.meta.fields(@TypeOf(tileset.tile_definitions))) |field| {
        try writeFixedList(writer, field.name, @field(tileset.tile_definitions, field.name));
    }
    try writer.endObject();

    try writer.objectField("animations");
    try writer.beginArray();
    for (tileset.animations.items) |ani| {
        try writer.arrayElem();
        try writer.beginObject();
        try writeNumber(writer, "tile", ani.tile);
        try writeNumber(writer, "rate", ani.rate);
        try writeFixedList(writer, "tiles", ani.tiles);
        try writer.endObject();
    }
    try writer.endArray();

    try writer.endObject();
}

fn writeFixedList(writer: anytype, field_name: []const u8, list: anytype) !void {
    try writer.objectField(field_name);
    try writer.beginArray();

    var i: usize = 0;
    while (i < list.len) : (i += 1) {
        try writer.arrayElem();
        try writer.emitNumber(list.items[i]);
    }

    try writer.endArray();
}
