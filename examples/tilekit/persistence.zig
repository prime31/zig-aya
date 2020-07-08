const std = @import("std");
const aya = @import("aya");

const Writer = aya.mem.SdlBufferStream.Writer;
const Reader = aya.mem.SdlBufferStream.Reader;
const Map = @import("data.zig").Map;
const RuleSet = @import("data.zig").RuleSet;
const Rule = @import("data.zig").Rule;
const Tag = @import("data.zig").Tag;
const Object = @import("data.zig").Object;
const Animation = @import("data.zig").Animation;

pub fn save(map: Map, file: []const u8) !void {
    var buf = aya.mem.SdlBufferStream.init(file, .write);
    defer buf.deinit();

    const out = buf.writer();
    try out.writeIntLittle(usize, map.w);
    try out.writeIntLittle(usize, map.h);
    try out.writeIntLittle(usize, map.tile_size);
    try out.writeIntLittle(usize, map.tile_spacing);
    try out.writeIntLittle(usize, map.tile_margin);
    try out.writeIntLittle(usize, map.seed);
    try out.writeIntLittle(usize, map.repeat);
    try out.writeIntLittle(usize, map.image.len);
    try out.writeAll(map.image);

    const data_bytes = std.mem.sliceAsBytes(map.data);
    try out.writeIntLittle(usize, data_bytes.len);
    try out.writeAll(data_bytes);

    // rulesets
    try out.writeIntLittle(usize, map.rulesets.items.len);
    for (map.rulesets.items) |rule| {
        try writeRuleSet(out, rule);
    }

    // pre-rulesets
    try out.writeIntLittle(usize, map.pre_rulesets.items.len);
    for (map.pre_rulesets.items) |rule_page| {
        try out.writeIntLittle(usize, rule_page.items.len);
        for (rule_page.items) |rule| {
            try writeRuleSet(out, rule);
        }
    }

    // tags
    try out.writeIntLittle(usize, map.tags.items.len);
    for (map.tags.items) |tag| {
        try writeFixedSliceZ(out, &tag.name);

        try out.writeIntLittle(usize, tag.tiles.len);
        for (tag.tiles.items) |tile, i| {
            if (i == tag.tiles.len) break;
            try out.writeIntLittle(u8, tile);
        }
    }

    // objects
    try out.writeIntLittle(usize, map.objects.items.len);
    for (map.objects.items) |obj| {
        try writeFixedSliceZ(out, &obj.name);
        try out.writeIntLittle(usize, obj.x);
        try out.writeIntLittle(usize, obj.y);

        try out.writeIntLittle(usize, obj.props.items.len);
        for (obj.props.items) |prop| {
            try writeFixedSliceZ(out, &prop.name);
            try writeUnion(out, prop.value);
        }
    }

    // animations
    try out.writeIntLittle(usize, map.animations.items.len);
    for (map.animations.items) |anim| {
        try out.writeIntLittle(u8, anim.tile);
        try out.writeIntLittle(u16, anim.rate);

        try out.writeIntLittle(usize, anim.tiles.len);
        for (anim.tiles.items) |tile, i| {
            if (i == anim.tiles.len) break;
            try out.writeIntLittle(u8, tile);
        }
    }
}

fn writeRuleSet(out: Writer, rule: RuleSet) !void {
    try writeFixedSliceZ(out, &rule.name);

    for (rule.rules) |rule_tile| {
        try out.writeIntLittle(usize, rule_tile.tile);
        try out.writeIntLittle(u8, @enumToInt(rule_tile.state));
    }

    try out.writeIntLittle(u8, rule.chance);

    try out.writeIntLittle(usize, rule.result_tiles.len);
    for (rule.result_tiles.items) |result_tiles, i| {
        if (i == rule.result_tiles.len) break;
        try out.writeIntLittle(u8, result_tiles);
    }
}

