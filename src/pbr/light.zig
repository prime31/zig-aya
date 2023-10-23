const std = @import("std");
const aya = @import("../aya.zig");

const Color = aya.Color;

pub const PointLight = struct {};

pub const SpotLight = struct {};

pub const DirectionalLight = struct {};

pub const Cascades = struct {
    /// Map from a view to the configuration of each of its [`Cascade`]s.
    cascades: std.AutoHashMap(u64, std.ArrayList(aya.Cascade)),
};

pub const CascadeShadowConfig = struct {
    /// The (positive) distance to the far boundary of each cascade.
    bounds: std.ArrayList(f32),
    /// The proportion of overlap each cascade has with the previous cascade.
    overlap_proportion: f32,
    /// The (positive) distance to the near boundary of the first cascade.
    minimum_distance: f32,
};

/// Resource.
pub const AmbientLight = struct {
    color: Color = Color.white,
    /// A direct scale factor multiplied with `color` before being passed to the shader.
    brightness: f32 = 0.05,
};
