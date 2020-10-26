const std = @import("std");
const aya = @import("aya");
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

var name_buf: [25:0]u8 = undefined;
var new_layer_type: editor.LayerType = .tilemap;

pub fn draw(state: *editor.AppState) void {
    if (igBegin("Layers", null, ImGuiWindowFlags_None)) {
        var delete_index: usize = std.math.maxInt(usize);
        for (state.layers.items) |layer, i| {
            ogPushIDUsize(i);
            defer igPopID();

            if (igSelectableBool(layer.name(), state.selected_layer_index == i, ImGuiSelectableFlags_None, .{ .x = igGetWindowContentRegionWidth() - 25 })) {
                state.selected_layer_index = i;
            }

            // make some room for the buttons
            igSameLine(igGetWindowContentRegionWidth() - 3, 0);
            igSetCursorPosY(igGetCursorPosY() - 3);
            if (ogButton("X")) {
                delete_index = i;
            }
        }

        if (delete_index < std.math.maxInt(usize)) {
            if (state.layers.items.len == 1 or delete_index == state.selected_layer_index) {
                state.selected_layer_index = 0;
            } else if (delete_index < state.selected_layer_index) {
                state.selected_layer_index -= 1;
            }
            var layer = state.layers.orderedRemove(delete_index);
            layer.deinit();
        }

        if (state.layers.items.len > 0) igDummy(.{ .y = 5 });

        // right-align the button
        igSetCursorPosX(igGetCursorPosX() + igGetWindowContentRegionWidth() - 75);
        if (igButton("Add Layer", .{.x = 75})) {
            std.mem.set(u8, &name_buf, 0);
            new_layer_type = .tilemap;
            igOpenPopup("##add-layer");
        }

        // we always need to call our popup code
        addLayerPopup(state);
    }
    igEnd();
}

fn addLayerPopup(state: *editor.AppState) void {
    if (igBeginPopup("##add-layer", ImGuiWindowFlags_None)) {
        igText("Layer Name");
        _ = ogInputText("##name", &name_buf, name_buf.len);
        igSpacing();

        // inline for (@typeInfo(LayerType).Enum.fields) |field| {
        //     var buf: [15]u8 = undefined;
        //     _ = std.mem.replace(u8, field.name, "_", " ", buf[0..]);
        //     if (igSelectableBool(&buf[0], new_layer_type == @intToEnum(LayerType, field.value), ImGuiSelectableFlags_DontClosePopups, .{})) {
        //         new_layer_type = @intToEnum(LayerType, field.value);
        //     }
        // }

        igText("Type");
        const tag_name = @tagName(new_layer_type);
        const tag_name_c = std.cstr.addNullByte(aya.mem.tmp_allocator, tag_name) catch unreachable;
        _ = std.mem.replace(u8, tag_name_c, "_", " ", tag_name_c);
        if (igBeginCombo("##type", &tag_name_c[0], ImGuiComboFlags_None)) {
            inline for (std.meta.fields(editor.LayerType)) |field| {
                var buf: [15]u8 = undefined;
                _ = std.mem.replace(u8, field.name, "_", " ", buf[0..]);
                if (igSelectableBool(&buf[0], new_layer_type == @intToEnum(editor.LayerType, field.value), ImGuiSelectableFlags_None, .{})) {
                    new_layer_type = @intToEnum(editor.LayerType, field.value);
                }
            }
            igEndCombo();
        }

        const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
        if (igButton("Add Layer", .{ .x = -1, .y = 0 }) and name.len > 0) {
            igCloseCurrentPopup();
            state.layers.append(editor.Layer.init(new_layer_type, name, state.map_size, state.tile_size)) catch unreachable;
            state.selected_layer_index = state.layers.items.len - 1;
        }

        igEndPopup();
    }
}
