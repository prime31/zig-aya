const std = @import("std");
const aya = @import("aya");

pub const Map = struct {
    w: usize = 64,
    h: usize = 64,
    tile_size: usize = 16,
    tile_spacing: usize = 0,
    seed: u64 = 0,
    repeat: u8 = 20,
    image: []const u8 = "",
    data: []u8,
    rulesets: std.ArrayList(RuleSet),
    pre_rulesets: std.ArrayList(std.ArrayList(RuleSet)),
    tags: std.ArrayList(Tag),
    objects: std.ArrayList(Object),
    animations: std.ArrayList(Animation),

    pub fn init(tile_size: usize, tile_spacing: usize) Map {
        var map = .{
            .w = 64,
            .h = 64,
            .tile_size = tile_size,
            .tile_spacing = tile_spacing,
            .data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .rulesets = std.ArrayList(RuleSet).init(aya.mem.allocator),
            .pre_rulesets = std.ArrayList(std.ArrayList(RuleSet)).init(aya.mem.allocator),
            .tags = std.ArrayList(Tag).init(aya.mem.allocator),
            .objects = std.ArrayList(Object).init(aya.mem.allocator),
            .animations = std.ArrayList(Animation).init(aya.mem.allocator),
        };

        std.mem.set(u8, map.data, 0);
        return map;
    }

    pub fn deinit(self: Map) void {
        aya.mem.allocator.free(self.data);
        for (self.pre_rulesets.items) |pr| {
            pr.deinit();
        }
        self.rulesets.deinit();
        self.tags.deinit();
        self.objects.deinit();
        self.animations.deinit();

        if (self.image.len > 0) {
            aya.mem.allocator.free(self.image);
        }
    }

    pub fn addRuleSet(self: *Map) void {
        self.rulesets.append(RuleSet.init()) catch unreachable;
    }

    pub fn addTag(self: *Map) void {
        self.tags.append(Tag.init()) catch unreachable;
    }

    pub fn addObject(self: *Map) void {
        self.objects.append(Object.init()) catch unreachable;
    }

    pub fn addAnimation(self: *Map, tile: u8) void {
        self.animations.append(Animation.init(tile)) catch unreachable;
    }

    pub fn addPreRulesPage(self: *Map) void {
        self.pre_rulesets.append(std.ArrayList(RuleSet).init(aya.mem.allocator)) catch unreachable;
    }

    pub fn getTile(self: Map, x: usize, y: usize) u8 {
        if (x > self.w or y > self.h) {
            return 0;
        }
        return self.data[x + y * self.w];
    }

    pub fn setTile(self: Map, x: usize, y: usize, value: u8) void {
        self.data[x + y * self.w] = value;
    }

    pub fn getNextRuleSetFolder(self: Map) u8 {
        var folder: u8 = 0;
        for (self.rulesets.items) |item| {
            folder = std.math.max(folder, item.folder);
        }
        return folder + 1;
    }

    /// adds the Rules required for a nine-slice with index being the top-left element of the nine-slice
    pub fn addNinceSliceRules(self: *Map, tiles_per_row: usize, selected_brush_index: usize, name_prefix: []const u8, index: usize) void {
        const x = @mod(index, tiles_per_row);
        const y = @divTrunc(index, tiles_per_row);
        const folder = self.getNextRuleSetFolder();

        var rule = RuleSet.init();
        rule.folder = folder;
        const tl_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tl_name);
        rule.get(1, 2).negate(selected_brush_index + 1);
        rule.get(2, 1).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + y * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const tr_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tr" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tr_name);
        rule.get(3, 2).negate(selected_brush_index + 1);
        rule.get(2, 1).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 2 + y * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const bl_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-bl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, bl_name);
        rule.get(1, 2).negate(selected_brush_index + 1);
        rule.get(2, 3).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + (y + 2) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const br_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-br" }) catch unreachable;
        std.mem.copy(u8, &rule.name, br_name);
        rule.get(2, 3).negate(selected_brush_index + 1);
        rule.get(3, 2).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 2 + (y + 2) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const t_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-t" }) catch unreachable;
        std.mem.copy(u8, &rule.name, t_name);
        rule.get(2, 1).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + y * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const b_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-b" }) catch unreachable;
        std.mem.copy(u8, &rule.name, b_name);
        rule.get(2, 3).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + (y + 2) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const l_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-l" }) catch unreachable;
        std.mem.copy(u8, &rule.name, l_name);
        rule.get(1, 2).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + (y + 1) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const r_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-r" }) catch unreachable;
        std.mem.copy(u8, &rule.name, r_name);
        rule.get(3, 2).negate(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, (x + 2) + (y + 1) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const c_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-c" }) catch unreachable;
        std.mem.copy(u8, &rule.name, c_name);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + (y + 1) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;
    }

    pub fn addInnerFourRules(self: *Map, tiles_per_row: usize, selected_brush_index: usize, name_prefix: []const u8, index: usize) void {
        const x = @mod(index, tiles_per_row);
        const y = @divTrunc(index, tiles_per_row);
        const folder = self.getNextRuleSetFolder();

        var rule = RuleSet.init();
        rule.folder = folder;
        const tl_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tl_name);
        rule.get(1, 1).negate(selected_brush_index + 1);
        rule.get(1, 2).require(selected_brush_index + 1);
        rule.get(2, 1).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + y * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const tr_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-tr" }) catch unreachable;
        std.mem.copy(u8, &rule.name, tr_name);
        rule.get(3, 1).negate(selected_brush_index + 1);
        rule.get(3, 2).require(selected_brush_index + 1);
        rule.get(2, 1).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + y * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const bl_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-bl" }) catch unreachable;
        std.mem.copy(u8, &rule.name, bl_name);
        rule.get(1, 2).require(selected_brush_index + 1);
        rule.get(2, 3).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.get(1, 3).negate(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + (y + 1) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;

        rule = RuleSet.init();
        rule.folder = folder;
        const br_name = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ name_prefix, "-br" }) catch unreachable;
        std.mem.copy(u8, &rule.name, br_name);
        rule.get(2, 3).require(selected_brush_index + 1);
        rule.get(3, 2).require(selected_brush_index + 1);
        rule.get(2, 2).require(selected_brush_index + 1);
        rule.get(3, 3).negate(selected_brush_index + 1);
        rule.toggleSelected(@intCast(u8, x + 1 + (y + 1) * tiles_per_row));
        self.rulesets.append(rule) catch unreachable;
    }
};

