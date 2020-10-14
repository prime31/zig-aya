const std = @import("std");
const aya = @import("aya");
const editor = @import("../editor.zig");
usingnamespace @import("imgui");

var name_buf: [25:0]u8 = undefined;
var new_layer_type: LayerType = .tilemap;

pub const LayerType = enum(u8) {
    tilemap,
    auto_tilemap,
    entity,
};

pub const TilemapLayer = struct {
    name: []const u8,
};

pub const AutoTilemapLayer = struct {
    name: []const u8,
};

pub const EntityLayer = struct {
    name: []const u8,
};

pub const Layer = union {
    tilemap: TilemapLayer,
    auto_tilemap: AutoTilemapLayer,
    entity: EntityLayer,
};

pub fn draw(state: *editor.AppState) void {
    if (igBegin("Layers", null, ImGuiWindowFlags_None)) {
        // loop through all layers and draw their names as selectables

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
            inline for (@typeInfo(LayerType).Enum.fields) |field| {
                var buf: [15]u8 = undefined;
                _ = std.mem.replace(u8, field.name, "_", " ", buf[0..]);
                if (igSelectableBool(&buf[0], new_layer_type == @intToEnum(LayerType, field.value), ImGuiSelectableFlags_None, .{})) {
                    new_layer_type = @intToEnum(LayerType, field.value);
                }
            }
            igEndCombo();
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
