const std = @import("std");
const aya = @import("../aya.zig");
const self = @This();

pub usingnamespace @import("spatial_bundle.zig");
pub usingnamespace @import("image.zig");
pub usingnamespace @import("gfx.zig");
pub usingnamespace @import("batcher.zig");
pub usingnamespace @import("fontbook.zig");
pub usingnamespace @import("mesh.zig");

pub const RenderPlugin = struct {
    pub fn build(_: RenderPlugin, app: *aya.App) void {
        _ = app
            .insertResource(ClearColor{})
            .initResource(self.GraphicsContext);
    }
};

/// Resource. stores the color that is used to clear the screen between frames
pub const ClearColor = struct {
    r: f32 = 0.8,
    g: f32 = 0.2,
    b: f32 = 0.3,
    a: f32 = 1,
};

/// Component. controls a Camera's clear behavior
pub const ClearColorConfig = union {
    /// The clear color is taken from the world's [`ClearColor`] resource.
    default: void,
    /// The given clear color is used, overriding the [`ClearColor`] resource defined in the world
    custom: ClearColor,
    /// No clear color is used: the camera will simply draw on top of anything already in the viewport
    none: void,
};
