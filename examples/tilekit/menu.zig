const std = @import("std");
const tk = @import("tilekit.zig");
usingnamespace @import("imgui");

const aya = @import("aya");
var buffer: [100]u8 = undefined;

var temp_state = struct {
    tile_size: usize = 16,
    tile_spacing: usize = 0,
    map_width: usize = 64,
    map_height: usize = 64,

    pub fn reset(self: *@This()) void {
        self.tile_size = 16;
        self.tile_spacing = 0;
        self.map_width = 64;
        self.map_height = 64;
    }
}{};

fn checkKeyboardShortcuts(state: *tk.AppState) void {
    // shortcuts for pressing 1-9 to set the brush
    var key: c_int = 30;
    while (key < 39) : (key += 1) {
        if (aya.input.keyPressed(@intToEnum(aya.sdl.SDL_Scancode, key))) state.selected_brush_index = @intCast(usize, key - 30);
    }

    if (aya.input.keyPressed(.SDL_SCANCODE_B)) {
        if (igIsPopupOpenID(igGetIDStr("brushes"))) {
            igClosePopupToLevel(0, true);
        } else {
            igOpenPopup("brushes");
        }
    }
}

pub fn draw(state: *tk.AppState) void {
    checkKeyboardShortcuts(state);

    var showLoadTilesetPopup = false;
    var showResizePopup = false;

    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("TileKit", true)) {
            defer igEndMenu();

            if (igMenuItemBool("New", null, false, true)) {
                state.map = tk.Map.init();
            }

            if (igMenuItemBool("Save", null, false, true)) {
                state.saveMap("tilekit.bin") catch unreachable;
            }

            if (igMenuItemBool("Save As...", null, false, true)) {
                state.saveMap("tilekit.bin") catch unreachable;
            }

            if (igMenuItemBool("Load", null, false, true)) {
                state.loadMap("tilekit.bin") catch unreachable;
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

            if (igMenuItemBool("Post Processed Map", null, state.post_processed_map, true)) {
                state.post_processed_map = !state.post_processed_map;
            }

            if (igMenuItemBool("Output Map", null, state.output_map, true)) {
                state.output_map = !state.output_map;
            }

            igSeparator();

            if (igBeginMenu("Map Display", true)) {
                defer igEndMenu();

                if (igMenuItemBool("8px", null, state.map_rect_size == 8, true)) {
                    state.map_rect_size = 8;
                }
                if (igMenuItemBool("16px", null, state.map_rect_size == 16, true)) {
                    state.map_rect_size = 16;
                }
                if (igMenuItemBool("32px", null, state.map_rect_size == 32, true)) {
                    state.map_rect_size = 32;
                }
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
        _ = ogDragUsize("Tile Size", &temp_state.tile_size, 0.5, 32);
        _ = ogDragUsize("Tile Spacing", &temp_state.tile_spacing, 0.5, 8);
        igSeparator();

        var size = ogGetContentRegionAvail();
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

        _ = ogDragUsize("Width", &temp_state.map_width, 0.5, 256);
        _ = ogDragUsize("Height", &temp_state.map_height, 0.5, 256);
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
