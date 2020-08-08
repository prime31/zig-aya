const std = @import("std");
const aya = @import("../aya.zig");
usingnamespace @import("imgui");

pub const FixedList = @import("fixed_list.zig").FixedList;

pub fn cstr_u8_cmp(a: [*:0]const u8, b: []const u8) i8 {
    var index: usize = 0;
    while (b[index] == a[index] and a[index + 1] != 0) : (index += 1) {}
    if (b[index] > a[index]) {
        return 1;
    } else if (b[index] < a[index]) {
        return -1;
    } else {
        return 0;
    }
}

inline fn getConstPtr(val: anytype) [*c]const u8 {
    return @as([*c]const u8, std.mem.sliceAsBytes(val[0..]).ptr);
}

pub fn inspect(label: []const u8, value: anytype) void {
    if (!aya.has_imgui) return;

    const T = comptime @TypeOf(value);
    comptime std.debug.assert(std.meta.trait.is(.Pointer)(T));

    if (comptime std.meta.trait.isSlice(T) or comptime std.meta.trait.isPtrTo(.Array)(T)) {
        for (ptr) |*v|
            inspect(label, v);
        return;
    }

    const C = comptime std.meta.Child(T);

    // special cases
    switch (C) {
        aya.math.Vec4 => {
            var tmp = value.asArray();
            if (igDragFloat4(getConstPtr(label), &tmp, 1, std.math.f32_min, std.math.f32_max, null, 1)) {
                value.x = tmp[0];
                value.y = tmp[1];
                value.z = tmp[2];
                value.w = tmp[3];
            }
            return;
        },
        else => {},
    }

    const child_type_info = @typeInfo(C);

    switch (child_type_info) {
        .Bool => {
            std.debug.print("hi bool\n", .{});
        },
        .Float => {
            igPushIDPtr(value);
            var tmp = @alignCast(@alignOf(f32), value);
            if (igDragFloat(getConstPtr(label), tmp, 1, std.math.f32_min, std.math.f32_max, null, 1)) {
                value.* = tmp.*;
            }
            igPopID();
        },
        .Struct => {
            const info = @typeInfo(C).Struct;
            inline for (info.fields) |*field_info| {
                const name = field_info.name;
                const FieldType = field_info.field_type;
                if (comptime std.meta.trait.is(.Pointer)(FieldType)) {
                    @compileError("Will not " ++ "inspect field " ++ name ++ " of struct " ++
                        @typeName(C) ++ " because it " ++ "is of pointer-type " ++ @typeName(FieldType) ++ ".");
                }
                inspect(name, &@field(value, name));
            }
        },
        else => {},
    }
}

test "test cstr" {
    const std = @import("std");
    const slice = try std.cstr.addNullByte(std.testing.allocator, "hello"[0..4]);
    defer std.testing.allocator.free(slice);
    const span = std.mem.spanZ(slice);

    std.testing.expect(cstr_u8_cmp(slice, span) == 0);
    std.testing.expect(cstr_u8_cmp(slice, "hell") == 0);
    std.testing.expect(cstr_u8_cmp(span, "hell") == 0);
}
