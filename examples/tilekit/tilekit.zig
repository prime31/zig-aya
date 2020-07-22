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

pub const data = @import("map.zig");
pub const history = @import("history.zig");
pub const colors = @import("colors.zig");

pub const AppState = @import("app_state.zig").AppState;
pub const Map = data.Map;
pub const drawBrush = brushes_win.drawBrush;

const files = @import("filebrowser");

pub const TileKit = struct {
    state: AppState,

    pub fn init() TileKit {
        colors.init();
        history.init();
        setupDefaults();
        return .{ .state = AppState.init() };
    }

    pub fn deinit(self: TileKit) void {
        history.deinit();
        self.state.texture.deinit();
        self.state.map.deinit();
        aya.mem.allocator.free(self.state.processed_map_data);
        aya.mem.allocator.free(self.state.final_map_data);
        aya.mem.allocator.free(self.state.random_map_data);
    }

    pub fn handleDroppedFile(self: *TileKit, file: []const u8) void {
        if (std.mem.endsWith(u8, file, ".tk") or std.mem.endsWith(u8, file, ".tkp")) {
            self.state.loadMap(file) catch unreachable;
        } else if (std.mem.endsWith(u8, file, ".png")) {
            menu.loadTileset(file);
        } else {
            self.state.showToast("Invalid file.", 100);
        }
    }

    fn setupDefaults() void {
        igGetStyle().WindowRounding = 0;
        igGetStyle().WindowBorderSize = 0;
        igGetStyle().WindowMenuButtonPosition = ImGuiDir_None;
    }

    pub fn draw(self: *TileKit) void {
        var window_flags = ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_MenuBar;
        const vp = igGetMainViewport();
        var work_pos = ImVec2{};
        var work_size = ImVec2{};
        ImGuiViewport_GetWorkPos(&work_pos, vp);
        ImGuiViewport_GetWorkSize(&work_size, vp);

        igSetNextWindowPos(work_pos, ImGuiCond_Always, .{});
        igSetNextWindowSize(work_size, ImGuiCond_Always);
        igSetNextWindowViewport(vp.ID);
        window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
        window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus;

        igPushStyleVarVec2(ImGuiStyleVar_WindowPadding, .{});
        _ = igBegin("Dockspace", null, window_flags);
        igPopStyleVar(1);

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
        brushes_win.drawPopup(&self.state, "##brushes-root");
        tags_win.draw(&self.state);
        objects_win.draw(&self.state);
        object_editor_win.draw(&self.state);
        animations_win.draw(&self.state);

        // toast notifications
        if (self.state.toast_timer > 0) {
            self.state.toast_timer -= 1;

            igPushStyleColorU32(ImGuiCol_WindowBg, colors.colorRgba(90, 90, 130, 255));
            igSetNextWindowPos(ogGetWindowCenter(), ImGuiCond_Always, .{ .x = 0.5, .y = 0.5 });
            if (igBegin("Toast Notification", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav)) {
                igText(&self.state.toast_text[0]);

                if (igIsItemHovered(ImGuiHoveredFlags_None) and igIsMouseClicked(ImGuiMouseButton_Left, false)) {
                    self.state.toast_timer = -1;
                }
            }
            igEnd();
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
        .x = (x * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) + @intToFloat(f32, state.map.tile_spacing)) * inv_w,
        .y = (y * @intToFloat(f32, state.map.tile_size + state.map.tile_spacing) + @intToFloat(f32, state.map.tile_spacing)) * inv_h,
        .w = @intToFloat(f32, state.map.tile_size) * inv_w,
        .h = @intToFloat(f32, state.map.tile_size) * inv_h,
    };
}

/// adds a tile selection indicator to the draw list with an outline rectangle and a fill rectangle. Works for both tilesets and palettes.
pub fn addTileToDrawList(tile_size: usize, content_start_pos: ImVec2, tile: u8, per_row: usize, tile_spacing: usize) void {
    const x = @mod(tile, per_row);
    const y = @divTrunc(tile, per_row);

    var tl = ImVec2{ .x = @intToFloat(f32, x) * @intToFloat(f32, tile_size + tile_spacing), .y = @intToFloat(f32, y) * @intToFloat(f32, tile_size + tile_spacing) };
    tl.x += content_start_pos.x + @intToFloat(f32, tile_spacing);
    tl.y += content_start_pos.y + @intToFloat(f32, tile_spacing);
    ogAddQuadFilled(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size), colors.rule_result_selected_fill);

    // offset by 1 extra pixel because quad outlines are drawn larger than the size passed in and we shrink the size by our outline width
    tl.x += 1;
    tl.y += 1;
    ogAddQuad(igGetWindowDrawList(), tl, @intToFloat(f32, tile_size - 2), colors.rule_result_selected_outline, 2);
}
