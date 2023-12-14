const std = @import("std");
const testing = std.testing;
const LDtk = @import("LDtk.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var ldtk = try LDtk.parse(gpa.allocator(), @embedFile("ldtk.ldtk"));
    defer ldtk.deinit();

    var ldtk_root = ldtk.root;

    try testing.expectEqualStrings("1.4.1", ldtk_root.jsonVersion);
    try testing.expectEqualStrings("#806262", ldtk_root.bgColor);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridHeight);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridWidth);
    try testing.expectEqual(@as(?LDtk.WorldLayout, LDtk.WorldLayout.Free), ldtk_root.worldLayout);
    try testing.expect(!ldtk_root.externalLevels);

    try testing.expectEqual(@as(usize, 3), ldtk_root.levels.len);

    const level_0 = ldtk_root.levels[0];
    try testing.expectEqualStrings("Your_typical_2D_platformer", level_0.identifier);
    try testing.expectEqualStrings("a315ac10-66b0-11ec-9cd7-99f223ad6ade", level_0.iid);
    try testing.expectEqualStrings("#50506A", level_0.__bgColor);
    try testing.expectEqual(@as(i64, 0), level_0.uid);
    try testing.expectEqual(@as(i64, 0), level_0.worldX);
    try testing.expectEqual(@as(i64, 0), level_0.worldY);
    try testing.expectEqual(@as(i64, 0), level_0.worldDepth);
    try testing.expectEqual(@as(i64, 848), level_0.pxWid);
    try testing.expectEqual(@as(i64, 336), level_0.pxHei);
    try testing.expectEqual(@as(?[]const u8, null), level_0.externalRelPath);
    try testing.expectEqual(@as(?[]const u8, null), level_0.bgRelPath);
    try testing.expectEqual(@as(usize, 2), level_0.__neighbours.len);
    try testing.expectEqualStrings("Entities", level_0.layerInstances.?[0].__identifier);
    try testing.expectEqualStrings("Wall_shadows", level_0.layerInstances.?[1].__identifier);

    std.debug.print("all done\n", .{});
}
