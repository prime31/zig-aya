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
    map_rect_size: f32 = 16,
    seed: u64 = 0,
    repeat: u8 = 20,
    map_data_dirty: bool = true,
    processed_map_data: []u8,
    final_map_data: []u8,
    // tileset state
    texture: Texture,
    // menu state
    windows: struct {
        brushes: bool = true,
        rules: bool = true,
        objects: bool = true,
        object_editor: bool = true,
        tag_editor: bool = true,
        input_map: bool = true,
        post_processed_map: bool = true,
        output_map: bool = true,
    },

    pub fn init() AppState {
        return .{
            .map = Map.init(),
            .processed_map_data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .final_map_data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
            .texture = Texture.initFromFile("assets/minimal_tiles.png") catch unreachable,
            // .texture = Texture.initCheckerboard(),
            .windows = .{},
        };
    }

    /// returns the number of tiles in each row of the tileset image
    pub fn tilesPerRow(self: AppState) usize {
        return @intCast(usize, self.texture.width) / @intCast(usize, self.map.tile_size);
    }

    pub fn mapSize(self: AppState) ImVec2 {
        return ImVec2{ .x = @intToFloat(f32, self.map.w) * self.map_rect_size, .y = @intToFloat(f32, self.map.h) * self.map_rect_size };
    }

    /// resizes the map and all of the sub-maps
    pub fn resizeMap(self: *AppState, w: usize, h: usize) void {
        history.reset();
        self.map_data_dirty = true;

        // map data is our source so we need to copy the old data over
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

        // resize our two generate maps
        aya.mem.allocator.free(self.processed_map_data);
        aya.mem.allocator.free(self.final_map_data);
        self.processed_map_data = aya.mem.allocator.alloc(u8, w * h) catch unreachable;
        self.final_map_data = aya.mem.allocator.alloc(u8, w * h) catch unreachable;
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
    }
};

pub const TileKit = struct {
    state: AppState,

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

/// helper to find the tile under the mouse given a top-left position of the grid and a grid size
pub fn tileIndexUnderMouse(rect_size: usize, screen_space_offset: ImVec2) struct { x: usize, y: usize } {
    var pos = igGetIO().MousePos;
    pos.x -= screen_space_offset.x;
    pos.y -= screen_space_offset.y;

    return .{ .x = @divTrunc(@floatToInt(usize, pos.x), rect_size), .y = @divTrunc(@floatToInt(usize, pos.y), rect_size) };
}