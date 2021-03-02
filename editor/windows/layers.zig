const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
usingnamespace @import("imgui");

const Layer = root.layers.Layer;

var name_buf: [25:0]u8 = undefined;
var new_layer_type: root.layers.LayerType = .tilemap;
var new_layer_tileset_index: usize = 0;
var dnd_swap: ?struct { remove_from: usize, insert_into: usize } = null;

/// draws the Layers window
pub fn draw(state: *root.AppState) void {
    if (igBegin("Layers", null, ImGuiWindowFlags_None)) {
        var delete_index: usize = std.math.maxInt(usize);

        for (state.level.layers.items) |*layer, i| {
            var rename_index: ?usize = null;
            ogPushIDUsize(i);
            defer igPopID();

            // make a drop zone above each layer
            const cursor = ogGetCursorPos();
            ogSetCursorPos(cursor.subtract(.{ .y = 6 }));
            _ = ogInvisibleButton("", .{ .x = -1, .y = 8 }, ImGuiButtonFlags_None);

            if (igBeginDragDropTarget()) {
                defer igEndDragDropTarget();

                if (igAcceptDragDropPayload("LAYER_DRAG", ImGuiDragDropFlags_None)) |payload| {
                    std.debug.assert(payload.DataSize == @sizeOf(usize));
                    const data = @ptrCast(*usize, @alignCast(@alignOf(usize), payload.Data.?));
                    if (i > data.* and i - data.* > 1) {
                        dnd_swap = .{ .remove_from = data.*, .insert_into = i - 1 };
                    } else if (i < data.*) {
                        dnd_swap = .{ .remove_from = data.*, .insert_into = i };
                    }
                }
            }
            ogSetCursorPos(cursor);

            _ = ogButton(icons.grip_horizontal);
            if (igBeginDragDropSource(ImGuiDragDropFlags_None)) {
                defer igEndDragDropSource();

                _ = igSetDragDropPayload("LAYER_DRAG", &i, @sizeOf(usize), ImGuiCond_Once);
                igText(std.mem.spanZ(&layer.name()));
            }

            const drag_grip_w = ogGetItemRectSize().x + 5; // 5 is for the SameLine pad
            ogUnformattedTooltip(-1, "Click and drag to reorder");
            igSameLine(0, 10);

            if (ogSelectableBool(std.mem.spanZ(&layer.name()), state.selected_layer_index == i, ImGuiSelectableFlags_None, .{ .x = igGetWindowContentRegionWidth() - drag_grip_w - 55 })) {
                state.selected_layer_index = i;
            }

            if (igBeginPopupContextItem("##layer-context-menu", ImGuiMouseButton_Right)) {
                if (igMenuItemBool("Rename", null, false, true)) rename_index = i;
                igEndPopup();
            }

            // line up our buttons on the right of the selectable
            igSameLine(igGetWindowContentRegionWidth() - 35, 0);
            if (ogButtonEx(if (layer.visible()) icons.eye else icons.eye_slash, .{ .x = 23 }))
                layer.setVisible(!layer.visible());

            igSameLine(igGetWindowContentRegionWidth() - 8, 0);
            if (ogButton(icons.trash))
                delete_index = i;

            // make a drop zone below only the last layer
            if (state.level.layers.items.len - 1 == i) {
                const cursor2 = ogGetCursorPos();
                ogSetCursorPos(cursor.add(.{ .y = igGetFrameHeight() - 6 }));
                _ = ogInvisibleButton("", .{ .x = -1, .y = 8 }, ImGuiButtonFlags_None);

                if (igBeginDragDropTarget()) {
                    defer igEndDragDropTarget();

                    if (igAcceptDragDropPayload("LAYER_DRAG", ImGuiDragDropFlags_None)) |payload| {
                        std.debug.assert(payload.DataSize == @sizeOf(usize));
                        const data = @ptrCast(*usize, @alignCast(@alignOf(usize), payload.Data.?));
                        if (data.* != i)
                            dnd_swap = .{ .remove_from = data.*, .insert_into = i };
                    }
                }
                ogSetCursorPos(cursor2);
            }

            if (rename_index != null) {
                aya.mem.copyZ(u8, &name_buf, std.mem.spanZ(&layer.name()));
                ogOpenPopup("##rename-layer");
            }

            renameLayerPopup(layer);
        }

        if (dnd_swap) |swapper| {
            const removed = state.level.layers.orderedRemove(swapper.remove_from);
            state.level.layers.insert(swapper.insert_into, removed) catch unreachable;

            // handle updating the selected index
            if (swapper.remove_from == state.selected_layer_index) {
                state.selected_layer_index = swapper.insert_into;
            } else if (swapper.remove_from < state.selected_layer_index and swapper.insert_into >= state.selected_layer_index) {
                state.selected_layer_index -= 1;
            } else if (swapper.remove_from > state.selected_layer_index and swapper.insert_into <= state.selected_layer_index) {
                state.selected_layer_index += 1;
            }
            dnd_swap = null;
        }

        if (delete_index < std.math.maxInt(usize)) {
            if (state.level.layers.items.len == 1 or delete_index == state.selected_layer_index) {
                state.selected_layer_index = 0;
            } else if (delete_index < state.selected_layer_index) {
                state.selected_layer_index -= 1;
            }
            var layer = state.level.layers.orderedRemove(delete_index);
            layer.deinit();
        }

        if (state.level.layers.items.len > 0) ogDummy(.{ .y = 5 });

        // right-align the button
        igSetCursorPosX(igGetCursorPosX() + igGetWindowContentRegionWidth() - 75);
        if (ogButtonEx("Add Layer", .{ .x = 75 })) {
            std.mem.set(u8, &name_buf, 0);
            new_layer_type = .tilemap;
            new_layer_tileset_index = 0;
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

        if (new_layer_type != .entity) {
            if (state.asset_man.tilesets.len == 0) {
                igText("No tilesets available in your project");
            } else {
                if (igBeginCombo("Tileset", state.asset_man.tilesets[new_layer_tileset_index], ImGuiComboFlags_None)) {
                    defer igEndCombo();

                    for (state.asset_man.tilesets) |tileset, i| {
                        if (ogSelectableBool(tileset, new_layer_tileset_index == i, ImGuiSelectableFlags_None, .{})) new_layer_tileset_index = i;
                    }
                }
            }
            ogDummy(.{ .y = 5 });
        }

        const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
        const disabled = label_sentinel_index == 0;
        ogPushDisabled(disabled);

        if (ogColoredButtonEx(root.colors.rgbToU32(25, 180, 45), "Add Layer", .{ .x = -1, .y = 0 })) {
            igCloseCurrentPopup();
            state.level.layers.append(root.layers.Layer.init(new_layer_type, name_buf[0..label_sentinel_index], state.level.map_size, state.tile_size)) catch unreachable;
            state.selected_layer_index = state.level.layers.items.len - 1;
        }

        ogPopDisabled(disabled);

        igEndPopup();
    }
}
