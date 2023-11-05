const std = @import("std");
const aya = @import("../aya.zig");

pub const LayerMask = u32;
pub const Layer = u8;

pub const RenderLayers = struct {
    /// The total number of layers supported.
    pub const TOTAL_LAYERS: usize = @sizeOf(LayerMask) * 8;

    layers: LayerMask = 0,

    /// Create a new `RenderLayers` belonging to the given layer.
    pub fn initWithLayer(n: Layer) RenderLayers {
        return RenderLayers(0).with(n);
    }

    /// Create a new `RenderLayers` that belongs to all layers.
    pub fn initWithAll() RenderLayers {
        return .{ .layers = std.math.maxInt(u32) };
    }

    /// Create a `RenderLayers` from a slice of layers.
    pub fn initFromLayers(layers: []Layer) RenderLayers {
        return layers.iter().copied().collect();
    }

    /// Add the given layer
    pub fn with(self: *RenderLayers, layer: Layer) *RenderLayers {
        std.debug.assert(@as(usize, layer) < TOTAL_LAYERS);
        self.layers |= 1 << layer;
        return self;
    }

    /// Removes the given rendering layer.
    pub fn without(self: *RenderLayers, layer: Layer) *RenderLayers {
        std.debug.assert(@as(usize, layer) < TOTAL_LAYERS);
        self.layer &= !(1 << layer);
        return self;
    }

    /// Get an iterator of the layers.
    // pub fn iter(self: RenderLayers) impl Iterator<Item = Layer> {
    //     let total: Layer = std::convert::TryInto::try_into(Self::TOTAL_LAYERS).unwrap();
    //     let mask = *self;
    //     return (0..total).filter(move |g| RenderLayers::layer(*g).intersects(&mask))
    // }

    /// Determine if a `RenderLayers` intersects another. RenderLayers`s intersect if they share any common layers.
    /// A `RenderLayers` with no layers will not match any other `RenderLayers`, even another with no layers.
    pub fn intersects(self: RenderLayers, other: RenderLayers) bool {
        return (self.layers & other.layers) > 0;
    }
};
