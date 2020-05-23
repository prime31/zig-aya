pub const tilemap = @import("tilemap.zig");
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

test "test cstr" {
    const std = @import("std");
    const slice = try std.cstr.addNullByte(std.testing.allocator, "hello"[0..4]);
    defer std.testing.allocator.free(slice);
    const span = std.mem.spanZ(slice);

    std.testing.expect(cstr_u8_cmp(slice, span) == 0);
    std.testing.expect(cstr_u8_cmp(slice, "hell") == 0);
    std.testing.expect(cstr_u8_cmp(span, "hell") == 0);
}
