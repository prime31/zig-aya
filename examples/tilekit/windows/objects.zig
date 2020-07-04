const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
usingnamespace @import("imgui");

const object_editor = @import("object_editor.zig");

var buffer: [25]u8 = undefined;
var selected_index: usize = std.math.maxInt(usize);

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 100 });
    defer igPopStyleVar(1);

    if (state.windows.tag_editor and igBegin("Objects", &state.windows.tag_editor, ImGuiWindowFlags_None)) {
        defer igEnd();

        if (igBeginChildEx("##obj-child", igGetItemID(), ImVec2{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            igPushItemWidth(igGetWindowContentRegionWidth());
            _ = ogInputText("##obj-filter", &buffer, buffer.len);
            igPopItemWidth();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.objects.items) |*obj, i| {
                igPushIDInt(@intCast(c_int, i));

                if (igSelectableBool(&obj.name, selected_index == i, ImGuiSelectableFlags_None, ImVec2{.x = igGetWindowContentRegionWidth() - 24})) {
                    selected_index = i;
                    object_editor.setSelectedObject(selected_index);
                }

                igSameLine(igGetWindowContentRegionWidth() - 20, 0);
                if (ogButton(icons.trash)) {
                    delete_index = i;
                }

                igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                if (delete_index == selected_index) {
                    selected_index = std.math.maxInt(usize);
                    object_editor.setSelectedObject(null);
                } else if (delete_index < selected_index and selected_index != std.math.maxInt(usize)) {
                    selected_index -= 1;
                    object_editor.setSelectedObject(selected_index);
                }

                _ = state.map.objects.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Object", ImVec2{})) {
            state.map.addObject();
            selected_index = state.map.objects.items.len - 1;
            var obj = &state.map.objects.items[selected_index];
            _ = std.fmt.bufPrint(&obj.name, "Object ${}", .{selected_index}) catch unreachable;
            object_editor.setSelectedObject(selected_index);
        }
    }
}
