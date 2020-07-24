const std = @import("std");
const aya = @import("aya");
const data = @import("map.zig");

// var simple_map = @import("runtime_map.zig").Map.init(state.map);
// simple_map.saveAsJson("/Users/desaro/Desktop/hi.json");
// var buf = aya.mem.SdlBufferStream.init("/Users/desaro/Desktop/hi.json", .write);
// try std.json.stringify(simple_map, .{ .whitespace = .{} }, buf.writer());
// simple_map.deinit();

pub const Map = struct {
    w: usize,
    h: usize,
    tile_size: usize,
    tile_spacing: usize,
    image: []const u8,
    data: []u8,
    ruleset: RuleSet,
    pre_rulesets: []RuleSet,
    tags: []Tag,
    objects: []Object,
    animations: []Animation,

    pub fn init(orig: data.Map) Map {
        var map = .{
            .w = orig.w,
            .h = orig.h,
            .tile_size = orig.tile_size,
            .tile_spacing = orig.tile_spacing,
            .image = aya.mem.allocator.dupe(u8, orig.image) catch unreachable,
            .data = aya.mem.allocator.alloc(u8, orig.w * orig.h) catch unreachable,
            .ruleset = RuleSet.init(orig.ruleset),
            .pre_rulesets = aya.mem.allocator.alloc(RuleSet, orig.pre_rulesets.items.len) catch unreachable,
            .tags = aya.mem.allocator.alloc(Tag, orig.tags.items.len) catch unreachable,
            .objects = aya.mem.allocator.alloc(Object, orig.objects.items.len) catch unreachable,
            .animations = aya.mem.allocator.alloc(Animation, orig.animations.items.len) catch unreachable,
        };

        for (orig.pre_rulesets.items) |ruleset, i| {
            map.pre_rulesets[i] = RuleSet.init(ruleset);
        }

        for (orig.tags.items) |tag, i| {
            map.tags[i] = Tag.init(tag);
        }

        for (orig.objects.items) |obj, i| {
            map.objects[i] = Object.init(obj);
        }

        for (orig.animations.items) |anim, i| {
            map.animations[i] = Animation.init(anim);
        }

        return map;
    }

    pub fn deinit(self: Map) void {
        aya.mem.allocator.free(self.image);
        aya.mem.allocator.free(self.data);
        self.ruleset.deinit();

        for (self.pre_rulesets) |ruleset| {
            ruleset.deinit();
        }
        aya.mem.allocator.free(self.pre_rulesets);

        for (self.tags) |tag| {
            tag.deinit();
        }
        aya.mem.allocator.free(self.tags);

        for (self.objects) |obj| {
            obj.deinit();
        }
        aya.mem.allocator.free(self.objects);

        for (self.animations) |anim| {
            anim.deinit();
        }
        aya.mem.allocator.free(self.animations);
    }

    pub fn saveAsJson(self: Map, file: []const u8) void {
        var buf = aya.mem.SdlBufferStream.init(file, .write);
        std.json.stringify(self, .{ .whitespace = .{} }, buf.writer()) catch unreachable;
    }
};

pub const RuleSet = struct {
    seed: u64 = 0,
    repeat: u8 = 20,
    rules: []Rule,

    pub fn init(orig: data.RuleSet) RuleSet {
        var ruleset = RuleSet{ .seed = orig.seed, .repeat = orig.repeat, .rules = aya.mem.allocator.alloc(Rule, orig.rules.items.len) catch unreachable };

        for (orig.rules.items) |rule, i| {
            ruleset.rules[i] = Rule.init(rule);
        }
        return ruleset;
    }

    pub fn deinit(self: RuleSet) void {
        aya.mem.allocator.free(self.rules);
    }
};

