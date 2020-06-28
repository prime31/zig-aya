const std = @import("std");
const print = std.debug.print;
usingnamespace @import("imgui");

const rules_win = @import("rules_win.zig");
const brushes_win = @import("brushes_win.zig");
const input_map_win = @import("input_map_win.zig");
const output_map_win = @import("output_map_win.zig");

const Map = @import("data.zig").Map;
const Menu = @import("menu.zig").Menu;

pub const TileKit = struct {
    map: Map,
    menu: Menu,

    pub fn init() TileKit {
        @import("colors.zig").init();
        return .{
            .map = Map.init(null),
            .menu = Menu.init(),
        };
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
        const dockspace_id = igGetIDStr("MyDockSpace");
        // igDockBuilderRemoveNode(dockspace_id);
        if (igDockBuilderGetNode(dockspace_id) == null) {
            self.initialLayout(dockspace_id, work_size);
        }

        igDockSpace(dockspace_id, ImVec2{}, ImGuiDockNodeFlags_None, null);

        self.menu.draw();

        rules_win.draw(&self.menu.rules, &self.map);
        brushes_win.drawWindow(&self.menu.brushes);
        input_map_win.drawWindow(&self.menu.input_map);
        output_map_win.drawWindow(&self.menu.output_map);

        brushes_win.drawPopup();

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
        igDockBuilderFinish(id);
    }
};
