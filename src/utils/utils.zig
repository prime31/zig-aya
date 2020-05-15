pub const tilemap = @import("tilemap.zig");

pub fn cstr_cmp(a: []const u8, b: [*:0]const u8) i8 {
    var index: usize = 0;
    while (a[index] == b[index] and b[index + 1] != 0) : (index += 1) {}
    if (a[index] > b[index]) {
        return 1;
    } else if (a[index] < b[index]) {
        return -1;
    } else {
        return 0;
    }
}
