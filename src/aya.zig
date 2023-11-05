const std = @import("std");
const aya = @This();

// common globals. should these be put in the ECS?
const Window = @import("window/window.zig").Window;
const Debug = @import("render/debug.zig").Debug;
const Time = @import("time.zig").Time;
const Input = @import("input.zig").Input;
const GraphicsContext = @import("render/gfx.zig").GraphicsContext;

// essentially our fields, just made globals for ease of access
pub var window: Window = undefined;
pub var debug: Debug = undefined;
pub var time: Time = undefined;
pub var input: Input = undefined;
pub var gfx: GraphicsContext = undefined;

pub const utils = @import("utils.zig");
pub const trait = @import("trait.zig");
pub const fs = @import("fs.zig");
pub const rk = @import("renderkit");

// inner modules
// TODO: be more restrictive with exports and possibly dump them into sub-structs per module
pub usingnamespace @import("app/mod.zig");
pub usingnamespace @import("asset/mod.zig");
pub usingnamespace @import("window/mod.zig");
pub usingnamespace @import("ecs/mod.zig");
pub usingnamespace @import("math/mod.zig");
pub usingnamespace @import("render/mod.zig");

pub fn init() void {
    window = Window.init(.{});
    debug = Debug.init();
    time = Time.init(60);
    input = Input.init();
    gfx = GraphicsContext.init();
}

pub fn deinit() void {
    window.deinit();
    debug.deinit();
    input.deinit();
    gfx.deinit();
}

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
