const aya = @import("../../aya.zig");
const Mesh = @import("../mesh.zig").Mesh;

pub const Icosphere = struct {
    radius: f32 = 1,
    subdivisions: usize = 5,

    pub fn init(radius: f32, subdivisions: usize) Icosphere {
        return .{ .radius = radius, .subdivisions = subdivisions };
    }

    pub fn toMesh(self: Icosphere) Mesh {
        if (self.subdivisions > 80) @panic("Icosphere is limited to 80 subdivisions");
        @panic("Not implemented yet");
    }
};