pub fn load(file: []const u8) !Map {
    var buf = aya.mem.SdlBufferStream.init(file, .read);
    defer buf.deinit();

    var map = Map{
        .data = undefined,
        .rulesets = std.ArrayList(RuleSet).init(aya.mem.allocator),
        .pre_rulesets = std.ArrayList(std.ArrayList(RuleSet)).init(aya.mem.allocator),
        .tags = std.ArrayList(Tag).init(aya.mem.allocator),
        .objects = std.ArrayList(Object).init(aya.mem.allocator),
        .animations = std.ArrayList(Animation).init(aya.mem.allocator),
    };

    const in = buf.reader();
    map.w = try in.readIntLittle(usize);
    map.h = try in.readIntLittle(usize);
    map.tile_size = try in.readIntLittle(usize);
    map.tile_spacing = try in.readIntLittle(usize);
    map.tile_margin = try in.readIntLittle(usize);
    map.seed = try in.readIntLittle(u64);
    map.repeat = try in.readIntLittle(u8);

    var image_len = try in.readIntLittle(usize);
    if (image_len > 0) {
        const buffer = try aya.mem.allocator.alloc(u8, image_len);
        _ = try in.readAll(buffer);
        map.image = buffer;
    }

    // map data
    const data_len = try in.readIntLittle(usize);
    map.data = try aya.mem.allocator.alloc(u8, data_len);
    _ = try in.readAll(map.data);

    // rulesets
    const rulesets_len = try in.readIntLittle(usize);
    _ = try map.rulesets.ensureCapacity(rulesets_len);
    var i: usize = 0;
    while (i < rulesets_len) : (i += 1) {
        try map.rulesets.append(try readRuleSet(in));
    }

    // pre rules
    const pre_rules_pages = try in.readIntLittle(usize);
    _ = try map.pre_rulesets.ensureCapacity(pre_rules_pages);
    i = 0;
    while (i < pre_rules_pages) : (i += 1) {
        _ = try map.pre_rulesets.append(std.ArrayList(RuleSet).init(aya.mem.allocator));

        const rules_cnt = try in.readIntLittle(usize);
        _ = try map.pre_rulesets.items[i].ensureCapacity(rules_cnt);
        var j: usize = 0;
        while (j < rules_cnt) : (j += 1) {
            try map.pre_rulesets.items[i].append(try readRuleSet(in));
        }
    }

    // tags
    const tag_cnt = try in.readIntLittle(usize);
    _ = try map.tags.ensureCapacity(tag_cnt);

    i = 0;
    while (i < tag_cnt) : (i += 1) {
        var tag = Tag.init();

        try readFixedSliceZ(in, &tag.name);

        var tile_len = try in.readIntLittle(usize);
        while (tile_len > 0) : (tile_len -= 1) {
            tag.tiles.append(try in.readIntLittle(u8));
        }

        try map.tags.append(tag);
    }

    // objects
    const obj_cnt = try in.readIntLittle(usize);
    _ = try map.objects.ensureCapacity(obj_cnt);

    i = 0;
    while (i < obj_cnt) : (i += 1) {
        var obj = Object.init();

        try readFixedSliceZ(in, &obj.name);
        obj.x = try in.readIntLittle(usize);
        obj.y = try in.readIntLittle(usize);

        var props_len = try in.readIntLittle(usize);
        try obj.props.ensureCapacity(props_len);
        while (props_len > 0) : (props_len -= 1) {
            var prop = Object.Prop.init();
            try readFixedSliceZ(in, &prop.name);
            try readUnionInto(in, &prop.value);
            obj.props.appendAssumeCapacity(prop);
        }

        map.objects.appendAssumeCapacity(obj);
    }

    // animations
    const anim_cnt = try in.readIntLittle(usize);
    _ = try map.animations.ensureCapacity(anim_cnt);

    i = 0;
    while (i < anim_cnt) : (i += 1) {
        var anim = Animation.init(try in.readIntLittle(u8));
        anim.rate = try in.readIntLittle(u16);

        var tile_len = try in.readIntLittle(usize);
        while (tile_len > 0) : (tile_len -= 1) {
            anim.tiles.append(try in.readIntLittle(u8));
        }

        try map.animations.append(anim);
    }

    return map;
}

fn readRuleSet(in: Reader) !RuleSet {
    var rule = RuleSet.init();

    try readFixedSliceZ(in, &rule.name);

    for (rule.rules) |*rule_tile| {
        rule_tile.tile = try in.readIntLittle(usize);
        rule_tile.state = @intToEnum(Rule.RuleState, @intCast(u4, try in.readIntLittle(u8)));
    }

    rule.chance = try in.readIntLittle(u8);

    const selected_len = try in.readIntLittle(usize);
    var i: usize = 0;
    while (i < selected_len) : (i += 1) {
        rule.result_tiles.append(try in.readIntLittle(u8));
    }

    return rule;
}

// generic write helpers
fn writeFixedSliceZ(out: Writer, slice: []const u8) !void {
    const sentinel_index = std.mem.indexOfScalar(u8, slice, 0) orelse slice.len;
    const txt = slice[0..sentinel_index];
    try out.writeIntLittle(usize, txt.len);
    try out.writeAll(txt);
}

fn writeUnion(out: Writer, value: var) !void {
    const info = @typeInfo(@TypeOf(value)).Union;
    if (info.tag_type) |TagType| {
        const active_tag = std.meta.activeTag(value);
        try writeValue(out, active_tag);

        inline for (info.fields) |field_info| {
            if (field_info.enum_field.?.value == @enumToInt(active_tag)) {
                const name = field_info.name;
                const FieldType = field_info.field_type;
                try writeValue(out, @field(value, name));
            }
        }
    }
}

fn writeValue(out: Writer, value: var) !void {
    const T = comptime @TypeOf(value);

    if (comptime std.meta.trait.isIndexable(T)) {
        for (value) |v|
            try writeValue(out, v);
        return;
    }

    switch (@typeInfo(T)) {
        .Int => try out.writeIntLittle(T, value),
        .Float => try out.writeIntLittle(T, value),
        .Enum => try writeValue(out, @enumToInt(value)),
        else => unreachable,
    }
}

