const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");

pub const utils = @import("utils.zig");
pub const menu = @import("menu.zig");
pub const data = @import("data/data.zig");
pub const colors = @import("colors.zig");
pub const windows = @import("windows/windows.zig");
pub const layers = @import("layers/layers.zig");
pub const persistence = @import("persistence.zig");

pub const Camera = @import("camera.zig").Camera;
pub const AssetManager = @import("asset_manager.zig").AssetManager;
pub const AppState = @import("data/app_state.zig").AppState;

pub const enable_imgui = true;
var next_stall_time: f32 = 10;

// global state
pub var state: data.AppState = undefined;
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
    state = data.AppState.init();
    state.addTestData();
    scene = windows.Scene.init();

    var io = imgui.igGetIO();
    io.ConfigFlags |= imgui.ImGuiConfigFlags_DockingEnable;
    io.ConfigDockingWithShift = true;

    imgui.igGetStyle().FrameRounding = 0;
    imgui.igGetStyle().WindowRounding = 0;
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
        _ = imgui.igBegin(name, null, imgui.ImGuiWindowFlags_None);
        imgui.igEnd();
    }

    // imgui.igShowDemoWindow(null);

    imgui.igEnd();
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
    const vp = imgui.igGetMainViewport();
    var work_pos = imgui.ImVec2{};
    var work_size = imgui.ImVec2{};
    imgui.ImGuiViewport_GetWorkPos(&work_pos, vp);
    imgui.ImGuiViewport_GetWorkSize(&work_size, vp);

    imgui.ogSetNextWindowPos(work_pos, imgui.ImGuiCond_Always, .{});
    imgui.ogSetNextWindowSize(work_size, imgui.ImGuiCond_Always);
    imgui.igSetNextWindowViewport(vp.ID);

    var window_flags = imgui.ImGuiWindowFlags_NoDocking | imgui.ImGuiWindowFlags_MenuBar;
    window_flags |= imgui.ImGuiWindowFlags_NoTitleBar | imgui.ImGuiWindowFlags_NoCollapse | imgui.ImGuiWindowFlags_NoResize | imgui.ImGuiWindowFlags_NoMove;
    window_flags |= imgui.ImGuiWindowFlags_NoBringToFrontOnFocus | imgui.ImGuiWindowFlags_NoNavFocus;

    imgui.ogPushStyleVarVec2(imgui.ImGuiStyleVar_WindowPadding, .{});
    _ = imgui.igBegin("Dockspace", null, window_flags);
    imgui.igPopStyleVar(1);

    const dockspace_id = imgui.igGetIDStr("aya-dockspace");
    // imgui.igDockBuilderRemoveNode(dockspace_id); // uncomment for testing initial layout setup code
    if (imgui.igDockBuilderGetNode(dockspace_id) == null) {
        var dock_main_id = imgui.igDockBuilderAddNode(dockspace_id, imgui.ImGuiDockNodeFlags_DockSpace | imgui.ImGuiDockNodeFlags_NoCloseButton | imgui.ImGuiDockNodeFlags_NoWindowMenuButton);
        imgui.ogDockBuilderSetNodeSize(dockspace_id, work_size);
        setupDockLayout(dock_main_id);
    }

    imgui.ogDockSpace(dockspace_id, .{}, imgui.ImGuiDockNodeFlags_NoCloseButton | imgui.ImGuiDockNodeFlags_NoWindowMenuButton, null);
}

fn setupDockLayout(id: imgui.ImGuiID) void {
    var dock_main_id = id;

    // dock_main_id is the left node after this
    const right_id = imgui.igDockBuilderSplitNode(dock_main_id, imgui.ImGuiDir_Right, 0.3, null, &dock_main_id);

    // dock_main_id is the center node after this
    const left_id = imgui.igDockBuilderSplitNode(dock_main_id, imgui.ImGuiDir_Left, 0.3, null, &dock_main_id);

    // bottom_left_id is the bottom node after this
    var bottom_left_id: imgui.ImGuiID = 0;
    const top_left_id = imgui.igDockBuilderSplitNode(left_id, imgui.ImGuiDir_Up, 0.35, null, &bottom_left_id);
    imgui.igDockBuilderDockWindow("Layers", top_left_id);
    imgui.igDockBuilderDockWindow("###Entities", bottom_left_id);

    // bottom_left_id is the bottom node after this
    var bottom_right_id: imgui.ImGuiID = 0;
    var top_right_id = imgui.igDockBuilderSplitNode(right_id, imgui.ImGuiDir_Up, 0.65, null, &bottom_right_id);
    imgui.igDockBuilderDockWindow("###Inspector", top_right_id);

    // dock_main_id is the bottom node after this
    const tl_id = imgui.igDockBuilderSplitNode(dock_main_id, imgui.ImGuiDir_Up, 0.8, null, &dock_main_id);
    imgui.igDockBuilderDockWindow("Scene", tl_id);
    imgui.igDockBuilderDockWindow("Assets", dock_main_id);

    imgui.igDockBuilderFinish(id);
}
