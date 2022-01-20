const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
const imgui = @import("imgui");
const icons = imgui.icons;

const Layer = root.layers.Layer;

var name_buf: [25:0]u8 = undefined;
var new_layer_type: root.layers.LayerType = .tilemap;
var new_layer_tileset_index: usize = 0;
var dnd_swap: ?struct { remove_from: usize, insert_into: usize } = null;

/// draws the Layers window
pub fn draw(state: *root.AppState) void {
    if (imgui.igBegin("Layers", null, imgui.ImGuiWindowFlags_None)) {
        var delete_index: usize = std.math.maxInt(usize);

        for (state.level.layers.items) |*layer, i| {
            var rename_index: ?usize = null;
            imgui.ogPushIDUsize(i);
            defer imgui.igPopID();

            // make a drop zone above each layer
            const cursor = imgui.ogGetCursorPos();
            imgui.ogSetCursorPos(cursor.subtract(.{ .y = 6 }));
            _ = imgui.ogInvisibleButton("", .{ .x = -1, .y = 8 }, imgui.ImGuiButtonFlags_None);

            if (imgui.igBeginDragDropTarget()) {
                defer imgui.igEndDragDropTarget();

                if (imgui.igAcceptDragDropPayload("LAYER_DRAG", imgui.ImGuiDragDropFlags_None)) |payload| {
                    std.debug.assert(payload[0].DataSize == @sizeOf(usize));
                    const data = @ptrCast(*usize, @alignCast(@alignOf(usize), payload[0].Data.?));
                    if (i > data.* and i - data.* > 1) {
                        dnd_swap = .{ .remove_from = data.*, .insert_into = i - 1 };
                    } else if (i < data.*) {
                        dnd_swap = .{ .remove_from = data.*, .insert_into = i };
                    }
                }
            }
            imgui.ogSetCursorPos(cursor);

            _ = imgui.ogButton(imgui.icons.grip_horizontal);
            if (imgui.igBeginDragDropSource(imgui.ImGuiDragDropFlags_None)) {
                defer imgui.igEndDragDropSource();

                _ = imgui.igSetDragDropPayload("LAYER_DRAG", &i, @sizeOf(usize), imgui.ImGuiCond_Once);
                imgui.igText(std.mem.span(&layer.name()));
            }

            const drag_grip_w = imgui.ogGetItemRectSize().x + 5; // 5 is for the SameLine pad
            imgui.ogUnformattedTooltip(-1, "Click and drag to reorder");
            imgui.igSameLine(0, 10);

            if (imgui.ogSelectableBool(std.mem.sliceTo(&layer.name(), 0), state.selected_layer_index == i, imgui.ImGuiSelectableFlags_None, .{ .x = imgui.igGetWindowContentRegionWidth() - drag_grip_w - 55 })) {
                state.selected_layer_index = i;
            }

            if (imgui.igBeginPopupContextItem("##layer-context-menu", imgui.ImGuiMouseButton_Right)) {
                if (imgui.igMenuItemBool("Rename", null, false, true)) rename_index = i;
                imgui.igEndPopup();
            }

            // line up our buttons on the right of the selectable
            imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 35, 0);
            if (imgui.ogButtonEx(if (layer.visible()) icons.eye else icons.eye_slash, .{ .x = 23 }))
                layer.setVisible(!layer.visible());

            imgui.igSameLine(imgui.igGetWindowContentRegionWidth() - 8, 0);
            if (imgui.ogButton(icons.trash))
                delete_index = i;

            // make a drop zone below only the last layer
            if (state.level.layers.items.len - 1 == i) {
                const cursor2 = imgui.ogGetCursorPos();
                imgui.ogSetCursorPos(cursor.add(.{ .y = imgui.igGetFrameHeight() - 6 }));
                _ = imgui.ogInvisibleButton("", .{ .x = -1, .y = 8 }, imgui.ImGuiButtonFlags_None);

                if (imgui.igBeginDragDropTarget()) {
                    defer imgui.igEndDragDropTarget();

                    if (imgui.igAcceptDragDropPayload("LAYER_DRAG", imgui.ImGuiDragDropFlags_None)) |payload| {
                        std.debug.assert(payload[0].DataSize == @sizeOf(usize));
                        const data = @ptrCast(*usize, @alignCast(@alignOf(usize), payload[0].Data.?));
                        if (data.* != i)
                            dnd_swap = .{ .remove_from = data.*, .insert_into = i };
                    }
                }
                imgui.ogSetCursorPos(cursor2);
            }

            if (rename_index != null) {
                aya.mem.copyZ(u8, &name_buf, std.mem.span(&layer.name()));
                imgui.ogOpenPopup("##rename-layer");
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

        if (state.level.layers.items.len > 0) imgui.ogDummy(.{ .y = 5 });

        // right-align the button
        imgui.igSetCursorPosX(imgui.igGetCursorPosX() + imgui.igGetWindowContentRegionWidth() - 75);
        if (imgui.ogButtonEx("Add Layer", .{ .x = 75 })) {
            std.mem.set(u8, &name_buf, 0);
            new_layer_type = .tilemap;
            new_layer_tileset_index = 0;
            imgui.ogOpenPopup("##add-layer");
        }

        // we always need to call our popup code
        addLayerPopup(state);
    }
    imgui.igEnd();
}

fn renameLayerPopup(layer: *Layer) void {
    if (imgui.igBeginPopup("##rename-layer", imgui.ImGuiWindowFlags_None)) {
        _ = imgui.ogInputText("", &name_buf, name_buf.len);

        const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
        if (imgui.ogButtonEx("Rename Layer", .{ .x = -1, .y = 0 }) and name.len > 0) {
            layer.setName(name);
            imgui.igCloseCurrentPopup();
        }

        imgui.igEndPopup();
    }
}

fn addLayerPopup(state: *root.AppState) void {
    imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("##add-layer", imgui.ImGuiWindowFlags_None)) {
        imgui.igText("Layer Name");
        _ = imgui.ogInputText("##layer-name", &name_buf, name_buf.len);
        imgui.igSpacing();

        imgui.igText("Layer Type");
        _ = imgui.ogBeginChildFrame(666, .{ .y = 55 }, imgui.ImGuiWindowFlags_None);
        inline for (@typeInfo(root.layers.LayerType).Enum.fields) |field| {
            var buf: [15]u8 = undefined;
            _ = std.mem.replace(u8, field.name, "_", " ", buf[0..]);
            if (imgui.ogSelectableBool(&buf[0], new_layer_type == @intToEnum(root.layers.LayerType, field.value), imgui.ImGuiSelectableFlags_DontClosePopups, .{})) {
                new_layer_type = @intToEnum(root.layers.LayerType, field.value);
            }
        }
        imgui.igEndChild();

        imgui.ogDummy(.{ .y = 5 });

        if (new_layer_type != .entity) {
            if (state.asset_man.tilesets.len == 0) {
                imgui.igText("No tilesets available in your project");
            } else {
                if (imgui.igBeginCombo("Tileset", state.asset_man.tilesets[new_layer_tileset_index], imgui.ImGuiComboFlags_None)) {
                    defer imgui.igEndCombo();

                    for (state.asset_man.tilesets) |tileset, i| {
                        if (imgui.ogSelectableBool(tileset, new_layer_tileset_index == i, imgui.ImGuiSelectableFlags_None, .{})) new_layer_tileset_index = i;
                    }
                }
            }
            imgui.ogDummy(.{ .y = 5 });
        }

        const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
        const disabled = label_sentinel_index == 0;
        imgui.ogPushDisabled(disabled);

        if (imgui.ogColoredButtonEx(root.colors.rgbToU32(25, 180, 45), "Add Layer", .{ .x = -1, .y = 0 })) {
            imgui.igCloseCurrentPopup();
            state.level.layers.append(root.layers.Layer.init(new_layer_type, name_buf[0..label_sentinel_index], state.level.map_size, state.tile_size)) catch unreachable;
            state.selected_layer_index = state.level.layers.items.len - 1;
        }

        imgui.ogPopDisabled(disabled);

        imgui.igEndPopup();
    }
}
