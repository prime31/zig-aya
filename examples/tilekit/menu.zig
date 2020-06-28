const std = @import("std");
const print = std.debug.print;
usingnamespace @import("imgui");

const aya = @import("aya");

pub const Menu = struct {
    brushes: bool = true,
    rules: bool = true,
    input_map: bool = false,
    output_map: bool = false,

    pub fn init() Menu {
        return .{};
    }

    fn checkKeyboardShortcuts(self: *Menu) void {
        if (aya.input.keyPressed(.SDL_SCANCODE_B)) {
            if (igIsPopupOpenID(igGetIDStr("brushes"))) {
                igClosePopupToLevel(0, true);
            } else {
                igOpenPopup("brushes");
            }
        }
    }

    pub fn draw(self: *Menu) void {
        self.checkKeyboardShortcuts();

        var showLoadTilesetPopup = false;
        var showResizePopup = false;

        if (igBeginMenuBar()) {
            defer igEndMenuBar();

            if (igBeginMenu("TileKit", true)) {
                defer igEndMenu();

                if (igMenuItemBool("Menu Thing", null, false, true)) {
                    std.debug.print("fucker\n", .{});
                }
            }

            if (igBeginMenu("Map", true)) {
                defer igEndMenu();

                showLoadTilesetPopup = igMenuItemBool("Load Tileset", null, false, true);
                showResizePopup = igMenuItemBool("Resize Map", null, false, true);
            }

            if (igBeginMenu("View", true)) {
                defer igEndMenu();

                if (igMenuItemBool("Brushes", null, self.brushes, true)) {
                    self.brushes = !self.brushes;
                }

                if (igMenuItemBool("Rules", null, self.rules, true)) {
                    self.rules = !self.rules;
                }

                if (igMenuItemBool("Input Map", null, self.input_map, true)) {
                    self.input_map = !self.input_map;
                }

                if (igMenuItemBool("Output Map", null, self.output_map, true)) {
                    self.output_map = !self.output_map;
                }
            }
        }

        // handle popups in the same scope
        if (showLoadTilesetPopup) {
            igOpenPopup("Load Tileset");
        }

        if (showResizePopup) {
            igOpenPopup("Resize Map");
        }

        self.loadTilesetPopup();
        self.resizeMapPopup();
    }

    var buffer: [100]u8 = undefined;
    var tile_size: c_int = 16;
    var tile_spacing: c_int = 0;
    var map_width: c_int = 64;
    var map_height: c_int = 64;

    fn loadTilesetPopup(self: *Menu) void {
        if (igBeginPopupModal("Load Tileset", null, ImGuiWindowFlags_AlwaysAutoResize)) {
            defer igEndPopup();

            _ = igInputText("Tileset file", &buffer, 100, ImGuiInputTextFlags_None, null, null);
            _ = igDragInt("Tile Size", &tile_size, 0.5, 0, 32, null);
            _ = igDragInt("Tile Spacing", &tile_spacing, 0.5, 0, 8, null);
            igSeparator();

            var size: ImVec2 = undefined;
            igGetContentRegionAvail(&size);
            if (igButton("Cancel", ImVec2{.x = (size.x - 4) / 2})) {
                igCloseCurrentPopup();
            }
            igSameLine(0, 4);
            if (igButton("Load", ImVec2{.x = -1, .y = 0})) {
                igCloseCurrentPopup();
            }
        }
    }

    fn resizeMapPopup(self: *Menu) void {
        if (igBeginPopupModal("Resize Map", null, ImGuiWindowFlags_AlwaysAutoResize)) {
            defer igEndPopup();

            _ = igDragInt("Width", &map_width, 0.5, 0, 256, null);
            _ = igDragInt("Height", &map_height, 0.5, 0, 256, null);
            igSeparator();

            var size: ImVec2 = undefined;
            igGetContentRegionAvail(&size);
            if (igButton("Cancel", ImVec2{.x = (size.x - 4) / 2})) {
                igCloseCurrentPopup();
            }
            igSameLine(0, 4);
            if (igButton("Apply", ImVec2{.x = -1, .y = 0})) {
                igCloseCurrentPopup();
            }
        }
    }
};
