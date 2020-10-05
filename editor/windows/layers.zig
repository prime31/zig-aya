const std = @import("std");
const aya = @import("aya");
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

var name_buf: [25]u8 = undefined;
var new_layer_type: LayerType = .tilemap;

pub const LayerType = enum {
    tilemap,
    auto_tilemap,
    entity,
};

pub fn draw(state: *editor.AppState) void {
    if (igBegin("Layers", null, ImGuiWindowFlags_None)) {
        if (ogButton("Add Layer")) {
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

        inline for (@typeInfo(LayerType).Enum.fields) |field| {
            var buf: [15]u8 = undefined;
            _ = std.mem.replace(u8, field.name, "_", " ", buf[0..]);
            if (igSelectableBool(&buf[0], new_layer_type == @intToEnum(LayerType, field.value), ImGuiSelectableFlags_DontClosePopups, .{})) {
                new_layer_type = @intToEnum(LayerType, field.value);
            }
        }
        igSpacing();

        const label_sentinel_index = std.mem.indexOfScalar(u8, &name_buf, 0).?;
        if (igButton("Add Layer", .{ .x = -1, .y = 0 }) and label_sentinel_index > 0) {
            igCloseCurrentPopup();
            std.debug.print("new layer name: {}\n", .{name_buf[0..label_sentinel_index]});
        }

        igEndPopup();
    }
}
