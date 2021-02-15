const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");
usingnamespace @import("data/data.zig");

pub const renderer: aya.renderkit.Renderer = .opengl;

pub const utils = @import("utils.zig");
pub const menu = @import("menu.zig");
pub const data = @import("data/data.zig");
pub const colors = @import("colors.zig");
pub const windows = @import("windows/windows.zig");
pub const layers = @import("layers/layers.zig");

pub const Camera = @import("camera.zig").Camera;
pub const AssetManager = @import("asset_manager.zig").AssetManager;

pub const enable_imgui = true;
var next_stall_time: f32 = 10;

// global state
pub var state: AppState = undefined;
pub var scene: windows.Scene = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .onFileDropped = onFileDropped,
        .gfx = .{
            .resolution_policy = .none,
        },
        .window = .{
            .width = 1280,
            .height = 800,
            .title = "Aya Edit",
        },
    });
}

fn init() !void {
    colors.init();
    state = AppState.init();
    state.addTestData();
    scene = windows.Scene.init();

    var io = igGetIO();
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    io.ConfigDockingWithShift = true;

    igGetStyle().FrameRounding = 0;
    igGetStyle().WindowRounding = 0;
}

fn shutdown() !void {
    scene.deinit();
    state.deinit();
}

fn update() !void {
    beginDock();

    menu.draw(&state);
    windows.layers.draw(&state);
    windows.assets.draw(&state);

    scene.draw(&state); // AFTER layers, in case any layers were removed

    // ensure our windows are always present so they can be arranged sanely and dont jump into and out of existence
    inline for (&[_][:0]const u8{ "Assets", "Inspector###Inspector", "Entities###Entities" }) |name| {
        _ = igBegin(name, null, ImGuiWindowFlags_None);
        igEnd();
    }

    // file picker tester
    var open_picker = false;
    if (igBegin("debug", null, ImGuiWindowFlags_None)) {
        if (ogButton("Open Sesame")) {
            utils.file_picker.setup("Farty", true, false);
            open_picker = true;
        }
    }
    igEnd();

    if (open_picker) ogOpenPopup("File Picker");

    if (igBeginPopupModal("File Picker", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();
        if (utils.file_picker.draw()) |res| {
            std.debug.print("done with picker: {s}, {s}\n", .{ utils.file_picker.selected_dir, utils.file_picker.selected_file });
            igCloseCurrentPopup();
        }
    }

    // igShowDemoWindow(null);

    igEnd();
}

fn render() !void {
    aya.gfx.beginNullPass();
    aya.gfx.beginPass(.{ .color = aya.math.Color.black });
    aya.gfx.endPass();

    // stall whenever we dont have events so that we render as little as possible. each event causes a 5s no-stall time.
    if (aya.time.seconds() > next_stall_time) {
        var evt: aya.sdl.SDL_Event = undefined;
        if (aya.sdl.SDL_WaitEventTimeout(&evt, 5000) == 1) {
            _ = aya.sdl.SDL_PushEvent(&evt);
            next_stall_time = aya.time.seconds() + 5;
        }
        aya.time.resync();
    }
}

fn onFileDropped(file: [:0]const u8) void {
    scene.onFileDropped(&state, file);
}

fn beginDock() void {
    const vp = igGetMainViewport();
    var work_pos = ImVec2{};
    var work_size = ImVec2{};
    ImGuiViewport_GetWorkPos(&work_pos, vp);
    ImGuiViewport_GetWorkSize(&work_size, vp);

    ogSetNextWindowPos(work_pos, ImGuiCond_Always, .{});
    ogSetNextWindowSize(work_size, ImGuiCond_Always);
    igSetNextWindowViewport(vp.ID);

    var window_flags = ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_MenuBar;
    window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
    window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus;

    ogPushStyleVarVec2(ImGuiStyleVar_WindowPadding, .{});
    _ = igBegin("Dockspace", null, window_flags);
    igPopStyleVar(1);

    const io = igGetIO();
    const dockspace_id = igGetIDStr("aya-dockspace");
    // igDockBuilderRemoveNode(dockspace_id); // uncomment for testing initial layout setup code
    if (igDockBuilderGetNode(dockspace_id) == null) {
        var dock_main_id = igDockBuilderAddNode(dockspace_id, ImGuiDockNodeFlags_DockSpace | ImGuiDockNodeFlags_NoCloseButton | ImGuiDockNodeFlags_NoWindowMenuButton);
        ogDockBuilderSetNodeSize(dockspace_id, work_size);
        setupDockLayout(dock_main_id);
    }

    ogDockSpace(dockspace_id, .{}, ImGuiDockNodeFlags_NoCloseButton | ImGuiDockNodeFlags_NoWindowMenuButton, null);
}

fn setupDockLayout(id: ImGuiID) void {
    var dock_main_id = id;

    // dock_main_id is the left node after this
    const right_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Right, 0.3, null, &dock_main_id);

    // dock_main_id is the center node after this
    const left_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Left, 0.3, null, &dock_main_id);

    // bottom_left_id is the bottom node after this
    var bottom_left_id: ImGuiID = 0;
    const top_left_id = igDockBuilderSplitNode(left_id, ImGuiDir_Up, 0.35, null, &bottom_left_id);
    igDockBuilderDockWindow("Layers", top_left_id);
    igDockBuilderDockWindow("###Entities", bottom_left_id);

    // bottom_left_id is the bottom node after this
    var bottom_right_id: ImGuiID = 0;
    var top_right_id = igDockBuilderSplitNode(right_id, ImGuiDir_Up, 0.65, null, &bottom_right_id);
    igDockBuilderDockWindow("###Inspector", top_right_id);

    // dock_main_id is the bottom node after this
    const tl_id = igDockBuilderSplitNode(dock_main_id, ImGuiDir_Up, 0.8, null, &dock_main_id);
    igDockBuilderDockWindow("Scene", tl_id);
    igDockBuilderDockWindow("Assets", dock_main_id);

    igDockBuilderFinish(id);
}
