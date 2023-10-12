const std = @import("std");

pub const utils = @import("utils.zig");

// inner modules
pub usingnamespace @import("app/mod.zig");
pub usingnamespace @import("asset/mod.zig");
pub usingnamespace @import("window/mod.zig");
pub usingnamespace @import("ecs/mod.zig");
pub usingnamespace @import("gizmos/mod.zig");
pub usingnamespace @import("render/mod.zig");
pub usingnamespace @import("sokol/mod.zig");

// TODO: be more restrictive with exports and possibly dump them into sub-structs per module
