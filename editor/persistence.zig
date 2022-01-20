const std = @import("std");
const aya = @import("aya");
const root = @import("main.zig");
const data = @import("data/data.zig");
const components = @import("data/components.zig");
const AppState = data.AppState;

// TODO: all the toOwned* methods should cleanup memory they dont need

/// AppState mirror that contains just the fields that should be persisted
const AppStateJson = struct {
    tile_size: usize,
    snap_size: u8,
    clear_color: u32,
    bg_color: u32,
    components: []components.Component,
    next_component_id: u8 = 0,
    selected_layer_index: usize = 0,
    loaded_level: []const u8,

    pub fn init(state: *AppState) AppStateJson {
        return .{
            .tile_size = state.tile_size,
            .snap_size = state.snap_size,
            .clear_color = state.clear_color.value,
            .bg_color = state.bg_color.value,
            .components = state.components.items,
            .next_component_id = state.next_component_id,
            .selected_layer_index = state.selected_layer_index,
            .loaded_level = state.level.name,
        };
    }

    pub fn toOwnedAppState(self: AppStateJson) !AppState {
        const level = try loadLevel(self.loaded_level);
        var state = AppState.initWithLevel(level);
        state.tile_size = self.tile_size;
        state.snap_size = self.snap_size;
        state.clear_color = aya.math.Color{ .value = self.clear_color };
        state.bg_color = aya.math.Color{ .value = self.bg_color };
        state.components = std.ArrayList(components.Component).fromOwnedSlice(aya.mem.allocator, self.components);
        state.next_component_id = self.next_component_id;
        state.selected_layer_index = self.selected_layer_index;
        return state;
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

    pub fn toOwnedLevel(self: @This()) data.Level {
        var layers = aya.mem.allocator.alloc(root.layers.Layer, self.layers.len) catch unreachable;
        for (self.layers) |src_layer, i| {
            layers[i] = switch (src_layer) {
                .tilemap => |layer| .{ .tilemap = TilemapLayerJson.toOwnedTilemapLayer(layer) },
                .auto_tilemap => |layer| .{ .auto_tilemap = AutoTilemapLayerJson.toOwnedAutoTilemapLayer(layer) },
                .entity => |layer| .{ .entity = EntityLayerJson.toOwnedEntityLayer(layer) },
            };
        }
        aya.mem.allocator.free(self.layers);

        return .{
            .name = self.name,
            .map_size = self.map_size,
            .layers = std.ArrayList(root.layers.Layer).fromOwnedSlice(aya.mem.allocator, layers),
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
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.span(&tilemap.name)) catch unreachable,
            .visible = tilemap.visible,
            .tilemap = tilemap.tilemap,
            .tileset = aya.mem.tmp_allocator.dupe(u8, std.mem.span(tilemap.tileset.tex_name)) catch unreachable,
        };
    }

    pub fn toOwnedTilemapLayer(self: @This()) root.layers.TilemapLayer {
        var name: [25:0]u8 = undefined;
        aya.mem.copyZ(u8, &name, self.name);
        return .{
            .name = name,
            .visible = self.visible,
            .tilemap = self.tilemap,
            .tileset = data.Tileset.init(16), // TODO: dont hardcode tile size
        };
    }
};

