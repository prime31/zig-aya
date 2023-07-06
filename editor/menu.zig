const std = @import("std");
const aya = @import("aya");
const root = @import("main.zig");
const imgui = @import("imgui");

var buffer: [25:0]u8 = undefined;
var map_width: usize = 0;
var map_height: usize = 0;
var new_project_state: enum { tile, folder, non_empty_folder } = .tile;
var tile_size: usize = 16;

pub fn draw(state: *root.AppState) void {
    var show_component_editor_popup = false;
    var show_timeline_popup = false;
    var show_new_project_popup = false;
    var show_open_level_popup = false;
    var show_new_level_popup = false;
    var show_open_project_popup = false;

    if (imgui.igBeginMenuBar()) {
        defer imgui.igEndMenuBar();

        if (imgui.igBeginMenu("File", true)) {
            defer imgui.igEndMenu();

            if (imgui.igMenuItemBool("New Project...", null, false, true)) show_new_project_popup = true;
            if (imgui.igMenuItemBool("New Level...", null, false, true)) show_new_level_popup = true;
            imgui.igSeparator();
            if (imgui.igMenuItemBool("Open Project...", null, false, true)) show_open_project_popup = true;
            if (imgui.igMenuItemBool("Open Level...", null, false, state.asset_man.levels.len > 1)) show_open_level_popup = true;
            imgui.igSeparator();
            if (imgui.igMenuItemBool("Save Project...", null, false, true))
                root.persistence.saveProject(state) catch unreachable;
            if (imgui.igMenuItemBool("Save Level...", null, false, true)) {
                root.persistence.saveLevel(state.level) catch unreachable;
                state.asset_man.loadLevels();
            }
        }

        if (imgui.igBeginMenu("Tools", true)) {
            defer imgui.igEndMenu();

            if (imgui.igMenuItemBool("Component Editor...", null, false, true)) show_component_editor_popup = true;
            if (imgui.igMenuItemBool("Timeline Editor...", null, false, true)) show_timeline_popup = true;
        }
    }

    // handle popup toggles
    if (show_new_project_popup) {
        imgui.ogOpenPopup("New Project");
        new_project_state = .tile;
        root.utils.file_picker.setup("Create a folder to put your new Aya Edit project in", true, true);
    }

    if (show_new_level_popup) {
        imgui.ogOpenPopup("New Level");
        @memset(&buffer, 0);
        map_width = 32;
        map_height = 32;
    }

    if (show_open_project_popup) {
        root.persistence.saveProject(state) catch unreachable;
        imgui.ogOpenPopup("Open Project");
    }

    if (show_open_level_popup) {
        root.persistence.saveLevel(state.level) catch unreachable;
        imgui.ogOpenPopup("Open Level");
    }

    if (show_component_editor_popup) imgui.ogOpenPopup("Component Editor");
    if (show_timeline_popup) imgui.ogOpenPopup("Timeline Editor");

    // we always need to call our popup code
    root.windows.component_editor.draw(state);
    root.windows.timeline.draw(state);

    if (imgui.igBeginPopupModal("New Project", null, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        defer imgui.igEndPopup();

        if (new_project_state == .tile) {
            _ = imgui.ogDrag(usize, "Tile Size", &tile_size, 0.5, 8, 128);
            imgui.igSeparator();
            if (imgui.ogButton("Cancel")) imgui.igCloseCurrentPopup();
            imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 35, 0);
            if (imgui.ogButton("Next"))
                new_project_state = .folder;
        } else if (new_project_state == .folder) {
            if (root.utils.file_picker.draw()) |res| {
                if (res) {
                    var dir = std.fs.cwd().openIterableDir(root.utils.file_picker.selected_dir.?, .{ .access_sub_paths = true }) catch unreachable;
                    var iterator = dir.iterate();
                    const is_empty = iterator.next() catch unreachable == null;
                    dir.close();

                    if (!is_empty) {
                        new_project_state = .non_empty_folder;
                    } else {
                        state.startNewProjectInFolder(root.utils.file_picker.selected_dir.?);
                        root.utils.file_picker.cleanup();
                        imgui.igCloseCurrentPopup();
                    }
                } else {
                    root.utils.file_picker.cleanup();
                    imgui.igCloseCurrentPopup();
                }
            }
        } else if (new_project_state == .non_empty_folder) {
            imgui.igText("The project folder must be empty");
            imgui.igSeparator();
            if (imgui.igButton("Go back and try again", .{ .x = -1 })) new_project_state = .folder;
        }
    }

    if (imgui.igBeginPopupModal("New Level", null, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        defer imgui.igEndPopup();
        _ = imgui.igInputText("Name", &buffer, buffer.len, imgui.ImGuiInputTextFlags_CharsNoBlank, null, null);

        _ = imgui.ogDrag(usize, "Width", &map_width, 0.5, 16, 512);
        _ = imgui.ogDrag(usize, "Height", &map_height, 0.5, 16, 512);
        imgui.igSeparator();

        const label_sentinel_index = std.mem.indexOfScalar(u8, &buffer, 0).?;
        const disabled = label_sentinel_index == 0;

        if (imgui.ogButton("Cancel")) imgui.igCloseCurrentPopup();
        imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 45, 0);

        imgui.ogPushDisabled(disabled);
        if (imgui.ogButton("Create")) {
            state.createLevel(buffer[0..label_sentinel_index], map_width, map_height);
            imgui.igCloseCurrentPopup();
        }
        imgui.ogPopDisabled(disabled);
    }

    imgui.ogSetNextWindowSize(.{ .x = 200 }, imgui.ImGuiCond_Once);
    if (imgui.igBeginPopupModal("Open Level", null, imgui.ImGuiWindowFlags_None)) {
        defer imgui.igEndPopup();

        for (state.asset_man.levels) |level| {
            const base_name = level[0..std.mem.indexOfScalar(u8, level, '.').?];
            var name_buf: [25:0]u8 = undefined;
            @memset(&name_buf, 0);
            std.mem.copy(u8, &name_buf, base_name);

            if (imgui.ogButtonEx(&name_buf, .{ .x = -1 })) {
                const new_level = root.persistence.loadLevel(level) catch unreachable;
                state.level.deinit();
                state.level = new_level;
                state.selected_layer_index = 0;
                imgui.igCloseCurrentPopup();
            }
        }

        imgui.igSeparator();
        if (imgui.ogButtonEx("Cancel", .{ .x = -1 })) imgui.igCloseCurrentPopup();
    }

    if (imgui.igBeginPopupModal("Open Project", null, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        defer imgui.igEndPopup();
        imgui.igText("some ui to select a project file or folder");

        if (imgui.ogButton("Cancel")) imgui.igCloseCurrentPopup();
        imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 45, 0);

        if (imgui.ogButton("Caxpoo"))
            imgui.igCloseCurrentPopup();
    }
}
