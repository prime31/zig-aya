const std = @import("std");
const aya = @import("aya");
const tk = @import("../tilekit.zig");
usingnamespace @import("imgui");

var buffer: [25]u8 = undefined;

pub fn draw(state: *tk.AppState) void {
    igPushStyleVarVec2(ImGuiStyleVar_WindowMinSize, ImVec2{ .x = 200, .y = 100 });
    defer igPopStyleVar(1);

    if (state.windows.tag_editor and igBegin("Object Editor", &state.windows.tag_editor, ImGuiWindowFlags_None)) {
        defer igEnd();

        if (igBeginChildEx("##obj-editor-child", igGetItemID(), ImVec2{ .y = -igGetFrameHeightWithSpacing() }, false, ImGuiWindowFlags_None)) {
            defer igEndChild();

            var delete_index: usize = std.math.maxInt(usize);
            for (state.map.objects.items) |*obj, i| {
                igPushIDInt(@intCast(c_int, i));

                igPushItemWidth(igGetWindowContentRegionWidth());
                if (ogInputText("##name", &obj.name, obj.name.len)) {}
                igPopItemWidth();

                _ = ogDrag(usize, "Tile X", &obj.x, 0.5, 0, state.map.w);
                _ = ogDrag(usize, "Tile Y", &obj.y, 0.5, 0, state.map.h);

                igSeparator();

                // custom properties
                {
                    var props: usize = 0;
                    while (props < 5) : (props += 1) {
                        igPushIDInt(@intCast(c_int, props));

                        igPushItemWidth(igGetWindowContentRegionWidth() / 2 - 15);
                        if (ogInputText("##key", &buffer, buffer.len)) {}
                        igSameLine(0, 5);
                        if (ogInputText("##value", &buffer, buffer.len)) {}
                        igSameLine(0, 5);
                        igPopItemWidth();

                        if (ogButton(icons.trash)) {}

                        igPopID();
                    }
                }

                igPopID();
            }

            if (delete_index < std.math.maxInt(usize)) {
                _ = state.map.objects.orderedRemove(delete_index);
            }
        }

        if (igButton("Add Property", ImVec2{})) {
            // state.map.addTag();
        }
    }
}
