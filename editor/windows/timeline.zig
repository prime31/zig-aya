const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
const imgui = @import("imgui");

pub fn draw(_: *root.AppState) void {
    imgui.igPushStyleColorU32(imgui.ImGuiCol_ModalWindowDimBg, root.colors.rgbaToU32(20, 20, 20, 200));
    defer imgui.igPopStyleColor(1);

    imgui.ogSetNextWindowSize(.{ .x = 500, .y = -1 }, imgui.ImGuiCond_Always);
    var open: bool = true;
    if (imgui.igBeginPopupModal("Timeline Editor", &open, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        defer imgui.igEndPopup();

        imgui.igText("Timeline Editor");
    }
}
