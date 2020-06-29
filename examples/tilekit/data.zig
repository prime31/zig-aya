const std = @import("std");
const aya = @import("aya");

pub const Map = struct {
    w: i32 = 64,
    h: i32 = 64,
    tile_size: i32 = 16,
    tile_spacing: i32 = 0,
    image: []const u8 = "",
    data: []u32,
    rules: std.ArrayList(Rule),

    pub fn init() Map {
        var map = .{
            .data = aya.mem.allocator.alloc(u32, 64 * 64) catch unreachable,
            .rules = std.ArrayList(Rule).init(aya.mem.allocator),
        };

        std.mem.set(u32, map.data, 0);
        return map;
    }

    pub fn deinit(self: Map) void {
        aya.mem.allocator.free(self.data);
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

    pub fn toBinary(self: Map) !void {
        var path_or_null = try @import("known-folders.zig").getPath(aya.mem.tmp_allocator, .desktop);
        const out_path = try std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ path_or_null.?, "/", "tilekit.bin" });

        var buf = aya.mem.SdlBufferStream.init(out_path, .write);
        defer buf.deinit();

        const out = buf.writer();
        try out.writeIntLittle(i32, self.w);
        try out.writeIntLittle(i32, self.h);
        try out.writeIntLittle(i32, self.tile_size);
        try out.writeIntLittle(i32, self.tile_spacing);
        try out.writeIntLittle(usize, self.image.len);
        try out.writeAll(self.image);

        try out.writeIntLittle(usize, self.data.len);
        try out.writeAll(std.mem.sliceAsBytes(self.data));

        try out.writeIntLittle(usize, self.rules.items.len);
        for (self.rules.items) |rule| {
            try out.writeAll(rule.name[0..std.mem.indexOfSentinel(u8, 0, rule.name[0..])]);
            try out.writeIntLittle(u8, rule.chance);

            try out.writeIntLittle(usize, rule.pattern_data.len);
            for (rule.pattern_data) |rule_tile| {
                try out.writeIntLittle(usize, rule_tile.tile);
                try out.writeIntLittle(usize, @enumToInt(rule_tile.state));
            }

            try out.writeIntLittle(usize, rule.selected_data.len);
            for (rule.selected_data.items) |selected_data, i| {
                if (i == rule.selected_data.len) break;
                try out.writeIntLittle(u8, selected_data);
            }
        }
    }

    pub fn fromBinary(self: Map) !void {
        var path_or_null = try @import("known-folders.zig").getPath(aya.mem.tmp_allocator, .desktop);
        const out_path = try std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ path_or_null.?, "/", "tilekit.bin" });

        var buf = aya.mem.SdlBufferStream.init(out_path, .read);
        defer buf.deinit();

        // std.mem.bytesAsValue for reading f32
        const in = buf.reader();
        var w = in.readIntLittle(i32);
        var h = in.readIntLittle(i32);
        var tile_size = in.readIntLittle(i32);
        var tile_spacing = in.readIntLittle(i32);

        var image_len = try in.readIntLittle(usize);
        if (image_len > 0) {
            const buffer = try aya.mem.tmp_allocator.alloc(u8, image_len);
            _ = try in.readAll(buffer);
        }

        var data_len = try in.readIntLittle(usize);

        std.debug.print("{}, {}, {}, {} img.len: {}, data.len: {}\n", .{ w, h, tile_size, tile_spacing, image_len, data_len });
    }

    pub fn toJson(self: Map) !void {
        var path_or_null = try @import("known-folders.zig").getPath(aya.mem.tmp_allocator, .desktop);
        const out_path = try std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ path_or_null.?, "/", "tilekit.json" });

        var buf = aya.mem.SdlBufferStream.init(out_path, .write);
        defer buf.deinit();
        const out_stream = buf.writer();

        var jw = std.json.writeStream(out_stream, 10);

        try jw.beginObject();
        try jw.objectField("w");
        try jw.emitNumber(self.w);

        try jw.objectField("h");
        try jw.emitNumber(self.h);

        try jw.objectField("tile_size");
        try jw.emitNumber(self.tile_size);

        try jw.objectField("tile_spacing");
        try jw.emitNumber(self.tile_spacing);

        try jw.objectField("image");
        try jw.emitString(self.image);

        try jw.objectField("data");
        try jw.beginArray();
        for (self.data) |d| {
            try jw.arrayElem();
            try jw.emitNumber(d);
        }
        try jw.endArray();

        try jw.objectField("rules");
        try jw.beginArray();
        for (self.rules.items) |rule| {
            try jw.arrayElem();
            try jw.beginObject();
            try jw.objectField("name");
            try jw.emitString(rule.name[0..std.mem.indexOfSentinel(u8, 0, rule.name[0..])]);

            try jw.objectField("chance");
            try jw.emitNumber(rule.chance);

            try jw.objectField("pattern_data");
            try jw.beginArray();
            for (rule.pattern_data) |rule_tile| {
                try jw.arrayElem();
                try jw.beginObject();
                try jw.objectField("tile");
                try jw.emitNumber(rule_tile.tile);
                try jw.objectField("state");
                try jw.emitNumber(@enumToInt(rule_tile.state));
                try jw.endObject();
            }
            try jw.endArray();

            try jw.objectField("selected_data");
            try jw.beginArray();
            for (rule.selected_data.items) |selected_data, i| {
                if (i == rule.selected_data.len) break;
                try jw.arrayElem();
                try jw.emitNumber(selected_data);
            }
            try jw.endArray();

            try jw.endObject();
        }
        try jw.endArray();

        try jw.endObject();
    }
};

