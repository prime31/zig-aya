const std = @import("std");
const aya = @This();

pub const utils = @import("utils.zig");
pub const trait = @import("trait.zig");

// inner modules
pub usingnamespace @import("app/mod.zig");
pub usingnamespace @import("asset/mod.zig");
pub usingnamespace @import("window/mod.zig");
pub usingnamespace @import("ecs/mod.zig");
pub usingnamespace @import("gizmos/mod.zig");
pub usingnamespace @import("render/mod.zig");
pub usingnamespace @import("sokol/mod.zig");

pub const mem = struct {
    pub fn create(comptime T: type) *T {
        return aya.allocator.create(T) catch unreachable;
    }

    pub fn destroy(ptr: anytype) void {
        aya.allocator.destroy(ptr);
    }

    pub fn alloc(comptime T: type, n: usize) []T {
        return aya.allocator.alloc(T, n) catch unreachable;
    }

    pub fn free(memory: anytype) void {
        aya.allocator.free(memory);
    }
};

// TODO: be more restrictive with exports and possibly dump them into sub-structs per module
