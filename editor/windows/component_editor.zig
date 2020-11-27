const std = @import("std");
const upaya = @import("upaya");
const root = @import("../main.zig");
usingnamespace @import("imgui");

const Component = root.data.Component;

var name_buf: [25]u8 = undefined;
var selected_comp: usize = 0;

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

        if (state.components.items.len > 0) {
            drawDetailsPane(state, &state.components.items[selected_comp]);
        }

        igColumns(1, "id", false);
        if (ogButton("Add Component")) {
            ogOpenPopup("##new-component");
            std.mem.set(u8, &name_buf, 0);
        }

        ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("##new-component", ImGuiWindowFlags_None)) {
            defer igEndPopup();

            _ = ogInputText("##new-component-name", &name_buf, name_buf.len);

            const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
            ogPushDisabled(name.len == 0);
            defer ogPopDisabled(name.len == 0);

            if (ogColoredButtonEx(root.colors.rgbToU32(25, 180, 45), "Create Component", .{ .x = -1, .y = 0 })) {
                _ = state.createComponent(name);
                std.debug.print("new comp: {}\n", .{name});
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
        _ = ogInputText("##name", &prop.name, prop.name.len);
        igSameLine(0, 5);

        switch (prop.value) {
            .string => |*str| {
                _ = ogInputText("##str", str, str.len);
            },
            .float => |*flt| {
                _ = ogDragSigned(f32, "##flt", flt, 1, std.math.minInt(i32), std.math.maxInt(i32));
            },
            .int => |*int| {
                _ = ogDragSigned(i32, "##int", int, 1, std.math.minInt(i32), std.math.maxInt(i32));
            },
            .bool => |*b| {
                _ = igCheckbox("##bool", b);
            },
        }
        igSameLine(0, 5);

        igPopItemWidth();
        if (ogButton(icons.trash)) delete_index = i;
    }

    if (delete_index) |index| {
        var prop = component.props.orderedRemove(index);

        // remove from any Entities that have this component
        for (state.layers.items) |*layer| {
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

    if (ogButton("Add Field")) {
        ogOpenPopup("##add-field");
    }

    addFieldPopup(state, component);
}

fn addFieldPopup(state: *root.AppState, component: *Component) void {
    ogSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
    if (igBeginPopup("##add-field", ImGuiWindowFlags_None)) {
        igText("Field Type");
        igSeparator();

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

        igEndPopup();
    }
}

fn addLastPropertyToEntitiesContainingComponent(state: *root.AppState, component: *Component) void {
    // remove from any Entities that have this component
    for (state.layers.items) |*layer| {
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
