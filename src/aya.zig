const std = @import("std");

pub const utils = @import("utils.zig");

// inner modules
pub usingnamespace @import("app/mod.zig");
pub usingnamespace @import("asset/mod.zig");
pub usingnamespace @import("input/mod.zig");
pub usingnamespace @import("window/window.zig");
pub usingnamespace @import("ecs/mod.zig");

// TODO: be more restrictive with exports and possibly dump them into sub-structs per module
