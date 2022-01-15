const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
usingnamespace @import("imgui");

pub fn draw(state: *root.AppState) void {
    igPushStyleColorU32(ImGuiCol_ModalWindowDimBg, root.colors.rgbaToU32(20, 20, 20, 200));
    defer igPopStyleColor(1);

    ogSetNextWindowSize(.{ .x = 500, .y = -1 }, ImGuiCond_Always);
    var open: bool = true;
    if (igBeginPopupModal("Timeline Editor", &open, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        igText("Timeline Editor");
    }
}
