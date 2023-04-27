const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");

pub const enable_imgui = true;

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
var tilemap: Tilemap = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .window = .{
            .width = 1024,
            .height = 768,
        },
        .gfx = .{
            .batcher_max_sprites = 5000,
        },
    });
}

fn init() !void {
    generateMap();
}

fn update() !void {
    if (imgui.ogButton("Regen")) generateMap();

    _ = imgui.ogDrag(usize, "Minimum # Rows", &minimum_rows, 0.5, 5, 100);

    if (imgui.ogButton("Extract From Image and Dump to Console")) extractImage();
}

fn generateMap() void {
    var markov = Markov.init();
    defer markov.deinit();

    markov.addSourceMap(&map, 10, 37);
    generated_map = markov.generate(minimum_rows);

    tilemap = Tilemap.initWithData(generated_map, 10, generated_map.len / 10);
    tilemap.rotate();
}

fn render() !void {
    aya.gfx.beginPass(.{});
    drawMap(map[0..], 10, 37, 10, 10, 4);
    drawMap(generated_map, 10, generated_map.len / 10, 100, 10, 8);
    drawMap(tilemap.map, tilemap.w, tilemap.h, 10, 500, 4);
    aya.gfx.endPass();
}

fn drawMap(data: []const u8, w: usize, h: usize, x_pos: f32, y_pos: f32, scale: f32) void {
    var y: usize = 0;
    while (y < h) : (y += 1) {
        var x: usize = 0;
        while (x < w) : (x += 1) {
            var color = aya.math.Color.transparent;
            if (data[x + y * w] == 2) {
                color = aya.math.Color.white;
            } else if (data[x + y * w] == 1) {
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
    const data = aya.gfx.Texture.dataFromFile("examples/assets/textures/markov.png", &w, &h) catch unreachable;

    var i: usize = 0;
    while (i < h) : (i += 1) {
        // const first = i * w;
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
    allocator: std.mem.Allocator,

    pub fn init() Markov {
        return .{
            .rows = std.StringHashMap(std.StringHashMap(u8)).init(aya.mem.allocator),
            .firsts = std.StringHashMap(u8).init(aya.mem.allocator),
            .allocator = aya.mem.allocator,
        };
    }

    pub fn deinit(_: *Markov) void {}

    fn choose(hashmap: std.StringHashMap(u8)) []const u8 {
        var n: i32 = 0;
        var iter = hashmap.iterator();
        while (iter.next()) |entry| {
            n += @intCast(i32, entry.value_ptr.*);
        }

        if (n <= 1) {
            iter = hashmap.iterator();
            return iter.next().?.key_ptr.*;
        }

        n = aya.math.rand.range(i32, 0, n);
        iter = hashmap.iterator();
        while (iter.next()) |entry| {
            n = n - @intCast(i32, entry.value_ptr.*);
            if (n < 0) return entry.key_ptr.*;
        }

        unreachable;
    }

    pub fn generateChain(self: *Markov, data: []const u8, width: usize, height: usize) []const u8 {
        aya.math.rand.seed(@intCast(u64, std.time.milliTimestamp()));

        var markov = Markov.init();
        defer markov.deinit();

        markov.addSourceMap(data, width, height);

        var res = std.ArrayList([]const u8).init(self.allocator);
        var item = choose(markov.firsts);
        while (!std.mem.eql(u8, item, markov.final)) {
            res.append(item) catch unreachable;
            item = choose(markov.rows.get(item).?);
        }

        var new_map = self.allocator.alloc(u8, res.items.len * width) catch unreachable;
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
        var res = std.ArrayList([]const u8).init(self.allocator);

        var item = choose(self.firsts);
        while (res.items.len < min_rows) {
            while (!std.mem.eql(u8, item, self.final)) {
                res.append(item) catch unreachable;
                item = choose(self.rows.get(item).?);
            }
            // reset item for the next iteration
            var index = aya.math.rand.range(usize, 0, self.rows.count());
            var iter = self.rows.iterator();
            while (iter.next()) |entry| {
                if (index == 0) {
                    item = choose(entry.value_ptr.*);
                    break;
                }
                index -= 1;
            }
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
        var all_rows = self.allocator.alloc([]u8, height) catch unreachable;

        var y: usize = 0;
        while (y < height) : (y += 1) {
            var current_row = self.allocator.alloc(u8, width) catch unreachable;
            var x: usize = 0;
            while (x < width) : (x += 1) {
                current_row[x] = data[x + y * width];
            }
            all_rows[y] = current_row;
        }

        incrementItemCount(&self.firsts, all_rows[0]);
        for (all_rows, 0..) |row, i| {
            if (i == 0) continue;
            self.updateItem(all_rows[i - 1], row);
        }

        self.final = all_rows[all_rows.len - 1];
        self.updateItem(self.final, self.final);
    }

    fn incrementItemCount(hashmap: *std.StringHashMap(u8), row: []u8) void {
        var res = hashmap.getOrPut(row) catch unreachable;
        if (!res.found_existing) {
            res.value_ptr.* = 1;
        } else {
            res.value_ptr.* += 1;
        }
    }

    fn updateItem(self: *Markov, item: []u8, next: []u8) void {
        var entry = self.rows.getOrPut(item) catch unreachable;
        if (!entry.found_existing) {
            entry.value_ptr.* = std.StringHashMap(u8).init(self.allocator);
        }
        incrementItemCount(entry.value_ptr, next);
    }
};

pub const Tilemap = struct {
    w: usize,
    h: usize,
    map: []u8,

    pub fn initWithData(data: []const u8, width: usize, height: usize) Tilemap {
        return .{
            .w = width,
            .h = height,
            .map = std.testing.allocator.dupe(u8, data) catch unreachable,
        };
    }

    pub fn deinit(self: Tilemap) void {
        std.testing.allocator.free(self.map);
    }

    pub fn rotate(self: *Tilemap) void {
        var rotated = std.testing.allocator.alloc(u8, self.map.len) catch unreachable;

        var y: usize = 0;
        while (y < self.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.w) : (x += 1) {
                rotated[y + x * self.h] = self.map[x + y * self.w];
            }
        }

        std.testing.allocator.free(self.map);
        self.map = rotated;
        std.mem.swap(usize, &self.w, &self.h);
    }

    pub fn print(self: Tilemap) void {
        var y: usize = 0;
        while (y < self.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.w) : (x += 1) {
                std.debug.print("{}, ", .{self.map[x + y * self.w]});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
};
