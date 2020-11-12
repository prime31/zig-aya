const aya = @import("../../aya.zig");
const shaders = @import("shaders");
const Pipeline = aya.gfx.Pipeline;
const Vec2 = aya.math.Vec2;
const Vec3 = aya.math.Vec3;
const Vec4 = aya.math.Vec4;

pub const Lines = struct {
    pub const Params = extern struct {
        pub const inspect = .{
            .line_color = .{ .min = 0.0, .max = 1.0 },
            .line_size = .{ .min = 1.0, .max = 50.0 },
        };

        line_color: aya.math.Vec4,
        line_size: f32,
    };

    pub fn init() Pipeline {
        return Pipeline.init(shaders.lines_shader_desc());
    }
};

pub const Noise = struct {
    pub const Params = extern struct {
        time: f32,
        power: f32,
    };

    pub fn init() Pipeline {
        return Pipeline.init(shaders.noise_shader_desc());
    }
};

pub const Dissolve = struct {
    pub const Params = extern struct {
        pub const inspect = .{
            .threshold_color = .{ .min = 0.0, .max = 1.0 },
            .threshold = .{ .min = 0.0, .max = 0.5 },
        };

        progress: f32 = 0.5,
        threshold: f32 = 0.5,
        threshold_color: Vec4 align(16),
    };

    pub fn init() Pipeline {
        return Pipeline.init(shaders.dissolve_shader_desc());
    }
};

pub const Mode7 = struct {
    pub const Params = extern struct {
        mapw: f32 = 0,
        maph: f32 = 0,
        x: f32 = 0,
        y: f32 = 0,
        zoom: f32 = 0,
        fov: f32 = 0,
        offset: f32 = 0,
        wrap: f32 = 0,
        x1: f32 = 0,
        x2: f32 = 0,
        y1: f32 = 0,
        y2: f32 = 0,
    };

    pub fn init() Pipeline {
        return Pipeline.init(shaders.mode7_shader_desc());
    }
};