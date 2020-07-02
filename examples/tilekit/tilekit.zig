const std = @import("std");
const print = std.debug.print;
usingnamespace @import("imgui");
const aya = @import("aya");
const Texture = aya.gfx.Texture;

const rules_win = @import("rules_win.zig");
const brushes_win = @import("brushes_win.zig");
const input_map_wins = @import("map_windows.zig");
const output_map_win = @import("output_map_win.zig");

const menu = @import("menu.zig");
const persistence = @import("persistence.zig");

pub const Map = @import("data.zig").Map;
pub const drawBrush = brushes_win.drawBrush;

const files = @import("filebrowser");

pub const AppState = struct {
    map: Map,
    // general state
    selected_brush_index: usize = 0,
    map_rect_size: f32 = 16,
    processed_map_data: []u8,
    // tileset state
    texture: Texture,
    // menu state
    brushes: bool = true,
    rules: bool = true,
    input_map: bool = true,
    post_processed_map: bool = false,
    output_map: bool = true,

    /// returns the number of tiles in each row of the tileset image
    pub fn tilesPerRow(self: AppState) usize {
        return @intCast(usize, self.texture.width) / @intCast(usize, self.map.tile_size);
    }

    pub fn mapSize(self: AppState) ImVec2 {
        return ImVec2{ .x = @intToFloat(f32, self.map.w) * self.map_rect_size, .y = @intToFloat(f32, self.map.h) * self.map_rect_size };
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

    pub fn loadMap(self: *AppState, file: []const u8) !void {
        self.map = try persistence.load(file);
    }
};

pub const TileKit = struct {
    state: AppState,

    pub fn init() TileKit {
        @import("colors.zig").init();
        return.{
            .state = AppState{
                .map = Map.init(),
                .processed_map_data = aya.mem.allocator.alloc(u8, 64 * 64) catch unreachable,
                .texture = Texture.initFromFile("assets/minimal_tiles.png") catch unreachable,
                // .texture = Texture.initCheckerboard(),
            },
        };
    }

    pub fn deinit(self: TileKit) void {
        self.state.texture.deinit();
        self.state.map.deinit();
        aya.mem.allocator.free(self.state.processed_map_data);
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