pub const Rule = struct {
    name: [25:0]u8 = [_:0]u8{0} ** 25,
    pattern_data: [25]RuleTile = undefined,
    chance: u8 = 100,
    selected_data: aya.utils.FixedList(u8, 25),

    pub fn init() Rule {
        return .{
            .pattern_data = [_]RuleTile{RuleTile{ .tile = 0, .state = .none }} ** 25,
            .selected_data = aya.utils.FixedList(u8, 25).init(),
        };
    }

    pub fn clone(self: Rule) Rule {
        var new_rule = Rule.init();
        std.mem.copy(u8, &new_rule.name, &self.name);
        std.mem.copy(RuleTile, &new_rule.pattern_data, &self.pattern_data);
        std.mem.copy(u8, &new_rule.selected_data.items, &self.selected_data.items);
        new_rule.selected_data.len = self.selected_data.len;
        new_rule.chance = self.chance;
        return new_rule;
    }

    pub fn clearPatternData(self: *Rule) void {
        self.pattern_data = [_]RuleTile{RuleTile{ .tile = 0, .state = .none }} ** 25;
    }

    pub fn get(self: *Rule, x: usize, y: usize) *RuleTile {
        return &self.pattern_data[x + y * 5];
    }

    pub fn toggleSelected(self: *Rule, index: u8) void {
        if (self.selected_data.indexOf(index)) |slice_index| {
            _ = self.selected_data.swapRemove(slice_index);
        } else {
            self.selected_data.append(index);
        }
    }

    pub fn flip(self: *Rule, dir: enum { horizontal, vertical }) void {
        if (dir == .vertical) {
            for ([_]usize{ 0, 1 }) |y| {
                for ([_]usize{ 0, 1, 2, 3, 4 }) |x| {
                    std.mem.swap(RuleTile, &self.pattern_data[x + y * 5], &self.pattern_data[x + (4 - y) * 5]);
                }
            }
        } else {
            for ([_]usize{ 0, 1 }) |x| {
                for ([_]usize{ 0, 1, 2, 3, 4 }) |y| {
                    std.mem.swap(RuleTile, &self.pattern_data[x + y * 5], &self.pattern_data[(4 - x) + y * 5]);
                }
            }
        }
    }

    pub fn shift(self: *Rule, dir: enum { left, right, up, down }) void {
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

    fn swap(self: *Rule, x: usize, y: usize, new_x: i32, new_y: i32) void {
        // destinations can be invalid and when they are we just reset the source values
        if (new_x >= 0 and new_x < 5 and new_y >= 0 and new_y < 5) {
            self.pattern_data[@intCast(usize, new_x + new_y * 5)] = self.pattern_data[x + y * 5].clone();
        }
        self.pattern_data[x + y * 5].reset();
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
        return .{ .tile = self.tile, .state = self.state };
    }

    pub fn reset(self: *RuleTile) void {
        self.tile = 0;
        self.state = .none;
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
