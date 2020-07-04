const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
usingnamespace @import("imgui");

var buffer: [25]u8 = undefined;

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 100 });
    defer igPopStyleVar(1);

    if (state.windows.tag_editor and igBegin("Tags", &state.windows.tag_editor, ImGuiWindowFlags_None)) {
        defer igEnd();

        if (igBeginChildEx("##tag-child", igGetItemID(), ImVec2{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.tags.items) |*tag, i| {
                igPushIDInt(@intCast(c_int, i));
                igPushItemWidth(igGetWindowContentRegionWidth() / 2 - 15);

                if (ogInputText("##key", &tag.key, tag.key.len)) {}
                igSameLine(0, 5);
                if (ogInputText("##value", &tag.val, tag.val.len)) {}
                igSameLine(0, 5);

                igPopItemWidth();

                if (ogButton(icons.trash)) {
                    delete_index = i;
                }

                igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                _ = state.map.tags.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Tag", ImVec2{})) {
            state.map.addTag();
        }
    }
}
