const std = @import("std");
const aya = @import("../aya.zig");

const Vec2 = aya.Vec2;
const Color = aya.Color;
const Rect = aya.Rect;

pub const Sprite = struct {
    /// The sprite's color tint
    color: Color,
    /// Flip the sprite along the `X` axis
    flip_x: bool,
    /// Flip the sprite along the `Y` axis
    flip_y: bool,
    /// An optional custom size for the sprite that will be used when rendering, instead of the size
    /// of the sprite's image
    custom_size: ?Vec2,
    /// An optional rectangle representing the region of the sprite's image to render, instead of
    /// rendering the full image. This is an easy one-off alternative to using a texture atlas.
    rect: ?Rect,
    /// [`Anchor`] point of the sprite in the world
    anchor: Anchor,
};

pub const TextureAtlasSprite = struct {
    /// The tint color used to draw the sprite, defaulting to [`Color::WHITE`]
    color: Color,
    /// Texture index in [`TextureAtlas`]
    index: usize,
    /// Whether to flip the sprite in the X axis
    flip_x: bool,
    /// Whether to flip the sprite in the Y axis
    flip_y: bool,
    /// An optional custom size for the sprite that will be used when rendering, instead of the size
    /// of the sprite's image in the atlas
    custom_size: ?Vec2,
    /// [`Anchor`] point of the sprite in the world
    anchor: Anchor,
};

pub const Anchor = union(enum) {
    center: void,
    bottom_left: void,
    bottom_center: void,
    bottom_right: void,
    center_left: void,
    center_right: void,
    top_left: void,
    top_center: void,
    top_right: void,
    /// Custom anchor point. Top left is `(-0.5, 0.5)`, center is `(0.0, 0.0)`. The value will
    /// be scaled with the sprite size.
    custom: Vec2,

    pub fn asVec(self: *Anchor) Vec2 {
        switch (self) {
            .center => Vec2{},
            .bottom_left => Vec2.init(-0.5, -0.5),
            .bottom_center => Vec2.init(0.0, -0.5),
            .bottom_right => Vec2.init(0.5, -0.5),
            .center_left => Vec2.init(-0.5, 0.0),
            .center_right => Vec2.init(0.5, 0.0),
            .top_left => Vec2.init(-0.5, 0.5),
            .top_center => Vec2.init(0.0, 0.5),
            .top_right => Vec2.init(0.5, 0.5),
            .custom => |pt| pt,
        }
    }
};

pub const Material = struct {
    shader: ?aya.Shader = null,
    texture: aya.Texture,
    texture2: ?aya.Texture = null,
    texture3: ?aya.Texture = null,
    texture4: ?aya.Texture = null,
};

pub const MeshRenderer = struct {
    render: *const fn () void,

    pub fn init(comptime MeshT: type) void {
        return .{
            .render = struct {
                pub fn render() void {
                    std.debug.print("foook you, captured type: {}\n", .{MeshT});
                }
            }.render,
        };
    }
};

// System could maybe query:
// - sprites need the following for rendering:
//      * Sprite, Material, ?RenderState
// - Sprite, Material, MeshRenderer
