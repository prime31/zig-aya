const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");
usingnamespace @import("data/data.zig");

pub const menu = @import("menu.zig");
pub const colors = @import("colors.zig");
pub const windows = @import("windows/windows.zig");

pub const Camera = @import("camera.zig").Camera;

pub const Editor = struct {
    state: AppState,
    scene: windows.Scene,

    pub fn init() Editor {
        colors.init();
        return .{
            .state = AppState.initWithTestData(),
            .scene = windows.Scene.init(),
        };
    }

    pub fn deinit(self: @This()) void {
        self.scene.deinit();
        self.state.deinit();
    }

    pub fn update(self: *@This()) void {
        menu.draw(&self.state);

        windows.layers.draw(&self.state);
        self.scene.draw(&self.state); // AFTER layers, in case any layers were removed
        windows.entities.draw(&self.state);
        windows.inspector.draw(&self.state);

        _ = igBegin("Assets", null, ImGuiWindowFlags_None);
        igEnd();

        // igShowDemoWindow(null);
        // _ = igBegin("sadfasdf", null, ImGuiWindowFlags_None);
        // if (igColorEdit4("fart", &colors.ui_tint.x, ImGuiColorEditFlags_NoInputs)) {
        //     colors.setTintColor(colors.ui_tint);
        // }
        // igEnd();
    }
};
