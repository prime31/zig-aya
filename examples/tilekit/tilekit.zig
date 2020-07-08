const std = @import("std");
const print = std.debug.print;
usingnamespace @import("imgui");
const aya = @import("aya");
const Texture = aya.gfx.Texture;

const rules_win = @import("windows/rules.zig");
const brushes_win = @import("windows/brushes.zig");
const tags_win = @import("windows/tags.zig");
const objects_win = @import("windows/objects.zig");
const object_editor_win = @import("windows/object_editor.zig");
const animations_win = @import("windows/animations.zig");
const input_map_wins = @import("windows/maps.zig");
const output_map_win = @import("windows/output_map.zig");

const menu = @import("menu.zig");
const persistence = @import("persistence.zig");

pub const data = @import("data.zig");
pub const history = @import("history.zig");
pub const colors = @import("colors.zig");

pub const Map = data.Map;
pub const drawBrush = brushes_win.drawBrush;

const files = @import("filebrowser");

pub const AppState = struct {
    map: Map,
    // general state
    object_edit_mode: bool = false,
    selected_brush_index: usize = 0,
    texture: Texture,
    tiles_per_row: usize = 0,
    map_rect_size: f32 = 12,
    // map data
    map_data_dirty: bool = true,
    processed_map_data: []u8,
    final_map_data: []u8,
    prefs: Prefs = .{
        .windows = .{},
    },

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

        return .{
            .map = map,
            .map_rect_size = @intToFloat(f32, tile_size * prefs.tile_size_multiplier),
            .processed_map_data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .final_map_data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .texture = Texture.initFromFile("assets/blacknwhite.png") catch unreachable,
            // .texture = Texture.initCheckerboard(),
            .prefs = prefs,
        };
    }

    pub fn savePrefs(self: AppState) void {
        aya.fs.savePrefsJson("aya_tile", "prefs.json", self.prefs) catch unreachable;
    }

    /// returns the number of tiles in each row of the tileset image
    pub fn tilesPerRow(self: *AppState) usize {
        // calculate tiles_per_row if needed
        if (self.tiles_per_row == 0) {
            var accum: usize = self.map.tile_margin * 2;
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
        var accum: usize = self.map.tile_margin * 2;
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
        history.reset();
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
        self.processed_map_data = aya.mem.allocator.alloc(u8, w * h) catch unreachable;
        self.final_map_data = aya.mem.allocator.alloc(u8, w * h) catch unreachable;

        // if we shrunk handle anything that needs to be fixed
        if (shrunk) {
            for (self.map.objects.items) |*anim| {
                if (anim.x >= w) anim.x = w - 1;
                if (anim.y >= h) anim.y = h - 1;
            }
        }
    }

    pub fn getProcessedTile(self: AppState, x: usize, y: usize) u32 {
        if (x >= self.map.w or y >= self.map.h) {
            return 0;
        }
        return self.processed_map_data[x + y * @intCast(usize, self.map.w)];
    }

    pub fn saveMap(self: AppState, file: []const u8) !void {
        try persistence.save(self.map, file);
    }

    pub fn exportJson(self: AppState, file: []const u8) !void {
        try persistence.exportJson(self.map, self.final_map_data, file);
    }

    pub fn loadMap(self: *AppState, file: []const u8) !void {
        self.map = try persistence.load(file);

        // unload old texture
        // load new texture

        // resize and clear processed_map_data and final_map_data
        aya.mem.allocator.free(self.processed_map_data);
        aya.mem.allocator.free(self.final_map_data);

        self.processed_map_data = try aya.mem.allocator.alloc(u8, self.map.w * self.map.h);
        self.final_map_data = try aya.mem.allocator.alloc(u8, self.map.w * self.map.h);
        self.map_data_dirty = true;
        self.tiles_per_row = 0;
    }
};