const AutoTilemapLayerJson = struct {
    name: []u8 = undefined,
    visible: bool = true,
    tilemap: data.Tilemap,
    tileset: []const u8,
    ruleset: RuleSetJson,
    ruleset_groups: []RulesetGroup, // convert the HashMap into a slice of key/value pairs

    const RulesetGroup = struct {
        id: u8,
        name: []const u8,
    };

    pub fn init(layer: root.layers.AutoTilemapLayer) AutoTilemapLayerJson {
        var ruleset_groups = aya.mem.tmp_allocator.alloc(RulesetGroup, layer.ruleset_groups.count()) catch unreachable;

        var i: usize = 0;
        var iter = layer.ruleset_groups.iterator();
        while (iter.next()) |kv| {
            ruleset_groups[i] = .{ .id = kv.key_ptr.*, .name = kv.value_ptr.* };
            i += 1;
        }

        return .{
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.span(&layer.name)) catch unreachable,
            .visible = layer.visible,
            .tilemap = layer.tilemap,
            .tileset = layer.tileset.tex_name,
            .ruleset = RuleSetJson.init(layer.ruleset),
            .ruleset_groups = ruleset_groups,
        };
    }

    pub fn toOwnedAutoTilemapLayer(self: @This()) root.layers.AutoTilemapLayer {
        var name: [25:0]u8 = undefined;
        aya.mem.copyZ(u8, &name, self.name);

        var ruleset_groups = std.AutoHashMap(u8, []const u8).init(aya.mem.allocator);
        for (self.ruleset_groups) |group| ruleset_groups.put(group.id, group.name) catch unreachable;

        var tmp_data = aya.mem.allocator.alloc(u16, self.tilemap.data.len) catch unreachable;
        std.mem.set(u16, tmp_data, 0);

        return .{
            .name = name,
            .visible = self.visible,
            .tilemap = self.tilemap,
            .final_map = tmp_data,
            .random_map_data = aya.mem.allocator.alloc(root.layers.AutoTilemapLayer.Randoms, self.tilemap.data.len) catch unreachable,
            .brushset = data.Brushset.init(16), // TODO: dont make up tile size
            .tileset = data.Tileset.init(16), // TODO: load the real Tileset
            .ruleset = self.ruleset.toOwnedRuleSet(),
            .ruleset_groups = ruleset_groups,
        };
    }
};

const RuleSetJson = struct {
    seed: u64,
    rules: []RuleJson,

    pub fn init(ruleset: data.RuleSet) RuleSetJson {
        var rules = aya.mem.tmp_allocator.alloc(RuleJson, ruleset.rules.items.len) catch unreachable;
        for (ruleset.rules.items) |rule, i| rules[i] = RuleJson.init(rule);

        return .{
            .seed = ruleset.seed,
            .rules = rules,
        };
    }

    pub fn toOwnedRuleSet(self: @This()) data.RuleSet {
        var ruleset = data.RuleSet.init();
        ruleset.seed = self.seed;

        for (self.rules) |rule| {
            var new_rule = data.Rule.init();
            std.mem.copy(u8, &new_rule.name, rule.name);
            new_rule.rule_tiles = rule.rule_tiles;
            new_rule.chance = rule.chance;
            new_rule.result_tiles.items = rule.result_tiles;
            new_rule.group = rule.group;
            ruleset.rules.append(new_rule) catch unreachable;
        }
        return ruleset;
    }
};

