const std = @import("std");
const aya = @import("aya");

pub const Map = struct {
    w: i32 = 64,
    h: i32 = 64,
    tile_w: i32 = 16,
    tile_h: i32 = 16,
    tile_spacing: i32 = 0,
    image: []const u8 = undefined,
    data: []u32,
    rules: std.ArrayList(Rule),
    allocator: *std.mem.Allocator,

    pub fn init(allocator: ?*std.mem.Allocator) Map {
        const alloc = allocator orelse aya.mem.allocator;
        var map = .{
            .data = alloc.alloc(u32, 64 * 64) catch unreachable,
            .rules = std.ArrayList(Rule).init(alloc),
            .allocator = alloc,
        };

        std.mem.set(u32, map.data, 0);

        return map;
    }

    pub fn deinit(self: Map) void {
        self.allocator.free(self.data);
        self.rules.deinit();
    }

    pub fn addRule(self: *Map) void {
        self.rules.append(Rule.init()) catch unreachable;
    }

    pub fn getTile(self: Map, x: usize, y: usize) u32 {
        return self.data[x + y * @intCast(usize, self.w)];
    }

    pub fn setTile(self: Map, x: usize, y: usize, value: u32) void {
        self.data[x + y * @intCast(usize, self.w)] = value;
    }
};

pub const Rule = struct {
    name: [25]u8 = undefined,
    data: [25]RuleTile = undefined,
    chance: u8 = 100,

    pub fn clone(self: Rule) Rule {
        var new_rule = Rule.init();
        std.mem.copy(u8, &new_rule.name, &self.name);
        std.mem.copy(RuleTile, &new_rule.data, &self.data);
        new_rule.chance = self.chance;
        return new_rule;
    }

    pub fn init() Rule {
        return .{
            .data = [_]RuleTile{RuleTile{.tile = 0, .state = .none}} ** 25,
        };
    }

    pub fn get(self: *Rule, x: usize, y: usize) *RuleTile {
        return &self.data[x + y * 5];
    }
};

pub const RuleTile = struct {
    tile: usize = 0,
    state: RuleTileState = .none,

    pub const RuleTileState = enum(u4) {
        none,
        negated,
        required,
    };

    pub fn clone(self: RuleTile) RuleTile {
        return .{.tile = self.tile, .state = self.state};
    }

    pub fn toggleState(self: *RuleTile, new_state: RuleTileState) void {
        if (self.tile == 0) {
            self.state = new_state;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }

    pub fn negate(self: *RuleTile, index: usize) void {
        if (self.tile == 0) {
            self.tile = index;
            self.state = .negated;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }

    pub fn require(self: *RuleTile, index: usize) void {
        if (self.tile == 0) {
            self.tile = index;
            self.state = .required;
        } else {
            self.tile = 0;
            self.state = .none;
        }
    }
};
