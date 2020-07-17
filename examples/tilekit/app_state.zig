const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");

const persistence = @import("persistence.zig");
const tk = @import("tilekit.zig");

const TileKit = tk.TileKit;
const Texture = aya.gfx.Texture;
const Map = tk.Map;

pub const AppState = struct {
    map: Map,
    // general state
    opened_file: ?[]const u8 = null,
    object_edit_mode: bool = false,
    selected_brush_index: usize = 0,
    texture: Texture,
    tiles_per_row: usize = 0,
    map_rect_size: f32 = 12,
    // toasts
    toast_timer: i32 = -1,
    toast_text: [255]u8 = undefined,
    // map data
    map_data_dirty: bool = true,
    processed_map_data: []u8,
    final_map_data: []u8,
    random_map_data: []Randoms,
    prefs: Prefs = .{
        .windows = .{},
    },

    pub const Randoms = struct {
        float: f32,
        int: usize,
    };

    /// persisted data
    pub const Prefs = struct {
        // ui state
        show_animations: bool = false,
        show_objects: bool = true,
        tile_size_multiplier: usize = 1,
        // menu state
        windows: struct {
            brushes: bool = true,
            rules: bool = true,
            objects: bool = true,
            object_editor: bool = false,
            tags: bool = false,
            animations: bool = false,
            input_map: bool = true,
            post_processed_map: bool = true,
            output_map: bool = true,
        },
    };

    pub fn init() AppState {
        const prefs = aya.fs.readPrefsJson(AppState.Prefs, "aya_tile", "prefs.json") catch AppState.Prefs{ .windows = .{} };

        // load up a temp map
        const tile_size = 12;
        const map = Map.init(tile_size, 1);

        var state = AppState{
            .map = map,
            .map_rect_size = @intToFloat(f32, tile_size * prefs.tile_size_multiplier),
            .processed_map_data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .final_map_data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .random_map_data = aya.mem.allocator.alloc(Randoms, 64 * 64) catch unreachable,
            .texture = Texture.initFromFile("assets/blacknwhite.png") catch unreachable,
            // .texture = Texture.initCheckerboard(),
            .prefs = prefs,
        };
        state.generateRandomData();
        return state;
    }

    pub fn savePrefs(self: AppState) void {
        aya.fs.savePrefsJson("aya_tile", "prefs.json", self.prefs) catch unreachable;
    }

    /// returns the number of tiles in each row of the tileset image
    pub fn tilesPerRow(self: *AppState) usize {
        // calculate tiles_per_row if needed
        if (self.tiles_per_row == 0) {
            var accum: usize = self.map.tile_spacing * 2;
            while (true) {
                self.tiles_per_row += 1;
                accum += self.map.tile_size + 2 * self.map.tile_spacing;
                if (accum >= self.texture.width) {
                    break;
                }
            }
        }
        return self.tiles_per_row;
    }

    pub fn tilesPerCol(self: *AppState) usize {
        var tiles_per_col: usize = 0;
        var accum: usize = self.map.tile_spacing * 2;
        while (true) {
            tiles_per_col += 1;
            accum += self.map.tile_size + 2 * self.map.tile_spacing;
            if (accum >= self.texture.height) {
                break;
            }
        }
        return tiles_per_col;
    }

    pub fn mapSize(self: AppState) ImVec2 {
        return ImVec2{ .x = @intToFloat(f32, self.map.w) * self.map_rect_size, .y = @intToFloat(f32, self.map.h) * self.map_rect_size };
    }

    /// resizes the map and all of the sub-maps
    pub fn resizeMap(self: *AppState, w: usize, h: usize) void {
        tk.history.reset();
        self.map_data_dirty = true;
        const shrunk = self.map.w > w or self.map.h > h;

        // map_data is our source so we need to copy the old data into a temporary slice
        var new_slice = aya.mem.allocator.alloc(u8, w * h) catch unreachable;
        std.mem.set(u8, new_slice, 0);

        // copy taking into account that we may have shrunk
        const max_x = std.math.min(self.map.w, w);
        const max_y = std.math.min(self.map.h, h);
        var y: usize = 0;
        while (y < max_y) : (y += 1) {
            var x: usize = 0;
            while (x < max_x) : (x += 1) {
                new_slice[x + y * w] = self.map.getTile(x, y);
            }
        }

        self.map.w = w;
        self.map.h = h;

        aya.mem.allocator.free(self.map.data);
        self.map.data = new_slice;

        // resize our two generated maps
        aya.mem.allocator.free(self.processed_map_data);
        aya.mem.allocator.free(self.final_map_data);
        aya.mem.allocator.free(self.random_map_data);
        self.processed_map_data = aya.mem.allocator.alloc(u8, w * h) catch unreachable;
        self.final_map_data = aya.mem.allocator.alloc(u8, w * h) catch unreachable;
        self.random_map_data = aya.mem.allocator.alloc(Randoms, w * h) catch unreachable;

        self.generateRandomData();

        // if we shrunk handle anything that needs to be fixed
        if (shrunk) {
            for (self.map.objects.items) |*anim| {
                if (anim.x >= w) anim.x = w - 1;
                if (anim.y >= h) anim.y = h - 1;
            }
        }
    }

    /// regenerates the stored random data per tile. Only needs to be called on seed change or map resize
    pub fn generateRandomData(self: *AppState) void {
        aya.math.rand.seed(self.map.seed);

        // pre-generate random data per tile
        var i: usize = 0;
        while (i < self.map.w * self.map.h) : (i += 1) {
            self.random_map_data[i] = .{
                .float = aya.math.rand.float(f32),
                .int = aya.math.rand.int(usize),
            };
        }
    }

    pub fn getProcessedTile(self: AppState, x: usize, y: usize) u32 {
        if (x >= self.map.w or y >= self.map.h) {
            return 0;
        }
        return self.processed_map_data[x + y * @intCast(usize, self.map.w)];
    }

    pub fn showToast(self: *AppState, text: []const u8, duration: i32) void {
        std.mem.copy(u8, &self.toast_text, text);
        self.toast_timer = duration;
    }

    pub fn saveMap(self: AppState, file: []const u8) !void {
        try persistence.save(self.map, file);
    }

    pub fn exportJson(self: AppState, file: []const u8) !void {
        try persistence.exportJson(self.map, self.final_map_data, file);
    }

    pub fn loadMap(self: *AppState, file: []const u8) !void {
        self.map = try persistence.load(file);
        self.map_rect_size = @intToFloat(f32, self.map.tile_size * self.prefs.tile_size_multiplier);

        const curr_dir = try std.fs.cwd().openDir(std.fs.path.dirname(file).?, .{});
        try curr_dir.setAsCwd();

        // unload old texture and load new texture
        try std.fs.cwd().access(self.map.image, .{});
        self.texture.deinit();
        self.texture = try Texture.initFromFile(self.map.image);

        // resize and clear processed_map_data and final_map_data
        aya.mem.allocator.free(self.processed_map_data);
        aya.mem.allocator.free(self.final_map_data);
        aya.mem.allocator.free(self.random_map_data);

        self.processed_map_data = try aya.mem.allocator.alloc(u8, self.map.w * self.map.h);
        self.final_map_data = try aya.mem.allocator.alloc(u8, self.map.w * self.map.h);
        self.random_map_data = aya.mem.allocator.alloc(Randoms, self.map.w * self.map.h) catch unreachable;
        self.map_data_dirty = true;
        self.tiles_per_row = 0;

        self.generateRandomData();

        // keep our file so we can save later
        if (self.opened_file != null) {
            aya.mem.allocator.free(self.opened_file.?);
        }
        self.opened_file = try aya.mem.allocator.dupe(u8, file);
    }
};