const RuleJson = struct {
    name: []const u8,
    rule_tiles: [25]data.RuleTile,
    chance: u8 = 100,
    result_tiles: [25]u8,
    group: u8 = 0,

    pub fn init(rule: data.Rule) RuleJson {
        return .{
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.span(&rule.name)) catch unreachable,
            .rule_tiles = rule.rule_tiles,
            .chance = rule.chance,
            .result_tiles = rule.result_tiles.items,
            .group = rule.group,
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
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.span(&layer.name)) catch unreachable,
            .visible = layer.visible,
            .entities = entities,
            .id_counter = layer.id_counter,
        };
    }

    pub fn toOwnedEntityLayer(self: @This()) root.layers.EntityLayer {
        var name: [25:0]u8 = undefined;
        aya.mem.copyZ(u8, &name, self.name);

        var entities = std.ArrayList(data.Entity).initCapacity(aya.mem.allocator, self.entities.len) catch unreachable;
        for (self.entities) |entity| entities.appendAssumeCapacity(entity.toOwnedEntity());

        return .{
            .name = name,
            .visible = self.visible,
            .entities = entities,
            .id_counter = self.id_counter,
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
    components: []ComponentInstanceJson,
    transform: data.Transform,
    sprite: ?SpriteJson = null,
    collider: ?data.Collider = null,

    pub fn init(entity: data.Entity) EntityJson {
        var comps = aya.mem.tmp_allocator.alloc(ComponentInstanceJson, entity.components.items.len) catch unreachable;
        for (entity.components.items) |comp, i| comps[i] = ComponentInstanceJson.init(comp);

        return .{
            .id = entity.id,
            .name = aya.mem.tmp_allocator.dupe(u8, std.mem.span(&entity.name)) catch unreachable,
            .selectable = entity.selectable,
            .components = comps,
            .transform = entity.transform,
            .sprite = if (entity.sprite) |sprite| SpriteJson.init(sprite) else null,
            .collider = entity.collider,
        };
    }

    pub fn toOwnedEntity(self: @This()) data.Entity {
        var entity = data.Entity{
            .id = self.id,
            .selectable = self.selectable,
            .components = std.ArrayList(data.ComponentInstance).initCapacity(aya.mem.allocator, self.components.len) catch unreachable,
            .transform = self.transform,
            .collider = self.collider,
        };
        aya.mem.copyZ(u8, &entity.name, self.name);

        for (self.components) |comp| entity.components.appendAssumeCapacity(.{
            .component_id = comp.component_id,
            .props = std.ArrayList(components.PropertyInstance).fromOwnedSlice(aya.mem.allocator, comp.props),
        });

        if (self.sprite) |sprite| {
            const tex_name = aya.mem.allocator.dupeZ(u8, sprite.tex_name) catch unreachable;
            const tex_rect = root.state.asset_man.getTextureAndRect(tex_name);
            entity.sprite = .{
                .tex = tex_rect.tex,
                .rect = sprite.rect,
                .tex_name = tex_name,
                .origin = sprite.origin,
            };
        }

        return entity;
    }
};

const ComponentInstanceJson = struct {
    component_id: u8,
    props: []components.PropertyInstance,

    pub fn init(comp: data.ComponentInstance) ComponentInstanceJson {
        return .{ .component_id = comp.component_id, .props = comp.props.items };
    }
};

pub fn saveProject(state: *AppState) !void {
    var handle = try std.fs.cwd().createFile("project2.json", .{});

    const state_json = AppStateJson.init(state);
    try std.json.stringify(state_json, .{}, handle.writer());
    handle.close();

    // and back
    @setEvalBranchQuota(2000);
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, "project2.json");
    var res = try std.json.parse(AppStateJson, &std.json.TokenStream.init(bytes), .{ .allocator = aya.mem.allocator });

    for (res.components) |comp| {
        std.log.info("{s}", .{comp.name});
        for (comp.props) |prop| {
            std.log.info("    name: {s}, val: {s}", .{ prop.name, prop.value });
        }
    }
}

pub fn loadProject(path: []const u8) !AppState {
    _ = path;
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, "project2.json");
    var state = try std.json.parse(AppStateJson, &std.json.TokenStream.init(bytes), .{ .allocator = aya.mem.allocator });
    return state.toOwnedAppState();
}

pub fn saveLevel(level: data.Level) !void {
    const filename = try std.fmt.allocPrint(aya.mem.tmp_allocator, "levels/{s}.json", .{std.mem.span(level.name)});

    var handle = try std.fs.cwd().createFile(filename, .{});
    const level_json = LevelJson.init(level);
    try std.json.stringify(level_json, .{}, handle.writer());
    handle.close();
}

pub fn loadLevel(name: []const u8) !data.Level {
    const filename = try std.fmt.allocPrint(aya.mem.tmp_allocator, "levels/{s}", .{name});
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, filename);
    @setEvalBranchQuota(2000);
    var level_json = try std.json.parse(LevelJson, &std.json.TokenStream.init(bytes), .{ .allocator = aya.mem.allocator });
    return level_json.toOwnedLevel();
}

fn manuallySaveProject(state: *AppState) !void {
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
        .Struct => |_| {
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

// level save/load
fn manuallySaveLevel(level: data.Level) !void {
    // try saveLevelFart(level);
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

fn writeAutoTilemapLayer(writer: anytype, layer: root.layers.AutoTilemapLayer) !void {
    _ = writer;
    _ = layer;
}

fn writeEntityLayer(writer: anytype, layer: root.layers.EntityLayer) !void {
    _ = writer;
    _ = layer;
}

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