// generic read helpers
fn readUnionInto(in: Reader, ptr: var) !void {
    const T = @TypeOf(ptr);
    const C = comptime std.meta.Child(T);
    const info = @typeInfo(C).Union;

    if (info.tag_type) |TagType| {
        const TagInt = @TagType(TagType);
        // TODO: why is this a u2 for PropValue when std.meta.activeTag is a u8? i believe this is due to requiring to write unpacked
        // data (u8 aligned). Reading dies in @divExact in std.mem.readIntNative
        // const tag = try in.readIntLittle(TagInt);
        const tag = try in.readIntLittle(u8);

        inline for (info.fields) |field_info| {
            if (field_info.enum_field.?.value == tag) {
                const name = field_info.name;
                const FieldType = field_info.field_type;
                ptr.* = @unionInit(C, name, undefined);
                try readValueInto(in, &@field(ptr, name));
            }
        }
    }
}

fn readValueInto(in: Reader, ptr: var) !void {
    const T = @TypeOf(ptr);
    comptime std.debug.assert(std.meta.trait.is(.Pointer)(T));

    if (comptime std.meta.trait.isSlice(T) or comptime std.meta.trait.isPtrTo(.Array)(T)) {
        for (ptr) |*v|
            try readValueInto(in, v);
        return;
    }

    comptime std.debug.assert(std.meta.trait.isSingleItemPtr(T));

    const C = comptime std.meta.Child(T);
    const child_type_id = @typeInfo(C);

    switch (child_type_id) {
        .Float, .Int => ptr.* = try in.readIntLittle(C),
        else => unreachable,
    }
}

// generic read helpers
fn readFixedSliceZ(in: Reader, dst: []u8) !void {
    const len = try in.readIntLittle(usize);
    if (len > 0) {
        const buffer = try aya.mem.tmp_allocator.alloc(u8, len);
        _ = try in.readAll(buffer);
        std.mem.copy(u8, dst, buffer);
    }
}

// export
pub fn exportJson(map: Map, map_data: []u8, file: []const u8) !void {
    var buf = aya.mem.SdlBufferStream.init(file, .write);
    defer buf.deinit();
    const out_stream = buf.writer();

    var jw = std.json.writeStream(out_stream, 10);
    {
        try jw.beginObject();
        defer jw.endObject() catch unreachable;

        try jw.objectField("w");
        try jw.emitNumber(map.w);

        try jw.objectField("h");
        try jw.emitNumber(map.h);

        try jw.objectField("tile_size");
        try jw.emitNumber(map.tile_size);

        try jw.objectField("tile_spacing");
        try jw.emitNumber(map.tile_spacing);

        try jw.objectField("tile_margin");
        try jw.emitNumber(map.tile_margin);

        try jw.objectField("image");
        try jw.emitString(map.image);

        // tags
        try jw.objectField("tags");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (map.tags.items) |tag| {
                try jw.arrayElem();
                try jw.beginObject();

                const sentinel_index = std.mem.indexOfScalar(u8, &tag.name, 0) orelse tag.name.len;
                const name = tag.name[0..sentinel_index];
                try jw.objectField("name");
                try jw.emitString(name);

                try jw.objectField("tiles");
                try jw.beginArray();
                for (tag.tiles.items) |tile, i| {
                    if (i == tag.tiles.len) break;
                    try jw.arrayElem();
                    try jw.emitNumber(tile);
                }
                try jw.endArray();

                try jw.endObject();
            }
        }

        // objects
        try jw.objectField("objects");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (map.objects.items) |obj| {
                try jw.arrayElem();
                try jw.beginObject();

                const sentinel_index = std.mem.indexOfScalar(u8, &obj.name, 0) orelse obj.name.len;
                try jw.objectField("name");
                try jw.emitString(obj.name[0..sentinel_index]);

                try jw.objectField("x");
                try jw.emitNumber(obj.x);

                try jw.objectField("y");
                try jw.emitNumber(obj.y);

                for (obj.props.items) |prop| {
                    const prop_sentinel_index = std.mem.indexOfScalar(u8, &prop.name, 0) orelse prop.name.len;
                    try jw.objectField(prop.name[0..prop_sentinel_index]);

                    switch (prop.value) {
                        .string => |str| {
                            const prop_value_sentinel_index = std.mem.indexOfScalar(u8, &str, 0) orelse str.len;
                            try jw.emitString(str[0..prop_value_sentinel_index]);
                        },
                        .int => |int| try jw.emitNumber(int),
                        .float => |float| try jw.emitNumber(float),
                    }
                }

                try jw.endObject();
            }
        }

        // animations
        try jw.objectField("animations");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (map.animations.items) |anim| {
                try jw.arrayElem();
                try jw.beginObject();

                try jw.objectField("tile");
                try jw.emitNumber(anim.tile);

                try jw.objectField("rate");
                try jw.emitNumber(anim.rate);

                try jw.objectField("tiles");
                try jw.beginArray();
                for (anim.tiles.items) |tile, i| {
                    if (i == anim.tiles.len) break;
                    try jw.arrayElem();
                    try jw.emitNumber(tile);
                }
                try jw.endArray();

                try jw.endObject();
            }
        }

        // map data
        try jw.objectField("data");
        try jw.beginArray();
        for (map_data) |d| {
            try jw.arrayElem();
            try jw.emitNumber(d);
        }
        try jw.endArray();
    }
}
