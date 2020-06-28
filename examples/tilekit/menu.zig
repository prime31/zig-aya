const std = @import("std");
const tk = @import("tilekit.zig");
usingnamespace @import("imgui");

const aya = @import("aya");
var buffer: [100]u8 = undefined;

var temp_state = struct {
    tile_size: c_int = 16,
    tile_spacing: c_int = 0,
    map_width: c_int = 64,
    map_height: c_int = 64,

    pub fn reset(self: *@This()) void {
        self.tile_size = 16;
        self.tile_spacing = 0;
        self.map_width = 64;
        self.map_height = 64;
    }
}{};

fn checkKeyboardShortcuts() void {
    if (aya.input.keyPressed(.SDL_SCANCODE_B)) {
        if (igIsPopupOpenID(igGetIDStr("brushes"))) {
            igClosePopupToLevel(0, true);
        } else {
            igOpenPopup("brushes");
        }
    }
}

pub fn draw(state: *tk.AppState) void {
    checkKeyboardShortcuts();

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

            if (igMenuItemBool("Brushes", null, state.brushes, true)) {
                state.brushes = !state.brushes;
            }

            if (igMenuItemBool("Rules", null, state.rules, true)) {
                state.rules = !state.rules;
            }

            if (igMenuItemBool("Input Map", null, state.input_map, true)) {
                state.input_map = !state.input_map;
            }

            if (igMenuItemBool("Output Map", null, state.output_map, true)) {
                state.output_map = !state.output_map;
            }
        }
    }

    // handle popups in the same scope
    if (showLoadTilesetPopup) {
        temp_state.reset();
        igOpenPopup("Load Tileset");
    }

    if (showResizePopup) {
        temp_state.map_width = state.map.w;
        temp_state.map_height = state.map.h;

        igOpenPopup("Resize Map");
    }

    loadTilesetPopup();
    resizeMapPopup();
}


fn loadTilesetPopup() void {
    if (igBeginPopupModal("Load Tileset", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        _ = igInputText("Tileset file", &buffer, 100, ImGuiInputTextFlags_None, null, null);
        _ = igDragInt("Tile Size", &temp_state.tile_size, 0.5, 0, 32, null);
        _ = igDragInt("Tile Spacing", &temp_state.tile_spacing, 0.5, 0, 8, null);
        igSeparator();

        var size: ImVec2 = undefined;
        igGetContentRegionAvail(&size);
        if (igButton("Cancel", ImVec2{ .x = (size.x - 4) / 2 })) {
            igCloseCurrentPopup();
        }
        igSameLine(0, 4);
        if (igButton("Load", ImVec2{ .x = -1, .y = 0 })) {
            igCloseCurrentPopup();
        }
    }
}

fn resizeMapPopup() void {
    if (igBeginPopupModal("Resize Map", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        _ = igDragInt("Width", &temp_state.map_width, 0.5, 0, 256, null);
        _ = igDragInt("Height", &temp_state.map_height, 0.5, 0, 256, null);
        igSeparator();

        var size: ImVec2 = undefined;
        igGetContentRegionAvail(&size);
        if (igButton("Cancel", ImVec2{ .x = (size.x - 4) / 2 })) {
            igCloseCurrentPopup();
        }
        igSameLine(0, 4);
        if (igButton("Apply", ImVec2{ .x = -1, .y = 0 })) {
            igCloseCurrentPopup();
        }
    }
}
