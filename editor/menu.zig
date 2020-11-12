const std = @import("std");
const aya = @import("aya");
const root = @import("root");
usingnamespace @import("imgui");


pub fn draw(state: *root.AppState) void {
    var show_component_editor_popup = false;

    if (igBeginMenuBar()) {
        defer igEndMenuBar();

        if (igBeginMenu("File", true)) {
            defer igEndMenu();

            if (igMenuItemBool("New", null, false, true)) {}
        }

        if (igBeginMenu("Tools", true)) {
            defer igEndMenu();

            if (igMenuItemBool("Component Editor...", null, false, true)) {
                show_component_editor_popup = true;
            }
        }
    }

    // handle popup toggles
    if (show_component_editor_popup) {
        ogOpenPopup("Component Editor");
    }

    // we always need to call our popup code
    root.windows.component_editor.draw(state);
}