pub const Rule = struct {
    name: []const u8,
    rule_tiles: []RuleTile,
    chance: u8,
    result_tiles: []u8,
    group: u8,

    pub fn init(orig: data.Rule) Rule {
        var rule = Rule{
            .name = aya.mem.allocator.dupe(u8, &orig.name) catch unreachable,
            .rule_tiles = aya.mem.allocator.alloc(RuleTile, orig.rule_tiles.len) catch unreachable,
            .chance = orig.chance,
            .result_tiles = aya.mem.allocator.dupe(u8, orig.result_tiles.items[0..orig.result_tiles.len]) catch unreachable,
            .group = orig.group,
        };

        var i: usize = 0;
        while (i < orig.rule_tiles.len) : (i += 1) {
            const rt = orig.rule_tiles[i];
            rule.rule_tiles[i] = .{ .tile = rt.tile, .state = @intToEnum(RuleTile.RuleState, @enumToInt(rt.state)) };
        }

        return rule;
    }

    pub fn deinit(self: Rule) void {
        aya.mem.allocator.free(self.name);
        aya.mem.allocator.free(self.rule_tiles);
        aya.mem.allocator.free(self.result_tiles);
    }
};

pub const RuleTile = struct {
    tile: usize,
    state: RuleState,

    pub const RuleState = enum(u4) {
        none,
        negated,
        required,

        pub fn jsonStringify(value: RuleState, options: std.json.StringifyOptions, out_stream: anytype) !void {
            // try out_stream.writeAll("[\"something special\",");
            try std.json.stringify(@enumToInt(value), options, out_stream);
            // try out_stream.writeByte(']');
        }
    };
};

pub const Tag = struct {
    name: []const u8,
    tiles: []u8,

    pub fn init(orig: data.Tag) Tag {
        return .{ .name = aya.mem.allocator.dupe(u8, &orig.name) catch unreachable, .tiles = aya.mem.allocator.dupe(u8, orig.tiles.items[0..orig.tiles.len]) catch unreachable };
    }

    pub fn deinit(self: Tag) void {
        aya.mem.allocator.free(self.name);
        aya.mem.allocator.free(self.tiles);
    }
};

pub const Object = struct {
    id: u8 = 0,
    name: []const u8,
    x: usize = 0,
    y: usize = 0,
    props: []Prop,

    pub const Prop = struct {
        name: []const u8,
        value: PropValue,

        pub fn init(orig: data.Object.Prop) Prop {
            var prop = Prop{ .name = aya.mem.allocator.dupe(u8, &orig.name) catch unreachable, .value = undefined };

            switch (orig.value) {
                .string => |str| prop.value = .{ .string = aya.mem.allocator.dupe(u8, &str) catch unreachable },
                .int => |int| prop.value = .{ .int = int },
                .float => |float| prop.value = .{ .float = float },
                .link => |link| prop.value = .{ .link = link },
            }

            return prop;
        }

        pub fn deinit(self: Prop) void {
            aya.mem.allocator.free(self.name);
            switch (self.value) {
                .string => |str| {
                    aya.mem.allocator.free(str);
                },
                else => {},
            }
        }
    };

    pub const PropValue = union(enum) {
        string: []const u8,
        int: i32,
        float: f32,
        link: u8,
    };

    pub fn init(orig: data.Object) Object {
        var obj = Object{ .id = orig.id, .name = aya.mem.allocator.dupe(u8, &orig.name) catch unreachable, .x = orig.x, .y = orig.y, .props = aya.mem.allocator.alloc(Prop, orig.props.items.len) catch unreachable };

        for (orig.props.items) |prop, i| {
            obj.props[i] = Prop.init(prop);
        }
        return obj;
    }

    pub fn deinit(self: Object) void {
        for (self.props) |prop| {
            prop.deinit();
        }
        aya.mem.allocator.free(self.props);
    }
};

pub const Animation = struct {
    tile: u8,
    rate: u16,
    tiles: []u8,

    pub fn init(orig: data.Animation) Animation {
        return .{ .tile = orig.tile, .rate = orig.rate, .tiles = aya.mem.allocator.dupe(u8, orig.tiles.items[0..orig.tiles.len]) catch unreachable };
    }

    pub fn deinit(self: Animation) void {
        aya.mem.allocator.free(self.tiles);
    }
};
