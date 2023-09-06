const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
const imgui = @import("imgui");
const icons = imgui.icons;

const Component = root.data.Component;
const Property = root.data.Property;

var name_buf: [25]u8 = undefined;
var selected_comp: usize = 0;
var enum_editor_index: ?usize = null;

pub fn draw(state: *root.AppState) void {
    imgui.igPushStyleColorU32(imgui.ImGuiCol_ModalWindowDimBg, root.colors.rgbaToU32(20, 20, 20, 200));
    defer imgui.igPopStyleColor(1);

    imgui.ogSetNextWindowSize(.{ .x = 500, .y = -1 }, imgui.ImGuiCond_Always);
    var open: bool = true;
    if (imgui.igBeginPopupModal("Component Editor", &open, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
        defer imgui.igEndPopup();

        imgui.igColumns(2, "id", true);
        imgui.igSetColumnWidth(0, 150);

        imgui.igPushItemWidth(-1);
        if (imgui.ogListBoxHeaderVec2("", .{})) {
            defer imgui.igListBoxFooter();

            for (state.components.items, 0..) |*comp, i| {
                if (imgui.ogSelectableBool(&comp.name, selected_comp == i, imgui.ImGuiSelectableFlags_DontClosePopups, .{})) {
                    selected_comp = i;
                }
            }
        }
        imgui.igPopItemWidth();

        imgui.igNextColumn();

        if (state.components.items.len > 0)
            drawDetailsPane(state, &state.components.items[selected_comp]);

        imgui.igColumns(1, "id", false);
        if (imgui.ogButton("Add Component")) {
            imgui.ogOpenPopup("##new-component");
            @memset(&name_buf, 0);
        }

        imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
        if (imgui.igBeginPopup("##new-component", imgui.ImGuiWindowFlags_None)) {
            defer imgui.igEndPopup();

            _ = imgui.igInputText("", &name_buf, name_buf.len, imgui.ImGuiInputTextFlags_CharsNoBlank, null, null);

            const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
            imgui.ogPushDisabled(name.len == 0);
            defer imgui.ogPopDisabled(name.len == 0);

            if (imgui.ogColoredButtonEx(root.colors.rgbToU32(25, 180, 45), "Create Component", .{ .x = -1, .y = 0 })) {
                _ = state.createComponent(name);
                selected_comp = state.components.items.len - 1;
                imgui.igCloseCurrentPopup();
            }
        }
    }
}

fn drawDetailsPane(state: *root.AppState, component: *Component) void {
    imgui.igText("Name");
    imgui.igSameLine(0, 130);
    imgui.igText("Default Value");

    var delete_index: ?usize = null;
    for (component.props, 0..) |*prop, i| {
        imgui.igPushIDPtr(prop);
        defer imgui.igPopID();

        imgui.igPushItemWidth(imgui.igGetColumnWidth(1) / 2 - 20);
        _ = imgui.igInputText("##name", &prop.name, prop.name.len, imgui.ImGuiInputTextFlags_CharsNoBlank, null, null);
        imgui.igSameLine(0, 5);

        switch (prop.value) {
            .string => |*str| _ = imgui.ogInputText("##str", str, str.len),
            .float => |*flt| _ = imgui.ogDragSigned(f32, "##flt", flt, 1, std.math.minInt(i32), std.math.maxInt(i32)),
            .int => |*int| _ = imgui.ogDragSigned(i32, "##int", int, 1, std.math.minInt(i32), std.math.maxInt(i32)),
            .bool => |*b| _ = imgui.igCheckbox("##bool", b),
            .vec2 => |*v2| _ = imgui.igDragFloat2("##vec2", &v2.x, 1, -std.math.floatMax(f32), std.math.floatMax(f32), "%.2f", imgui.ImGuiSliderFlags_None),
            .enum_values => |*enums| {
                _ = enums;
                if (imgui.ogButton("Edit Enum Values")) enum_editor_index = i;
            },
            .entity_link => imgui.igText("No default value"),
        }
        imgui.igSameLine(0, 5);

        imgui.igPopItemWidth();
        if (imgui.ogButton(icons.trash)) delete_index = i;
    }

    if (enum_editor_index) |index| {
        imgui.ogOpenPopup("Enum Values##enum-values");

        var enum_delete_index: ?usize = null;
        var open = true;
        if (imgui.igBeginPopupModal("Enum Values##enum-values", &open, imgui.ImGuiWindowFlags_AlwaysAutoResize)) {
            defer imgui.igEndPopup();

            var prop_value = &component.props[index].value;
            for (prop_value.enum_values, 0..) |*val, i| {
                imgui.igPushIDPtr(val);
                defer imgui.igPopID();

                _ = imgui.igInputText("##enum_value", val, val.len, imgui.ImGuiInputTextFlags_CharsNoBlank, null, null);

                imgui.igSameLine(0, 5);
                if (imgui.ogButton(icons.trash)) enum_delete_index = i;
            }

            if (imgui.ogButton("Add Enum Value")) {
                // prop_value.enum_values = aya.mem.allocator.realloc(prop_value.enum_values, prop_value.enum_values.len + 1) catch unreachable;
                @memset(&prop_value.enum_values[prop_value.enum_values.len - 1], 0);
            }
        }

        if (enum_delete_index) |i| {
            var prop_value = &component.props[index].value;
            const newlen = prop_value.enum_values.len - 1;

            // if this isnt the last element, copy each element after the one we remove back one to fill the gap
            if (newlen != i)
                for (prop_value.enum_values[i..newlen], 0..) |*b, j| std.mem.copy(u8, b, &prop_value.enum_values[i + 1 + j]);

            prop_value.enum_values = aya.mem.allocator.realloc(prop_value.enum_values, prop_value.enum_values.len - 1) catch unreachable;
            ensureLiveEnumValueIsValid(state, component, prop_value.enum_values.len);
        }

        if (!open) enum_editor_index = null;
    }

    if (delete_index) |index| {
        var prop = aya.utils.array.orderedRemove(Property, &component.props, index); // component.props.orderedRemove(index);

        // remove the property from any Entities that have this component
        for (state.level.layers.items) |*layer| {
            if (layer.* == .entity) {
                for (layer.entity.entities.items) |*entity| {
                    for (entity.components.items) |*comp| {
                        if (comp.component_id == component.id) {
                            comp.removeProperty(prop.id);
                            break;
                        }
                    }
                }
            }
        }

        prop.deinit();
    }

    imgui.ogDummy(.{ .y = 5 });

    if (imgui.ogButton("Add Field"))
        imgui.ogOpenPopup("##add-field");

    addFieldPopup(state, component);
}

fn addFieldPopup(state: *root.AppState, component: *Component) void {
    imgui.ogSetNextWindowPos(imgui.igGetIO().MousePos, imgui.ImGuiCond_Appearing, .{ .x = 0.5 });
    if (imgui.igBeginPopup("##add-field", imgui.ImGuiWindowFlags_None)) {
        if (imgui.ogSelectableBool("bool", false, imgui.ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .bool = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (imgui.ogSelectableBool("string", false, imgui.ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .string = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (imgui.ogSelectableBool("float", false, imgui.ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .float = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (imgui.ogSelectableBool("int", false, imgui.ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .int = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (imgui.ogSelectableBool("Vec2", false, imgui.ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .vec2 = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (imgui.ogSelectableBool("enum", false, imgui.ImGuiSelectableFlags_None, .{})) {
            @panic("fix this once zig can allocate with sentinels again");
            // var enums = aya.mem.allocator.alloc([25:0]u8, 1) catch unreachable;
            // @memset(&enums[0], 0);
            // std.mem.copy(u8, &enums[0], "default_value");
            // component.addProperty(.{ .enum_values = enums });
            // addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (imgui.ogSelectableBool("Entity Link", false, imgui.ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .entity_link = 0 });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }

        imgui.igEndPopup();
    }
}

fn addLastPropertyToEntitiesContainingComponent(state: *root.AppState, component: *Component) void {
    // add the new property to any Entities that have this component
    for (state.level.layers.items) |*layer| {
        if (layer.* == .entity) {
            for (layer.entity.entities.items) |*entity| {
                for (entity.components.items) |*comp| {
                    if (comp.component_id == component.id) {
                        comp.addProperty(component.props[component.props.len - 1]);
                        break;
                    }
                }
            }
        }
    }
}

fn ensureLiveEnumValueIsValid(state: *root.AppState, component: *Component, enum_len: usize) void {
    // add the new property to any Entities that have this component
    for (state.level.layers.items) |*layer| {
        if (layer.* == .entity) {
            for (layer.entity.entities.items) |*entity| {
                for (entity.components.items) |*comp| {
                    if (comp.component_id == component.id) {
                        for (comp.props.items) |*prop| {
                            if (prop.value == .enum_value and prop.value.enum_value.index > 0 and prop.value.enum_value.index == enum_len)
                                prop.value.enum_value.index -= 1;
                        }
                        break;
                    }
                }
            }
        }
    }
}