pub const TileKit = struct {
    state: AppState,
    toast_timer: i32 = -1,
    toast_text: [255]u8 = undefined,

    pub fn init() TileKit {
        colors.init();
        history.init();
        return .{ .state = AppState.init() };
    }

    pub fn deinit(self: TileKit) void {
        history.deinit();
        self.state.texture.deinit();
        self.state.map.deinit();
        aya.mem.allocator.free(self.state.processed_map_data);
        aya.mem.allocator.free(self.state.final_map_data);
    }

    pub fn handleDroppedFile(self: *TileKit, file: []const u8) void {
        if (std.mem.endsWith(u8, file, ".tk")) {
            self.state.loadMap(file) catch unreachable;
        } else if (std.mem.endsWith(u8, file, ".png")) {
            menu.loadTileset(file);
        }
    }

    pub fn showToast(self: *TileKit, text: []const u8, duration: i32) void {
        std.mem.copy(u8, &self.toast_text, text);
        self.toast_timer = duration;
    }

    pub fn draw(self: *TileKit) void {
        var window_flags = ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_MenuBar;
        const vp = igGetMainViewport();
        var work_pos = ImVec2{};
        var work_size = ImVec2{};
        ImGuiViewport_GetWorkPos(&work_pos, vp);
        ImGuiViewport_GetWorkSize(&work_size, vp);

        igSetNextWindowPos(work_pos, ImGuiCond_Always, ImVec2{});
        igSetNextWindowSize(work_size, ImGuiCond_Always);
        igSetNextWindowViewport(vp.ID);
        igPushStyleVarFloat(ImGuiStyleVar_WindowRounding, 0);
        igPushStyleVarFloat(ImGuiStyleVar_WindowBorderSize, 0);
        window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
        window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus;

        igPushStyleVarVec2(ImGuiStyleVar_WindowPadding, ImVec2{});
        _ = igBegin("Dockspace", null, window_flags);
        igPopStyleVar(2);

        const io = igGetIO();
        const dockspace_id = igGetIDStr("default-dockspace");
        // igDockBuilderRemoveNode(dockspace_id); // uncomment for setting up initial layout
        if (igDockBuilderGetNode(dockspace_id) == null) {
            self.initialLayout(dockspace_id, work_size);
        }

        igDockSpace(dockspace_id, ImVec2{}, ImGuiDockNodeFlags_None, null);

        menu.draw(&self.state);

        rules_win.draw(&self.state);
        brushes_win.drawWindow(&self.state);
        input_map_wins.drawWindows(&self.state);
        output_map_win.drawWindow(&self.state);
        brushes_win.drawPopup(&self.state);
        tags_win.draw(&self.state);
        objects_win.draw(&self.state);
        object_editor_win.draw(&self.state);
        animations_win.draw(&self.state);

        // toast notifications
        if (self.toast_timer > 0) {
            self.toast_timer -= 1;

            igPushStyleColorU32(ImGuiCol_WindowBg, colors.colorRgba(90, 90, 130, 255));
            igSetNextWindowPos(ImVec2{ .x = 5, .y = 40 }, ImGuiCond_Always, ImVec2{});
            if (igBegin("Toast Notification", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav)) {
                defer igEnd();

                igText(&self.toast_text[0]);

                if (igIsItemHovered(ImGuiHoveredFlags_None) and igIsMouseClicked(ImGuiMouseButton_Left, false)) {
                    self.toast_timer = -1;
                }
            }
            igPopStyleColor(1);
        }

        // igShowDemoWindow(null);
        igEnd();
    }

    fn initialLayout(self: TileKit, id: ImGuiID, size: ImVec2) void {
        print("----------- initial layout\n", .{});

        _ = igDockBuilderAddNode(id, ImGuiDockNodeFlags_DockSpace);
        igDockBuilderSetNodeSize(id, size);

        var dock_main_id = id;
        const right_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Right, 0.3, null, &dock_main_id);
        igDockBuilderDockWindow("Rules", right_id);

        // dock_main_id = id;
        const left_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Left, 1, null, &dock_main_id);

        const tl_id = igDockBuilderSplitNode(left_id, ImGuiDir_Up, 0.5, null, &dock_main_id);
        igDockBuilderDockWindow("Input Map", tl_id);

        const br_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Down, 1, null, &dock_main_id);
        igDockBuilderDockWindow("Output Map", br_id);

        igDockBuilderFinish(id);
    }
};

// TODO: move these to a common utility file along with methods to draw brushes popup and tileset popup with single/multiple selection

/// helper to find the tile under the mouse given a top-left position of the grid and a grid size
pub fn tileIndexUnderMouse(rect_size: usize, origin: ImVec2) struct { x: usize, y: usize } {
    var pos = igGetIO().MousePos;
    pos.x -= origin.x;
    pos.y -= origin.y;

    return .{ .x = @divTrunc(@floatToInt(usize, pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, pos.y), rect_size) };
}

pub fn tileIndexUnderPos(position: ImVec2, rect_size: usize, origin: ImVec2) struct { x: usize, y: usize } {
    var pos = position;
    pos.x -= origin.x;
    pos.y -= origin.y;

    return .{ .x = @divTrunc(@floatToInt(usize, pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, pos.y), rect_size) };
}

/// helper to draw an image button with an image from the tileset
pub fn tileImageButton(state: *AppState, size: f32, tile: usize) bool {
    const rect = uvsForTile(state, tile);
    const uv0 = ImVec2{ .x = rect.x, .y = rect.y };
    const uv1 = ImVec2{ .x = rect.x + rect.w, .y = rect.y + rect.h };

    const tint = colors.colorRgbaVec4(255, 255, 255, 255);
    return igImageButton(state.texture.tex, ImVec2{ .x = size, .y = size }, uv0, uv1, 2, ImVec4{ .w = 1 }, tint);
}

pub fn uvsForTile(state: *AppState, tile: usize) aya.math.Rect {
    const x = @intToFloat(f32, @mod(tile, state.tilesPerRow()));
    const y = @intToFloat(f32, @divTrunc(tile, state.tilesPerRow()));

    const inv_w = 1.0 / @intToFloat(f32, state.texture.width);
    const inv_h = 1.0 / @intToFloat(f32, state.texture.height);

    return .{
        .x = (x * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) + @intToFloat(f32, state.map.tile_margin)) * inv_w,
        .y = (y * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) + @intToFloat(f32, state.map.tile_margin)) * inv_h,
        .w = @intToFloat(f32, state.map.tile_size) * inv_w,
        .h = @intToFloat(f32, state.map.tile_size) * inv_h,
    };
}
