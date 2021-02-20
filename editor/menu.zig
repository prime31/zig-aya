const std = @import("std");
const aya = @import("aya");
const root = @import("main.zig");
usingnamespace @import("imgui");

var buffer: [25:0]u8 = undefined;
var map_width: usize = 0;
var map_height: usize = 0;
var new_project_state: enum { tile, folder, non_empty_folder } = .tile;
var tile_size: usize = 16;

pub fn draw(state: *root.AppState) void {
    var show_component_editor_popup = false;
    var show_new_project_popup = false;
    var show_open_level_popup = false;
    var show_new_level_popup = false;
    var show_open_project_popup = false;

    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();

            if (igMenuItemBool("New Project...", null, false, true)) show_new_project_popup = true;
            if (igMenuItemBool("New Level...", null, false, true)) show_new_level_popup = true;
            igSeparator();
            if (igMenuItemBool("Open Project...", null, false, true)) show_open_project_popup = true;
            if (igMenuItemBool("Open Level...", null, false, true)) show_open_level_popup = true;
            igSeparator();
            if (igMenuItemBool("Save Project...", null, false, true))
                root.persistence.saveProject(state) catch unreachable;
            if (igMenuItemBool("Save Level...", null, false, true)) {
                root.persistence.saveLevel(state.level) catch unreachable;
                state.asset_man.loadLevels();
            }
        }

        if (igBeginMenu("Tools", true)) {
            defer igEndMenu();

            if (igMenuItemBool("Component Editor...", null, false, true)) {
                show_component_editor_popup = true;
            }
        }
    }

    // handle popup toggles
    if (show_new_project_popup) {
        ogOpenPopup("New Project");
        new_project_state = .tile;
        root.utils.file_picker.setup("Create a folder to put your new Aya Edit project in", true, true);
    }

    if (show_new_level_popup) {
        ogOpenPopup("New Level");
        std.mem.set(u8, &buffer, 0);
        map_width = 32;
        map_height = 32;
    }

    if (show_open_project_popup) {
        // TODO: save the old project/level
        ogOpenPopup("Open Project");
    }

    if (show_open_level_popup) {
        // TODO: save the old level
        ogOpenPopup("Open Level");
    }

    if (show_component_editor_popup) ogOpenPopup("Component Editor");

    // we always need to call our popup code
    root.windows.component_editor.draw(state);

    if (igBeginPopupModal("New Project", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        if (new_project_state == .tile) {
            _ = ogDrag(usize, "Tile Size", &tile_size, 0.5, 8, 128);
            igSeparator();
            if (ogButton("Cancel")) igCloseCurrentPopup();
            igSameLine(igGetWindowContentRegionWidth() - 35, 0);
            if (ogButton("Next"))
                new_project_state = .folder;
        } else if (new_project_state == .folder) {
            if (root.utils.file_picker.draw()) |res| {
                if (res) {
                    var dir = std.fs.cwd().openDir(root.utils.file_picker.selected_dir.?, .{ .iterate = true }) catch unreachable;
                    const is_empty = dir.iterate().next() catch unreachable == null;
                    dir.close();

                    if (!is_empty) {
                        new_project_state = .non_empty_folder;
                    } else {
                        state.startNewProjectInFolder(root.utils.file_picker.selected_dir.?);
                        root.utils.file_picker.cleanup();
                        igCloseCurrentPopup();
                    }
                } else {
                    root.utils.file_picker.cleanup();
                    igCloseCurrentPopup();
                }
            }
        } else if (new_project_state == .non_empty_folder) {
            igText("The project folder must be empty");
            igSeparator();
            if (igButton("Go back and try again", .{ .x = -1 })) new_project_state = .folder;
        }
    }

    if (igBeginPopupModal("New Level", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();
        _ = igInputText("Name", &buffer, buffer.len, ImGuiInputTextFlags_CharsNoBlank, null, null);

        _ = ogDrag(usize, "Width", &map_width, 0.5, 16, 512);
        _ = ogDrag(usize, "Height", &map_height, 0.5, 16, 512);
        igSeparator();

        const label_sentinel_index = std.mem.indexOfScalar(u8, &buffer, 0).?;
        const disabled = label_sentinel_index == 0;

        if (ogButton("Cancel")) igCloseCurrentPopup();
        igSameLine(igGetWindowContentRegionWidth() - 45, 0);

        ogPushDisabled(disabled);
        if (ogButton("Create")) {
            state.createLevel(buffer[0..label_sentinel_index], map_width, map_height);
            igCloseCurrentPopup();
        }
        ogPopDisabled(disabled);
    }

    if (igBeginPopupModal("Open Level", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();
        igText("open level selector");

        if (ogButton("Cancel")) igCloseCurrentPopup();
        igSameLine(igGetWindowContentRegionWidth() - 30, 0);

        const disabled = true;

        ogPushDisabled(disabled);
        if (ogButton("Open"))
            igCloseCurrentPopup();
        ogPopDisabled(disabled);
    }

    if (igBeginPopupModal("Open Project", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();
        igText("some ui to select a project file or folder");

        if (ogButton("Cancel")) igCloseCurrentPopup();
        igSameLine(igGetWindowContentRegionWidth() - 45, 0);

        if (ogButton("Caxpoo"))
            igCloseCurrentPopup();
    }
}
