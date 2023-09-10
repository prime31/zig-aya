const std = @import("std");
const assets = @import("mod.zig");

const AssetId = assets.AssetId;

pub fn Handle(comptime T: type) type {
    return struct {
        const Self = @This();
        const phantom = T;

        asset_id: AssetId,

        pub fn init(asset_id: AssetId) Self {
            return .{ .asset_id = asset_id };
        }
    };
}