pub const RuleSet = struct {
    name: [25:0]u8 = [_:0]u8{0} ** 25,
    rules: [25]Rule = undefined,
    chance: u8 = 100,
    result_tiles: aya.utils.FixedList(u8, 25), // indices into the tileset image
    folder: u8 = 0, // UI-relevant: used to group RuleSets into a tree leaf node visually

    pub fn init() RuleSet {
        return .{
            .rules = [_]Rule{Rule{ .tile = 0, .state = .none }} ** 25,
            .result_tiles = aya.utils.FixedList(u8, 25).init(),
        };
    }

    pub fn clone(self: RuleSet) RuleSet {
        var new_rule = RuleSet.init();
        std.mem.copy(u8, &new_rule.name, &self.name);
        std.mem.copy(Rule, &new_rule.rules, &self.rules);
        std.mem.copy(u8, &new_rule.result_tiles.items, &self.result_tiles.items);
        new_rule.result_tiles.len = self.result_tiles.len;
        new_rule.chance = self.chance;
        new_rule.folder = self.folder;
        return new_rule;
    }

    pub fn clearPatternData(self: *RuleSet) void {
        self.rules = [_]Rule{Rule{ .tile = 0, .state = .none }} ** 25;
    }

    pub fn get(self: *RuleSet, x: usize, y: usize) *Rule {
        return &self.rules[x + y * 5];
    }

    pub fn resultTile(self: *RuleSet, random: usize) usize {
        const index = std.rand.limitRangeBiased(usize, random, self.result_tiles.len);
        return self.result_tiles.items[index];
    }

    pub fn toggleSelected(self: *RuleSet, index: u8) void {
        if (self.result_tiles.indexOf(index)) |slice_index| {
            _ = self.result_tiles.swapRemove(slice_index);
        } else {
            self.result_tiles.append(index);
        }
    }

    pub fn flip(self: *RuleSet, dir: enum { horizontal, vertical }) void {
        if (dir == .vertical) {
            for ([_]usize{ 0, 1 }) |y| {
                for ([_]usize{ 0, 1, 2, 3, 4 }) |x| {
                    std.mem.swap(Rule, &self.rules[x + y * 5], &self.rules[x + (4 - y) * 5]);
                }
            }
        } else {
            for ([_]usize{ 0, 1 }) |x| {
                for ([_]usize{ 0, 1, 2, 3, 4 }) |y| {
                    std.mem.swap(Rule, &self.rules[x + y * 5], &self.rules[(4 - x) + y * 5]);
                }
            }
        }
    }

    pub fn shift(self: *RuleSet, dir: enum { left, right, up, down }) void {
        var x_incr: i32 = if (dir == .left) -1 else 1;
        var x_vals = [_]usize{ 0, 1, 2, 3, 4 };
        if (dir == .right) std.mem.reverse(usize, &x_vals);

        var y_incr: i32 = if (dir == .up) -1 else 1;
        var y_vals = [_]usize{ 0, 1, 2, 3, 4 };
        if (dir == .down) std.mem.reverse(usize, &y_vals);

        if (dir == .left or dir == .right) {
            for (y_vals) |y| {
                for (x_vals) |x| {
                    self.swap(x, y, @intCast(i32, x) + x_incr, @intCast(i32, y));
                }
            }
        } else {
            for (x_vals) |x| {
                for (y_vals) |y| {
                    self.swap(x, y, @intCast(i32, x), @intCast(i32, y) + y_incr);
                }
            }
        }
    }

    fn swap(self: *RuleSet, x: usize, y: usize, new_x: i32, new_y: i32) void {
        // destinations can be invalid and when they are we just reset the source values
        if (new_x >= 0 and new_x < 5 and new_y >= 0 and new_y < 5) {
            self.rules[@intCast(usize, new_x + new_y * 5)] = self.rules[x + y * 5].clone();
        }
        self.rules[x + y * 5].reset();
    }
};

