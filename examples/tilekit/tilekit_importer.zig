const std = @import("std");
const aya = @import("aya");
const ayatile = @import("tilekit.zig");

pub fn import(file: []const u8) !ayatile.Map {
    var bytes = try std.fs.cwd().readFileAlloc(aya.mem.allocator, file, std.math.maxInt(usize));
    var tokens = std.json.TokenStream.init(bytes);

    const options = std.json.ParseOptions{ .allocator = aya.mem.allocator };
    var res = try std.json.parse(TileKitMap, &tokens, options);
    defer std.json.parseFree(TileKitMap, res, options);

    var map = ayatile.Map.init(res.output_map.tile_w, res.output_map.tile_spacing);
    map.w = res.input_map.w;
    map.h = res.input_map.h;
    map.image = try std.mem.dupe(aya.mem.allocator, u8, res.output_map.image_filename);

    aya.mem.allocator.free(map.data);
    map.data = try aya.mem.allocator.alloc(u8, map.w * map.h);
    std.mem.copy(u8, map.data, res.input_map.data);

    for (res.final_ruleset.rules) |rule| {
        try map.ruleset.append(rule.toAyaRuleSet());
    }

    for (res.rulesets) |ruleset| {
        map.addPreRulesPage();
        var pre_ruleset = &map.pre_rulesets.items[map.pre_rulesets.items.len - 1];

        for (ruleset.rules) |rule| {
            try pre_ruleset.append(rule.toAyaRuleSet());
        }
    }

    return map;
}

pub const TileKitMap = struct {
    brush_idx: usize,
    ruleset_idx: i32,
    show_animations: bool,
    input_map: InputMap,
    output_map: OutputMap,
    final_ruleset: RuleSet,
    rulesets: []RuleSet,
    objects: []Object,
    edit_mode: u8,

    pub const InputMap = struct {
        w: usize,
        h: usize,
        data: []u8,
    };

    pub const OutputMap = struct {
        tile_w: usize,
        tile_h: usize,
        tile_spacing: usize,
        image_filename: []const u8,
        animations: []Animation,
        tags: []Tag,
    };

    pub const RuleSet = struct {
        seed: usize,
        repeat: u8,
        rules: []Rule,
    };

    pub const Rule = struct {
        label: []const u8,
        chance: u8,
        offsets: []RuleOffsets,
        results: []u8,

       pub fn toAyaRuleSet(self: @This()) ayatile.data.Rule {
            var ruleset = ayatile.data.Rule.init();
            std.mem.copy(u8, &ruleset.name, self.label);
            ruleset.chance = self.chance;

            for (self.results) |tile| {
                ruleset.result_tiles.append(tile - 1);
            }

            for (self.offsets) |offset| {
                var rule_tile = ruleset.get(@intCast(usize, offset.x + 2), @intCast(usize, offset.y + 2));
                if (offset.type == 1) {
                    rule_tile.require(offset.val);
                } else if (offset.type == 2) {
                    rule_tile.negate(offset.val);
                } else {
                    rule_tile.tile = offset.val;
                }
            }

            return ruleset;
        }
    };

    pub const RuleOffsets = struct {
        x: i32,
        y: i32,
        val: usize,
        type: u8,
    };

    pub const Animation = struct {
        idx: usize,
        rate: usize,
        frames: []u8,
    };

    pub const Object = struct {
        name: []const u8,
        id: usize,
        x: u8,
        y: u8,
        w: u8,
        h: u8,
    };

    pub const Tag = struct {
        label: []const u8,
        tiles: []u8,
    };
};
