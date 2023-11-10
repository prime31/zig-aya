const std = @import("std");
pub const sdl = @import("imgui_sdl3.zig");
pub const icons = @import("font_awesome.zig");
pub const enabled = @import("options").imgui;

pub usingnamespace @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    @cInclude("cimgui.h");
});

const ig = @This();

// helper for getting window titles and other dynamic strings for Dear ImGui
var temp_buffer: [512]u8 = undefined;

pub fn format(comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.bufPrint(&temp_buffer, fmt, args) catch unreachable;
}

pub fn formatZ(comptime fmt: []const u8, args: anytype) [:0]const u8 {
    return std.fmt.bufPrintZ(&temp_buffer, fmt, args) catch unreachable;
}

const DataType = enum(c_int) { I8, U8, I16, U16, I32, U32, I64, U64, F32, F64 };

fn typeToDataTypeEnum(comptime T: type) DataType {
    return switch (T) {
        i8 => .I8,
        u8 => .U8,
        i16 => .I16,
        u16 => .U16,
        i32 => .I32,
        u32 => .U32,
        i64 => .I64,
        u64 => .U64,
        f32 => .F32,
        f64 => .F64,
        usize => switch (@sizeOf(usize)) {
            1 => .U8,
            2 => .U16,
            4 => .U32,
            8 => .U64,
            else => @compileError("Unsupported usize length"),
        },
        else => @compileError("Only fundamental scalar types allowed: " ++ @typeName(T)),
    };
}

fn typeToDataTypeInt(comptime T: type) c_int {
    return @intFromEnum(typeToDataTypeEnum(T));
}

// Sliders
pub const SliderFlags = packed struct(u32) {
    _reserved0: bool = false,
    _reserved1: bool = false,
    _reserved2: bool = false,
    _reserved3: bool = false,
    always_clamp: bool = false,
    logarithmic: bool = false,
    no_round_to_format: bool = false,
    no_input: bool = false,
    _padding: u24 = 0,
};

fn SliderScalarGen(comptime T: type) type {
    return struct {
        v: *T,
        min: T,
        max: T,
        cfmt: ?[:0]const u8 = null,
        flags: SliderFlags = .{},
    };
}
pub fn sliderScalar(label: [:0]const u8, comptime T: type, args: SliderScalarGen(T)) bool {
    return ig.igSliderScalar(
        label,
        typeToDataTypeInt(T),
        @as(*anyopaque, args.v),
        &args.min,
        &args.max,
        if (args.cfmt) |fmt| fmt else null,
        @bitCast(args.flags),
    );
}

// Combos
pub const ComboFlags = packed struct(u32) {
    popup_align_left: bool = false,
    height_small: bool = false,
    height_regular: bool = false,
    height_large: bool = false,
    height_largest: bool = false,
    no_arrow_button: bool = false,
    no_preview: bool = false,
    _padding: u25 = 0,
};

const BeginCombo = struct {
    preview_value: [*:0]const u8,
    flags: ComboFlags = .{},
};

pub fn beginCombo(label: [:0]const u8, args: BeginCombo) bool {
    return ig.igBeginCombo(label, args.preview_value, @bitCast(args.flags));
}

// Selectables
pub const SelectableFlags = packed struct(u32) {
    dont_close_popups: bool = false,
    span_all_columns: bool = false,
    allow_double_click: bool = false,
    disabled: bool = false,
    allow_item_overlap: bool = false,
    _padding: u27 = 0,
};
//--------------------------------------------------------------------------------------------------
const Selectable = struct {
    selected: bool = false,
    flags: SelectableFlags = .{},
    w: f32 = 0,
    h: f32 = 0,
};
pub fn selectable(label: [:0]const u8, args: Selectable) bool {
    return ig.igSelectable_Bool(label, args.selected, @bitCast(args.flags), .{ .x = args.w, .y = args.h });
}
