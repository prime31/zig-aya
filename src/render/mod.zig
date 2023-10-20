const std = @import("std");
const aya = @import("../aya.zig");
const zm = @import("zmath");
const self = @This();

pub usingnamespace @import("shapes/mod.zig");
pub usingnamespace @import("mesh.zig");
pub usingnamespace @import("shader.zig");
pub usingnamespace @import("image.zig");
pub usingnamespace @import("pipeline.zig");

pub const RenderPlugin = struct {
    pub fn build(_: RenderPlugin, app: *aya.App) void {
        _ = app.initAsset(self.Mesh)
            .insertResource(ClearColor{});
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

pub const HalfSpace = struct {
    normal_d: zm.Vec,
};

pub const Frustum = struct {
    half_spaces: [6]HalfSpace,
};

pub const CascadesFrusta = struct {
    frusta: std.AutoHashMap(u64, std.ArrayList(Frustum)),
};
