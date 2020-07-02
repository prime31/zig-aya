const std = @import("std");
const aya = @import("aya");

const Writer = aya.mem.SdlBufferStream.Writer;
const Reader = aya.mem.SdlBufferStream.Reader;
const Map = @import("data.zig").Map;
const RuleSet = @import("data.zig").RuleSet;
const Rule = @import("data.zig").Rule;

pub fn save(map: Map, file: []const u8) !void {
    var buf = aya.mem.SdlBufferStream.init(file, .write);
    defer buf.deinit();

    const out = buf.writer();
    try out.writeIntLittle(usize, map.w);
    try out.writeIntLittle(usize, map.h);
    try out.writeIntLittle(usize, map.tile_size);
    try out.writeIntLittle(usize, map.tile_spacing);
    try out.writeIntLittle(usize, map.image.len);
    try out.writeAll(map.image);

    const data_bytes = std.mem.sliceAsBytes(map.data);
    try out.writeIntLittle(usize, data_bytes.len);
    try out.writeAll(data_bytes);

    try out.writeIntLittle(usize, map.rulesets.items.len);
    for (map.rulesets.items) |rule| {
        try writeRuleSet(out, rule);
    }

    try out.writeIntLittle(usize, map.pre_rulesets.items.len);
    for (map.pre_rulesets.items) |rule_page| {
        try out.writeIntLittle(usize, rule_page.items.len);
        for (rule_page.items) |rule| {
            try writeRuleSet(out, rule);
        }
    }
}

fn writeRuleSet(out: Writer, rule: RuleSet) !void {
    const name = rule.name[0..std.mem.indexOfSentinel(u8, 0, rule.name[0..])];
    try out.writeIntLittle(usize, name.len);
    try out.writeAll(name);

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
    };

    // std.mem.bytesAsValue for reading f32
    const in = buf.reader();
    map.w = try in.readIntLittle(usize);
    map.h = try in.readIntLittle(usize);
    map.tile_size = try in.readIntLittle(usize);
    map.tile_spacing = try in.readIntLittle(usize);

    var image_len = try in.readIntLittle(usize);
    if (image_len > 0) {
        const buffer = try aya.mem.tmp_allocator.alloc(u8, image_len);
        _ = try in.readAll(buffer);
        map.image = buffer;
    }

    const data_len = try in.readIntLittle(usize);
    map.data = try aya.mem.allocator.alloc(u8, data_len);
    _ = try in.readAll(map.data);

    const rules_len = try in.readIntLittle(usize);
    _ = try map.rulesets.ensureCapacity(rules_len);
    var i: usize = 0;
    while (i < rules_len) : (i += 1) {
        try map.rulesets.append(try readRuleSet(in));
    }

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

    return map;
}

fn readRuleSet(in: Reader) !RuleSet {
    var rule = RuleSet.init();

    const name_len = try in.readIntLittle(usize);
    const buffer = try aya.mem.tmp_allocator.alloc(u8, name_len);
    _ = try in.readAll(buffer);
    std.mem.copy(u8, rule.name[0..], buffer);

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
