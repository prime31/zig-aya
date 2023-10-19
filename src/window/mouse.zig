pub const MouseMotion = struct {
    x: f32,
    y: f32,
    /// The change in the position of the pointing device since the last event was sent.
    xrel: f32,
    yrel: f32,
};

pub const MouseWheel = struct {
    pub const Direction = enum { normal, flipped };
    /// The mouse scroll unit.
    // unit: MouseScrollUnit,
    /// The horizontal scroll value.
    x: f32,
    /// The vertical scroll value.
    y: f32,
    direction: Direction,
};

pub const MouseButton = enum(u8) {
    left = 1,
    middle = 2,
    right = 3,

    pub const max = MouseButton.right;
};
