const std = @import("std");
const aya = @import("aya");
const data = @import("data/data.zig");
const components = @import("data/components.zig");
const AppState = data.AppState;

const AppStateJson = struct {
    tile_size: usize,
    snap_size: u8,
    clear_color: u32,
    bg_color: u32,
    components: []components.Component,
    next_component_id: u8 = 0,
    selected_layer_index: usize = 0,

    pub fn init(state: *AppState) AppStateJson {
        return .{
            .tile_size = state.tile_size,
            .snap_size = state.snap_size,
            .clear_color = state.clear_color.value,
            .bg_color = state.bg_color.value,
            .components = state.components.items,
            .next_component_id = state.next_component_id,
            .selected_layer_index = state.selected_layer_index,
        };
    }
};

fn fart(state: *AppState) !void {
    var handle = try std.fs.cwd().createFile("project2.json", .{});

    const state_json = AppStateJson.init(state);
    try std.json.stringify(state_json, .{}, handle.writer());
    handle.close();

    // and back
    var bytes = try aya.fs.read(aya.mem.tmp_allocator, "project2.json");
    var res = try std.json.parse(AppStateJson, &std.json.TokenStream.init(bytes), .{ .allocator = aya.mem.allocator });

    for (res.components) |comp| {
        std.log.info("{s}", .{comp.name});
        for (comp.props) |prop| {
            std.log.info("    name: {s}, val: {s}", .{prop.name, prop.value});
        }
    }
}



pub fn saveProject(state: *AppState) !void {
    try fart(state);

    var handle = try std.fs.cwd().createFile("project.json", .{});
    defer handle.close();
    const out_stream = handle.writer();

    var jw = std.json.writeStream(out_stream, 10);
    try jw.beginObject();

    try writeNumber(&jw, "tile_size", state.tile_size);
    try writeNumber(&jw, "snap_size", state.snap_size);
    try writeNumber(&jw, "clear_color", state.clear_color.value);
    try writeNumber(&jw, "bg_color", state.bg_color.value);
    try writeNumber(&jw, "next_component_id", state.next_component_id);

    try jw.objectField("components");
    try jw.beginArray();
    for (state.components.items) |component| {
        try jw.arrayElem();
        try jw.beginObject();

        try writeNumber(&jw, "id", component.id);
        try writeString(&jw, "name", &component.name);
        try writeNumber(&jw, "next_property_id", component.next_property_id);

        try jw.objectField("props");
        try jw.beginArray();
        {
            defer jw.endArray() catch unreachable;

            for (component.props) |prop| {
                try jw.arrayElem();
                try jw.beginObject();

                try writeNumber(&jw, "id", prop.id);
                try writeString(&jw, "name", &prop.name);
                try writePropertyValue(&jw, prop.value);

                try jw.endObject();
            }
        }

        try jw.endObject();
    }
    try jw.endArray();

    try jw.endObject();
}

fn writeValue(value: anytype, writer: anytype) !void {
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        .Float, .Int, .ComptimeInt, .ComptimeFloat => try writer.emitNumber(value),
        .Bool => try writer.emitBool(value),
        .Struct => |S| {
            if (T == aya.math.Vec2) {
                try writer.beginObject();
                try writer.objectField("x");
                try writer.emitNumber(value.x);
                try writer.objectField("y");
                try writer.emitNumber(value.y);
                try writer.endObject();
            } else {
                @compileError("Unable to write struct type " ++ @typeName(T));
            }
        },
        else => @compileError("Unable to write type " ++ @typeName(T)),
    }
}

fn writeNumber(writer: anytype, field_name: []const u8, value: anytype) !void {
    try writer.objectField(field_name);
    try writeValue(value, writer);
}

fn writeString(writer: anytype, field_name: []const u8, string: [:0]const u8) !void {
    const sentinel = std.mem.indexOfScalar(u8, string, 0) orelse string.len;
    const str = string[0..sentinel];
    try writer.objectField(field_name);
    try writer.emitString(str);
}

fn writePropertyValue(writer: anytype, value: components.PropertyValue) !void {
    try writer.objectField("property");
    try writer.beginObject();

    const tag = std.meta.activeTag(value);
    try writer.objectField("type");
    try writer.emitString(@tagName(tag));

    try writer.objectField("value");
    switch (value) {
        .string => |str| {
            const sentinel = std.mem.indexOfScalar(u8, &str, 0) orelse str.len;
            try writer.emitString(str[0..sentinel]);
        },
        .int => |i| try writeValue(i, writer),
        .float => |f| try writeValue(f, writer),
        .bool => |b| try writeValue(b, writer),
        .vec2 => |v| try writeValue(v, writer),
        .enum_values => |vals| {
            try writer.beginArray();
            for (vals) |val| {
                try writer.arrayElem();
                const sentinel = std.mem.indexOfScalar(u8, &val, 0) orelse val.len;
                try writer.emitString(val[0..sentinel]);
            }
            try writer.endArray();
        },
        .entity_link => |l| try writeValue(l, writer),
    }

    try writer.endObject();
}

pub fn loadProject(path: []const u8) !AppState {
    var state = AppState.init();

    return state;
}
