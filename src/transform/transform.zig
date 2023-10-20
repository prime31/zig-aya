const zm = @import("zmath");

pub const Transform = struct {
    translation: zm.Vec,
    rotation: zm.Quat,
    scale: zm.Vec,
};
