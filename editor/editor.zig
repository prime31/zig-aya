const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");

pub const menu = @import("menu.zig");
pub const colors = @import("colors.zig");
pub const windows = @import("windows/windows.zig");

pub const Editor = struct {
    scene: windows.Scene,

    pub fn init() Editor {
        return .{
            .scene = windows.Scene.init(),
        };
    }

    pub fn deinit(self: @This()) void {
        self.scene.deinit();
    }

    pub fn update(self: *@This()) void {
        menu.draw();

        igPushStyleVarVec2(ImGuiStyleVar_WindowPadding, .{});
        if (igBegin("Scene", null, ImGuiWindowFlags_NoScrollbar)) self.scene.update();
        igEnd();
        igPopStyleVar(1);

        _ = igBegin("Entities", null, ImGuiWindowFlags_None);
        igEnd();

       _ = igBegin("Inspector", null, ImGuiWindowFlags_None);
        igEnd();

        _ = igBegin("Assets", null, ImGuiWindowFlags_None);
        igEnd();
    }
};
