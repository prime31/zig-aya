const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
usingnamespace @import("imgui");

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

                if (igSelectableBool(&obj.name, selected_index == i, ImGuiSelectableFlags_None, ImVec2{.x = igGetWindowContentRegionWidth() - 20})) {
                    selected_index = i;
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
                } else if (delete_index < selected_index) {
                    selected_index -= 1;
                }

                _ = state.map.objects.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Object", ImVec2{})) {
            state.map.addObject();
            var obj = &state.map.objects.items[state.map.objects.items.len - 1];
            std.mem.copy(u8, &obj.name, "whatever man");
        }
    }
}
