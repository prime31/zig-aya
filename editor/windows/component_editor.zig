const std = @import("std");
const aya = @import("aya");
const root = @import("../main.zig");
usingnamespace @import("imgui");

const Component = root.data.Component;

var name_buf: [25]u8 = undefined;
var selected_comp: usize = 0;
var enum_editor_index: ?usize = null;

pub fn draw(state: *root.AppState) void {
    igPushStyleColorU32(ImGuiCol_ModalWindowDimBg, root.colors.rgbaToU32(20, 20, 20, 200));
    defer igPopStyleColor(1);

    ogSetNextWindowSize(.{ .x = 500, .y = -1 }, ImGuiCond_Always);
    var open: bool = true;
    if (igBeginPopupModal("Component Editor", &open, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        igColumns(2, "id", true);
        igSetColumnWidth(0, 150);

        igPushItemWidth(-1);
        if (ogListBoxHeaderVec2("", .{})) {
            defer igListBoxFooter();

            for (state.components.items) |*comp, i| {
                if (ogSelectableBool(&comp.name, selected_comp == i, ImGuiSelectableFlags_DontClosePopups, .{})) {
                    selected_comp = i;
                }
            }
        }
        igPopItemWidth();

        igNextColumn();

        if (state.components.items.len > 0)
            drawDetailsPane(state, &state.components.items[selected_comp]);

        igColumns(1, "id", false);
        if (ogButton("Add Component")) {
            ogOpenPopup("##new-component");
            std.mem.set(u8, &name_buf, 0);
        }

        ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("##new-component", ImGuiWindowFlags_None)) {
            defer igEndPopup();

            _ = igInputText("", &name_buf, name_buf.len, ImGuiInputTextFlags_CharsNoBlank, null, null);

            const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
            ogPushDisabled(name.len == 0);
            defer ogPopDisabled(name.len == 0);

            if (ogColoredButtonEx(root.colors.rgbToU32(25, 180, 45), "Create Component", .{ .x = -1, .y = 0 })) {
                _ = state.createComponent(name);
                selected_comp = state.components.items.len - 1;
                igCloseCurrentPopup();
            }
        }
    }
}

fn drawDetailsPane(state: *root.AppState, component: *Component) void {
    igText("Name");
    igSameLine(0, 130);
    igText("Default Value");

    var delete_index: ?usize = null;
    for (component.props.items) |*prop, i| {
        igPushIDPtr(prop);
        defer igPopID();

        igPushItemWidth(igGetColumnWidth(1) / 2 - 20);
        _ = igInputText("##name", &prop.name, prop.name.len, ImGuiInputTextFlags_CharsNoBlank, null, null);
        igSameLine(0, 5);

        switch (prop.value) {
            .string => |*str| _ = ogInputText("##str", str, str.len),
            .float => |*flt| _ = ogDragSigned(f32, "##flt", flt, 1, std.math.minInt(i32), std.math.maxInt(i32)),
            .int => |*int| _ = ogDragSigned(i32, "##int", int, 1, std.math.minInt(i32), std.math.maxInt(i32)),
            .bool => |*b| _ = igCheckbox("##bool", b),
            .vec2 => |*v2| _ = igDragFloat2("##vec2", &v2.x, 1, -std.math.f32_max, std.math.f32_max, "%.2f", ImGuiSliderFlags_None),
            .enum_values => |*enums| {
                if (ogButton("Edit Enum Values")) enum_editor_index = i;
            },
            .entity_link => igText("No default value"),
        }
        igSameLine(0, 5);

        igPopItemWidth();
        if (ogButton(icons.trash)) delete_index = i;
    }

    if (enum_editor_index) |index| {
        ogOpenPopup("Enum Values##enum-values");

        var enum_delete_index: ?usize = null;
        var open = true;
        if (igBeginPopupModal("Enum Values##enum-values", &open, ImGuiWindowFlags_AlwaysAutoResize)) {
            defer igEndPopup();
           
            var prop_value = &component.props.items[index].value;
            for (prop_value.enum_values) |*val, i| {
                igPushIDPtr(val);
                defer igPopID();

                _ = igInputText("##enum_value", val, val.len, ImGuiInputTextFlags_CharsNoBlank, null, null);

                igSameLine(0, 5);
                if (ogButton(icons.trash)) enum_delete_index = i;
            }

            if (ogButton("Add Enum Value")) {
                prop_value.enum_values = aya.mem.allocator.realloc(prop_value.enum_values, prop_value.enum_values.len + 1) catch unreachable;
                std.mem.set(u8, &prop_value.enum_values[prop_value.enum_values.len - 1], 0);
            }
        }

        if (enum_delete_index) |i| {
            var prop_value = &component.props.items[index].value;
            const newlen = prop_value.enum_values.len - 1;

            // if this isnt the last element, copy each element after the one we remove back one to fill the gap
            if (newlen != i)
                for (prop_value.enum_values[i..newlen]) |*b, j| std.mem.copy(u8, b, &prop_value.enum_values[i + 1 + j]);

            prop_value.enum_values = aya.mem.allocator.realloc(prop_value.enum_values, prop_value.enum_values.len - 1) catch unreachable;
        }

        if (!open) enum_editor_index = null;
    }

    if (delete_index) |index| {
        var prop = component.props.orderedRemove(index);

        // remove the component from any Entities that have this component
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

    ogDummy(.{ .y = 5 });

    if (ogButton("Add Field"))
        ogOpenPopup("##add-field");

    addFieldPopup(state, component);
}

fn addFieldPopup(state: *root.AppState, component: *Component) void {
    ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
    if (igBeginPopup("##add-field", ImGuiWindowFlags_None)) {
        if (ogSelectableBool("bool", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .bool = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (ogSelectableBool("string", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .string = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (ogSelectableBool("float", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .float = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (ogSelectableBool("int", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .int = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (ogSelectableBool("Vec2", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .vec2 = undefined });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (ogSelectableBool("enum", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .enum_values = &[_][25:0]u8{} });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }
        if (ogSelectableBool("Entity Link", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .entity_link = 0 });
            addLastPropertyToEntitiesContainingComponent(state, component);
        }

        igEndPopup();
    }
}

fn addLastPropertyToEntitiesContainingComponent(state: *root.AppState, component: *Component) void {
    // remove from any Entities that have this component
    for (state.level.layers.items) |*layer| {
        if (layer.* == .entity) {
            for (layer.entity.entities.items) |*entity| {
                for (entity.components.items) |*comp| {
                    if (comp.component_id == component.id) {
                        comp.addProperty(component.props.items[component.props.items.len - 1]);
                        break;
                    }
                }
            }
        }
    }
}
