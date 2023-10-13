const std = @import("std");
const assets = @import("mod.zig");

const AssetIndex = assets.AssetIndex;

pub fn Handle(comptime T: type) type {
    return struct {
        const Self = @This();
        const phantom = T;

        asset_index: AssetIndex,

        pub fn init(asset_index: AssetIndex) Self {
            return .{ .asset_id = asset_index };
        }
    };
}
