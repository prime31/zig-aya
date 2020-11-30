const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
usingnamespace @import("imgui");

const Layer = root.layers.Layer;

var name_buf: [25:0]u8 = undefined;
var new_layer_type: root.layers.LayerType = .tilemap;

pub fn draw(state: *root.AppState) void {
    if (igBegin("Layers", null, ImGuiWindowFlags_None)) {
        var delete_index: usize = std.math.maxInt(usize);

        for (state.layers.items) |*layer, i| {
            var rename_index: ?usize = null;
            ogPushIDUsize(i);
            defer igPopID();

            _ = ogButton(icons.grip_horizontal);
            const drag_grip_w = ogGetItemRectSize().x + 5; // 5 is for the SameLine pad
            ogUnformattedTooltip(-1, "Click and drag to reorder");
            igSameLine(0, 10);

            if (ogSelectableBool(std.mem.spanZ(&layer.name()), state.selected_layer_index == i, ImGuiSelectableFlags_None, .{ .x = igGetWindowContentRegionWidth() - drag_grip_w - 30 })) {
                state.selected_layer_index = i;
            }

            if (igBeginPopupContextItem("##layer-context-menu", ImGuiMouseButton_Right)) {
                if (igMenuItemBool("Rename", null, false, true)) rename_index = i;
                igEndPopup();
            }

            // make some room for the delete button
            igSameLine(igGetWindowContentRegionWidth() - 8, 0);
            if (ogButton(icons.trash)) {
                delete_index = i;
            }

            if (rename_index != null) {
                aya.mem.copyZ(u8, &name_buf, std.mem.spanZ(&layer.name()));
                ogOpenPopup("##rename-layer");
            }

            renameLayerPopup(layer);
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

        if (state.layers.items.len > 0) ogDummy(.{ .y = 5 });

        // right-align the button
        igSetCursorPosX(igGetCursorPosX() + igGetWindowContentRegionWidth() - 75);
        if (ogButtonEx("Add Layer", .{ .x = 75 })) {
            std.mem.set(u8, &name_buf, 0);
            new_layer_type = .tilemap;
            ogOpenPopup("##add-layer");
        }

        // we always need to call our popup code
        addLayerPopup(state);
    }
    igEnd();
}

fn renameLayerPopup(layer: *Layer) void {
    if (igBeginPopup("##rename-layer", ImGuiWindowFlags_None)) {
        _ = ogInputText("", &name_buf, name_buf.len);

        const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
        if (ogButtonEx("Rename Layer", .{ .x = -1, .y = 0 }) and name.len > 0) {
            layer.setName(name);
            igCloseCurrentPopup();
        }

        igEndPopup();
    }
}

fn addLayerPopup(state: *root.AppState) void {
    ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
    if (igBeginPopup("##add-layer", ImGuiWindowFlags_None)) {
        igText("Layer Name");
        _ = ogInputText("##layer-name", &name_buf, name_buf.len);
        igSpacing();

        igText("Layer Type");
        _ = ogBeginChildFrame(666, .{ .y = 55 }, ImGuiWindowFlags_None);
        inline for (@typeInfo(root.layers.LayerType).Enum.fields) |field| {
            var buf: [15]u8 = undefined;
            _ = std.mem.replace(u8, field.name, "_", " ", buf[0..]);
            if (ogSelectableBool(&buf[0], new_layer_type == @intToEnum(root.layers.LayerType, field.value), ImGuiSelectableFlags_DontClosePopups, .{})) {
                new_layer_type = @intToEnum(root.layers.LayerType, field.value);
            }
        }
        igEndChild();

        ogDummy(.{ .y = 5 });

        // igText("Type");
        // const tag_name = @tagName(new_layer_type);
        // const tag_name_c = std.cstr.addNullByte(aya.mem.tmp_allocator, tag_name) catch unreachable;
        // _ = std.mem.replace(u8, tag_name_c, "_", " ", tag_name_c);
        // if (igBeginCombo("##type", &tag_name_c[0], ImGuiComboFlags_None)) {
        //     inline for (std.meta.fields(root.LayerType)) |field| {
        //         var buf: [15]u8 = undefined;
        //         _ = std.mem.replace(u8, field.name, "_", " ", buf[0..]);
        //         if (ogSelectableBool(&buf[0], new_layer_type == @intToEnum(root.LayerType, field.value), ImGuiSelectableFlags_None, .{})) {
        //             new_layer_type = @intToEnum(root.LayerType, field.value);
        //         }
        //     }
        //     igEndCombo();
        // }

        const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
        const disabled = label_sentinel_index == 0;
        if (disabled) {
            igPushItemFlag(ImGuiItemFlags_Disabled, true);
            igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
        }

        if (ogColoredButtonEx(root.colors.rgbToU32(25, 180, 45), "Add Layer", .{ .x = -1, .y = 0 })) {
            igCloseCurrentPopup();
            state.layers.append(root.layers.Layer.init(new_layer_type, name_buf[0..label_sentinel_index], state.map_size, state.tile_size)) catch unreachable;
            state.selected_layer_index = state.layers.items.len - 1;
        }

        if (disabled) {
            igPopItemFlag();
            igPopStyleVar(1);
        }

        igEndPopup();
    }
}
