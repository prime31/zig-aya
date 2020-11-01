const std = @import("std");
const upaya = @import("upaya");
const root = @import("../main.zig");
usingnamespace @import("imgui");

const Component = root.data.Component;

var name_buf: [25]u8 = undefined;
var selected_comp: usize = 0;

pub fn draw(state: *root.AppState) void {
    igSetNextWindowSize(.{ .x = 500, .y = -1 }, ImGuiCond_Always);
    var open: bool = true;
    if (igBeginPopupModal("Component Editor", &open, ImGuiWindowFlags_AlwaysAutoResize)) {
        defer igEndPopup();

        igColumns(2, "id", true);
        igSetColumnWidth(0, 150);

        igPushItemWidth(-1);
        if (igListBoxHeaderVec2("", .{})) {
            defer igListBoxFooter();

            for (state.components.items) |*comp, i| {
                if (igSelectableBool(&comp.name, selected_comp == i, ImGuiSelectableFlags_DontClosePopups, .{})) {
                    selected_comp = i;
                }
            }
        }
        igPopItemWidth();

        igNextColumn();

        if (state.components.items.len > 0) {
            drawDetailsPane(&state.components.items[selected_comp]);
        }

        igColumns(1, "id", false);
        if (ogButton("Add Component")) {
            igOpenPopup("##new-component");
            std.mem.set(u8, &name_buf, 0);
        }

        igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
        if (igBeginPopup("##new-component", ImGuiWindowFlags_None)) {
            _ = ogInputText("##new-component-name", &name_buf, name_buf.len);

            const name = name_buf[0..std.mem.indexOfScalar(u8, &name_buf, 0).?];
            const disabled = name.len == 0;
            if (disabled) {
                igPushItemFlag(ImGuiItemFlags_Disabled, true);
                igPushStyleVarFloat(ImGuiStyleVar_Alpha, 0.5);
            }

            if (ogColoredButtonEx(root.colors.rgbToU32(25, 180, 45), "Create Component", .{ .x = -1, .y = 0 }) and name.len > 0) {
                _ = state.createComponent(name);
                selected_comp = state.components.items.len - 1;
                igCloseCurrentPopup();
            }

            if (disabled) {
                igPopItemFlag();
                igPopStyleVar(1);
            }

            igEndPopup();
        }
    }
}

fn drawDetailsPane(component: *Component) void {
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
        prop.deinit();
    }

    igDummy(.{.y = 5});

    if (igButton("Add Field", .{})) {
        igOpenPopup("##add-field");
    }

    addFieldPopup(component);
}

fn addFieldPopup(component: *Component) void {
    igSetNextWindowPos(igGetIO().MousePos, ImGuiCond_Appearing, .{ .x = 0.5 });
    if (igBeginPopup("##add-field", ImGuiWindowFlags_None)) {
        igText("Field Type");
        igSeparator();

        if (igSelectableBool("bool", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .bool = undefined });
        }
        if (igSelectableBool("string", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .string = undefined });
        }
        if (igSelectableBool("float", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .float = undefined });
        }
        if (igSelectableBool("int", false, ImGuiSelectableFlags_None, .{})) {
            component.addProperty(.{ .int = undefined });
        }

        igEndPopup();
    }
}
