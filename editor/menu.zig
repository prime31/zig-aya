const std = @import("std");
const aya = @import("aya");
const root = @import("main.zig");
usingnamespace @import("imgui");

var buffer: [25:0]u8 = undefined;
var map_width: usize = 0;
var map_height: usize = 0;

pub fn draw(state: *root.AppState) void {
    var show_component_editor_popup = false;
    var show_new_project_popup = false;
    var show_new_level_popup = false;

    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();

            if (igMenuItemBool("New Project...", null, false, true)) show_new_project_popup = true;
            if (igMenuItemBool("New Level...", null, false, true)) show_new_level_popup = true;
        }

        if (igBeginMenu("Tools", true)) {
            defer igEndMenu();

            if (igMenuItemBool("Component Editor...", null, false, true)) {
                show_component_editor_popup = true;
            }
        }
    }

    // handle popup toggles
    if (show_component_editor_popup) ogOpenPopup("Component Editor");
    if (show_new_project_popup) {
        ogOpenPopup("New Project");
        root.utils.file_picker.setup("Create a folder to put your new Aya Editor project in", true, true);
    }
    if (show_new_level_popup) {
        ogOpenPopup("New Level");
        std.mem.set(u8, &buffer, 0);
        map_width = 32;
        map_height = 32;
    }

    // we always need to call our popup code
    root.windows.component_editor.draw(state);

    if (igBeginPopupModal("New Project", null, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();
        if (root.utils.file_picker.draw()) {
            std.debug.print("done with picker: {}, {}\n", .{ root.utils.file_picker.selected_dir, root.utils.file_picker.selected_file });
            root.utils.file_picker.cleanup();
            igCloseCurrentPopup();
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
            state.createLevel(buffer[0..label_sentinel_index]);
            igCloseCurrentPopup();
        }
        ogPopDisabled(disabled);
    }
}
