const std = @import("std");
usingnamespace @import("imgui");
const tk = @import("tilekit.zig");

const aya = @import("aya");
const files = @import("filebrowser");
const stb_image = @import("stb_image");

var buffer: [100]u8 = undefined;

// used to fill the ui while we are getting input for loading/resizing
var temp_state = struct {
    tile_size: usize = 16,
    tile_spacing: usize = 0,
    map_width: usize = 64,
    map_height: usize = 64,
    has_image: bool = false,
    invalid_image_selected: bool = false,
    error_loading_file: bool = false,
    image: [255:0]u8 = undefined,

    pub fn reset(self: *@This()) void {
        self.tile_size = 16;
        self.tile_spacing = 0;
        self.map_width = 64;
        self.map_height = 64;
        self.has_image = false;
        self.invalid_image_selected = false;
        self.error_loading_file = false;
        std.mem.set(u8, &self.image, 0);
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
                std.debug.print("doesnt work yet\n", .{});
                // state.saveMap("tilekit.tk") catch unreachable;
            }

            if (igMenuItemBool("Save As...", null, false, true)) {
                const path_or_null = @import("known-folders.zig").getPath(aya.mem.tmp_allocator, .desktop) catch unreachable;
                const tmp_path = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ path_or_null.?, std.fs.path.sep_str, "tilekit.tk" }) catch unreachable;
                const desktop = std.mem.dupeZ(aya.mem.tmp_allocator, u8, tmp_path) catch unreachable;

                const res = files.saveFileDialog("Save project", desktop, "*.tk");
                if (res != null) {
                    var out_file = res[0..std.mem.lenZ(res)];
                    if (!std.mem.endsWith(u8, out_file, ".tk")) {
                        out_file = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ out_file, ".tk" }) catch unreachable;
                    }
                    state.saveMap(out_file) catch unreachable;
                }
            }

            if (igMenuItemBool("Load...", null, false, true)) {
                const path_or_null = @import("known-folders.zig").getPath(aya.mem.tmp_allocator, .desktop) catch unreachable;
                const tmp_path = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ path_or_null.?, std.fs.path.sep_str }) catch unreachable;
                const desktop = std.mem.dupeZ(aya.mem.tmp_allocator, u8, tmp_path) catch unreachable;

                const res = files.openFileDialog("Open project", desktop, "*.tk");
                if (res != null) {
                    state.loadMap(std.mem.spanZ(res)) catch unreachable;
                }
            }
        }

        if (igBeginMenu("Map", true)) {
            defer igEndMenu();

            showLoadTilesetPopup = igMenuItemBool("Load Tileset", null, false, true);
            showResizePopup = igMenuItemBool("Resize Map", null, false, true);
        }

        if (igBeginMenu("View", true)) {
            defer igEndMenu();

            if (igMenuItemBool("Brushes", null, state.brushes_win, true)) {
                state.brushes_win = !state.brushes_win;
            }

            if (igMenuItemBool("Rules", null, state.rules_win, true)) {
                state.rules_win = !state.rules_win;
            }

            if (igMenuItemBool("Input Map", null, state.input_map_win, true)) {
                state.input_map_win = !state.input_map_win;
            }

            if (igMenuItemBool("Post Processed Map", null, state.post_processed_map_win, true)) {
                state.post_processed_map_win = !state.post_processed_map_win;
            }

            if (igMenuItemBool("Output Map", null, state.output_map_win, true)) {
                state.output_map_win = !state.output_map_win;
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

        igSetCursorPosX(igGetWindowWidth() - 120);
        if (igBeginMenu("Pre Processing", true)) {
            defer igEndMenu();

            if (igBeginMenu("Seed", true)) {
                defer igEndMenu();
                if (ogDrag(usize, "##seed", &state.seed, 1, 0, 1000)) {
                    state.map_data_dirty = true;
                }
            }

            if (igBeginMenu("Repeat", true)) {
                defer igEndMenu();
                if (ogDrag(u8, "##repeat", &state.repeat, 0.2, 0, 100)) {
                    state.map_data_dirty = true;
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

        if (temp_state.has_image) {
            // only display the filename here so there is room for the button
            const last_sep = std.mem.lastIndexOf(u8, &temp_state.image, std.fs.path.sep_str) orelse 0;
            const sentinel_index = std.mem.indexOfScalar(u8, &temp_state.image, 0) orelse temp_state.image.len;
            const c_file = std.cstr.addNullByte(aya.mem.tmp_allocator, temp_state.image[last_sep + 1..sentinel_index]) catch unreachable;
            igText(c_file);
        }
        igSameLine(0, 5);
        if (igButton("Choose", ImVec2{ .x = -1, .y = 0 })) {
            const path_or_null = @import("known-folders.zig").getPath(aya.mem.tmp_allocator, .desktop) catch unreachable;
            const tmp_path = std.mem.concat(aya.mem.tmp_allocator, u8, &[_][]const u8{ path_or_null.?, std.fs.path.sep_str }) catch unreachable;
            const desktop = std.mem.dupeZ(aya.mem.tmp_allocator, u8, tmp_path) catch unreachable;

            const res = files.openFileDialog("Import tileset image", desktop, "*.png");
            if (res != null) {
                std.mem.copy(u8, &temp_state.image, std.mem.spanZ(res));
                temp_state.has_image = true;
            } else {
                temp_state.has_image = false;
            }
        }

        _ = ogDrag(usize, "Tile Size", &temp_state.tile_size, 0.5, 8, 32);
        _ = ogDrag(usize, "Tile Spacing", &temp_state.tile_spacing, 0.5, 0, 8);

        // error messages
        // igPushTextWrapPos(ogGetContentRegionAvail().x);
        if (temp_state.invalid_image_selected) {
            igSpacing();
            igTextWrapped("Error: image width not compatible with tile size/spacing");
            igSpacing();
        }

        if (temp_state.error_loading_file) {
            igSpacing();
            igTextWrapped("Error: could not load file");
            igSpacing();
        }
        // igPopTextWrapPos();

        igSeparator();

        var size = ogGetContentRegionAvail();
        if (igButton("Cancel", ImVec2{ .x = (size.x - 4) / 2 })) {
            igCloseCurrentPopup();
        }
        igSameLine(0, 4);

        if (!temp_state.has_image) {
            igPushItemFlag(ImGuiItemFlags_Disabled, true);
            igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
        }

        if (igButton("Load", ImVec2{ .x = -1, .y = 0 })) {
            // load the image and validate that its width is divisible by the tile size (take spacing into account to)
            if (validateImage()) {
                std.debug.print("fuck yeah\n", .{});
                igCloseCurrentPopup();
            }
        }

        if (!temp_state.has_image) {
            igPopItemFlag();
            igPopStyleVar(1);
        }
    }
}

fn validateImage() bool {
    const image_contents = aya.fs.read(aya.mem.tmp_allocator, std.mem.spanZ(&temp_state.image)) catch unreachable;
    var w: c_int = 0;
    var h: c_int = 0;
    var comp: c_int = 0;
    if (stb_image.stbi_info_from_memory(image_contents.ptr, @intCast(c_int, image_contents.len), &w, &h, &comp) == 1) {
        temp_state.invalid_image_selected = true;
        return false;
    }

    temp_state.error_loading_file = true;
    return false;
}

fn resizeMapPopup() void {
    if (igBeginPopupModal("Resize Map", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        _ = ogDrag(usize, "Width", &temp_state.map_width, 0.5, 16, 512);
        _ = ogDrag(usize, "Height", &temp_state.map_height, 0.5, 16, 512);
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