pub const Rule = struct {
    tile: usize = 0,
    state: RuleState = .none,

    pub const RuleState = enum(u4) {
        none,
        negated,
        required,
    };

    pub fn clone(self: Rule) Rule {
        return .{ .tile = self.tile, .state = self.state };
    }

    pub fn reset(self: *Rule) void {
        self.tile = 0;
        self.state = .none;
    }

    pub fn passes(self: Rule, tile: usize) bool {
        if (self.state == .none) return false;
        if (tile == self.tile) {
            return self.state == .required;
        }
        return self.state == .negated;
    }

    pub fn toggleState(self: *Rule, new_state: RuleState) void {
        if (self.tile == 0) {
            self.state = new_state;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }

    pub fn negate(self: *Rule, index: usize) void {
        if (self.tile == 0) {
            self.tile = index;
            self.state = .negated;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }

    pub fn require(self: *Rule, index: usize) void {
        if (self.tile == 0) {
            self.tile = index;
            self.state = .required;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }
};

pub const Tag = struct {
    name: [25]u8,
    tiles: aya.utils.FixedList(u8, 10),

    pub fn init() Tag {
        return .{ .name = [_]u8{0} ** 25, .tiles = aya.utils.FixedList(u8, 10).init() };
    }

    pub fn toggleSelected(self: *Tag, index: u8) void {
        if (self.tiles.indexOf(index)) |slice_index| {
            _ = self.tiles.swapRemove(slice_index);
        } else {
            self.tiles.append(index);
        }
    }
};

pub const Object = struct {
    name: [25]u8 = undefined,
    x: usize = 0,
    y: usize = 0,
    props: std.ArrayList(Prop),

    pub const Prop = struct {
        name: [25]u8,
        value: PropValue,

        pub fn init() Prop {
            return .{ .name = [_]u8{0} ** 25, .value = undefined };
        }
    };

    pub const PropValue = union(enum) {
        string: [25]u8,
        int: i32,
        float: f32,
    };

    pub fn init() Object {
        return .{ .props = std.ArrayList(Prop).init(aya.mem.allocator) };
    }

    pub fn deinit(self: Object) void {
        self.props.deinit();
    }

    pub fn addProp(self: *Object, value: PropValue) void {
        self.props.append(.{ .name = undefined, .value = value }) catch unreachable;
    }
};

pub const Animation = struct {
    tile: u8,
    rate: u16 = 500,
    tiles: aya.utils.FixedList(u8, 10),

    pub fn init(tile: u8) Animation {
        return .{ .tile = tile, .tiles = aya.utils.FixedList(u8, 10).init() };
    }

    pub fn toggleSelected(self: *Animation, index: u8) void {
        if (self.tiles.indexOf(index)) |slice_index| {
            _ = self.tiles.swapRemove(slice_index);
        } else {
            self.tiles.append(index);
        }
    }
};
