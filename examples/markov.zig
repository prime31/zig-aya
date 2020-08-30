const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");
usingnamespace @import("sokol");

pub const imgui = true;

var tex: aya.gfx.Texture = undefined;
// 10 x 37
const map = [_]u8{
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 1, 1, 1, 1, 0, 0, 1,
    1, 0, 0, 1, 1, 1, 1, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 1, 1, 0, 0, 0, 1,
    1, 0, 0, 0, 1, 1, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 0, 0, 0, 0, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 2, 0, 0, 2, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 0, 0, 0, 0, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 0, 0, 0, 0, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 2, 0, 0, 0, 0, 1, 1, 1,
    1, 0, 0, 0, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 0, 1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 2, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 0, 0, 1,
    1, 0, 2, 0, 0, 1, 1, 0, 0, 1,
    1, 1, 1, 1, 0, 1, 1, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 1, 1, 2, 2, 2, 2, 1, 1, 1,
};

var minimum_rows: usize = 10;
var generated_map: []const u8 = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .window = .{
            .width = 1024,
            .height = 768,
        },
    });
}

fn init() void {
    tex = aya.gfx.Texture.initFromFile("/Users/desaro/Desktop/input.png", .nearest) catch unreachable;
    generateMap();
}

fn update() void {
    if (ogButton("Regen")) {
        generateMap();
    }

    _ = ogDrag(usize, "Minimum # Rows", &minimum_rows, 0.5, 5, 100);
}

fn generateMap() void {
    var markov = Markov.init();
    defer markov.deinit();

    markov.addSourceMap(&map, 10, 37);
    generated_map = markov.generate(minimum_rows);
}

fn render() void {
    aya.gfx.beginPass(.{});
    drawMap(map[0..], 10, 37, 10, 10, 4);
    drawMap(generated_map, 10, generated_map.len / 10, 100, 10, 8);
    aya.gfx.endPass();
}

fn drawMap(data: []const u8, w: usize, h: usize, x_pos: f32, y_pos: f32, scale: f32) void {
    var y: usize = 0;
    while (y < h) : (y += 1) {
        var x: usize = 0;
        while (x < w) : (x += 1) {
            var color = aya.math.Color.transparent;
            if (data[x + y * 10] == 2) {
                color = aya.math.Color.white;
            } else if (data[x + y * 10] == 1) {
                color = aya.math.Color.black;
            } else {
                continue;
            }
            aya.draw.rect(.{ .x = x_pos + @intToFloat(f32, x) * scale, .y = y_pos + @intToFloat(f32, y) * scale }, scale, scale, color);
        }
    }
}

fn extractImage() void {
    var w: usize = 0;
    var h: usize = 0;
    const data = aya.gfx.Texture.dataFromFile("/Users/desaro/Desktop/input.png", .nearest, &w, &h) catch unreachable;

    var i: usize = 0;
    while (i < h) : (i += 1) {
        const first = i * w;
        var j: usize = 0;
        while (j < w) : (j += 1) {
            const pixel_index = (j + i * w) * 4;
            const alpha = data[pixel_index];

            if (alpha == 0) {
                std.debug.print("0, ", .{});
            } else {
                const green = data[pixel_index + 2];
                if (green == 255) {
                    std.debug.print("1, ", .{});
                } else {
                    std.debug.print("2, ", .{});
                }
            }
        }
        std.debug.print("\n", .{});
    }
}

pub const Markov = struct {
    rows: std.StringHashMap(std.StringHashMap(u8)),
    firsts: std.StringHashMap(u8),
    final: []u8 = undefined,
    arena: std.heap.ArenaAllocator,

    pub fn init() Markov {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        return .{
            .rows = std.StringHashMap(std.StringHashMap(u8)).init(&arena.allocator),
            .firsts = std.StringHashMap(u8).init(&arena.allocator),
            .arena = arena,
        };
    }

    pub fn deinit(self: *Markov) void {
        self.arena.deinit();
    }

    fn choose(hashmap: std.StringHashMap(u8)) []const u8 {
        var n: i32 = 0;
        for (hashmap.items()) |entry| {
            n += @intCast(i32, entry.value);
        }

        if (n <= 1) return hashmap.items()[0].key;

        n = aya.math.rand.range(i32, 0, n);
        for (hashmap.items()) |entry| {
            n = n - @intCast(i32, entry.value);
            if (n < 0) return entry.key;
        }

        unreachable;
    }

    pub fn generateChain(data: []const u8, width: usize, height: usize) []const u8 {
        aya.math.rand.seed(@intCast(u64, std.time.milliTimestamp()));

        var markov = Markov.init();
        defer markov.deinit();

        markov.addSourceMap(data, width, height);

        var res = std.ArrayList([]const u8).init(&markov.arena.allocator);
        var item = choose(markov.firsts);
        while (!std.mem.eql(u8, item, markov.final)) {
            res.append(item) catch unreachable;
            item = choose(markov.rows.get(item).?);
        }

        var new_map = markov.arena.allocator.alloc(u8, res.items.len * width) catch unreachable;
        var i: usize = 0;
        for (res.items) |row| {
            for (row) |tile| {
                new_map[i] = tile;
                i += 1;
            }
        }

        return markov.generate(20);
    }

    pub fn generate(self: *Markov, min_rows: usize) []const u8 {
        var res = std.ArrayList([]const u8).init(&self.arena.allocator);

        var item = choose(self.firsts);
        while (res.items.len < min_rows) {
            while (!std.mem.eql(u8, item, self.final)) {
                res.append(item) catch unreachable;
                item = choose(self.rows.get(item).?);
            }
            // reset item for the next iteration
            item = choose(self.rows.items()[aya.math.rand.range(usize, 0, self.rows.items().len)].value);
        }
        res.append(self.final) catch unreachable;

        var new_map = aya.mem.allocator.alloc(u8, res.items.len * res.items[0].len) catch unreachable;
        var i: usize = 0;
        for (res.items) |row| {
            for (row) |tile| {
                new_map[i] = tile;
                i += 1;
            }
        }

        return new_map;
    }

    pub fn addSourceMap(self: *Markov, data: []const u8, width: usize, height: usize) void {
        var all_rows = self.arena.allocator.alloc([]u8, height) catch unreachable;

        var y: usize = 0;
        while (y < height) : (y += 1) {
            var current_row = self.arena.allocator.alloc(u8, width) catch unreachable;
            var x: usize = 0;
            while (x < width) : (x += 1) {
                current_row[x] = data[x + y * width];
            }
            all_rows[y] = current_row;
        }

        incrementItemCount(&self.firsts, all_rows[0]);
        for (all_rows) |row, i| {
            if (i == 0) continue;
            self.updateItem(all_rows[i - 1], row);
        }

        self.final = all_rows[all_rows.len - 1];
        self.updateItem(self.final, self.final);
    }

    fn incrementItemCount(hashmap: *std.StringHashMap(u8), row: []u8) void {
        var res = hashmap.getOrPut(row) catch unreachable;
        if (!res.found_existing) {
            res.entry.value = 1;
        } else {
            res.entry.value += 1;
        }
    }

    fn updateItem(self: *Markov, item: []u8, next: []u8) void {
        var entry = self.rows.getOrPut(item) catch unreachable;
        if (!entry.found_existing) {
            entry.entry.value = std.StringHashMap(u8).init(&self.arena.allocator);
        }
        incrementItemCount(&entry.entry.value, next);
    }
};
