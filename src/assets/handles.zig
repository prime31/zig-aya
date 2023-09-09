const std = @import("std");

// AssetId is the same as AssetIndex in bevy
// pub struct AssetIndex {
//     pub(crate) generation: u32,
//     pub(crate) index: u32,
// }
pub const AssetId = struct {};

pub fn Handle(comptime T: type) type {
    return struct {
        const Self = @This();
        const phantom = T;

        asset_id: AssetId = .{},
    };
}
