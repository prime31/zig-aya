const std = @import("std");
const aya = @import("aya");

const ShaderState = aya.render.ShaderState;
const Shader = aya.render.Shader;
const Mat4 = aya.math.Mat4;
const Vec2 = aya.math.Vec2;
const Vec3 = aya.math.Vec3;

pub const DepthShader = ShaderState(DepthParamsFS);
pub const DissolveShader = ShaderState(DissolveParams);
pub const LinesShader = ShaderState(LinesParams);
pub const MetaFlamesShader = ShaderState(MetaFlamesParams);
pub const Mode7Shader = ShaderState(Mode7Params);
pub const NoiseShader = ShaderState(NoiseParams);
pub const PixelGlitchShader = ShaderState(PixelGlitchParams);
pub const RgbShiftShader = ShaderState(RgbShiftParams);
pub const SepiaShader = ShaderState(SepiaParams);
pub const VignetteShader = ShaderState(VignetteParams);

pub fn createCubeShader() !Shader {
    const vert = @embedFile("cube_vs.glsl");
    const frag = @embedFile("cube_fs.glsl");
    return try Shader.initWithVertFrag(CubeParamsVS, struct { pub const metadata = .{ .images = .{ "tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createDepthShader() DepthShader {
    const frag = @embedFile("depth_fs.glsl");
    return DepthShader.init(.{ .frag = frag, .onPostBind = DepthShader.onPostBind });
}

pub fn createDissolveShader() DissolveShader {
    const frag = @embedFile("dissolve_fs.glsl");
    return DissolveShader.init(.{ .frag = frag, .onPostBind = DissolveShader.onPostBind });
}

pub fn createInstancedShader() !Shader {
    const vert = @embedFile("instanced_vs.glsl");
    const frag = @embedFile("instanced_fs.glsl");
    return try Shader.initWithVertFrag(InstancedVertParams, struct { pub const metadata = .{ .images = .{ "main_tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createLinesShader() LinesShader {
    const frag = @embedFile("lines_fs.glsl");
    return LinesShader.init(.{ .frag = frag, .onPostBind = LinesShader.onPostBind });
}

pub fn createMetaFlamesShader() MetaFlamesShader {
    const frag = @embedFile("meta_flames_fs.glsl");
    return MetaFlamesShader.init(.{ .frag = frag, .onPostBind = MetaFlamesShader.onPostBind });
}

pub fn createMode7Shader() Mode7Shader {
    const frag = @embedFile("mode7_fs.glsl");
    return Mode7Shader.init(.{ .frag = frag, .onPostBind = Mode7Shader.onPostBind });
}

pub fn createNoiseShader() NoiseShader {
    const frag = @embedFile("noise_fs.glsl");
    return NoiseShader.init(.{ .frag = frag, .onPostBind = NoiseShader.onPostBind });
}

pub fn createPixelGlitchShader() PixelGlitchShader {
    const frag = @embedFile("pixel_glitch_fs.glsl");
    return PixelGlitchShader.init(.{ .frag = frag, .onPostBind = PixelGlitchShader.onPostBind });
}

pub fn createRgbShiftShader() RgbShiftShader {
    const frag = @embedFile("rgb_shift_fs.glsl");
    return RgbShiftShader.init(.{ .frag = frag, .onPostBind = RgbShiftShader.onPostBind });
}

pub fn createSepiaShader() SepiaShader {
    const frag = @embedFile("sepia_fs.glsl");
    return SepiaShader.init(.{ .frag = frag, .onPostBind = SepiaShader.onPostBind });
}

pub fn createVignetteShader() VignetteShader {
    const frag = @embedFile("vignette_fs.glsl");
    return VignetteShader.init(.{ .frag = frag, .onPostBind = VignetteShader.onPostBind });
}


pub const NoiseParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .NoiseParams = .{ .type = .float4, .array_count = 1 } },
    };

    time: f32 = 0,
    power: f32 = 0,
    _pad8_0_: [8]u8 = [_]u8{0} ** 8,
};

pub const DepthParamsFS = extern struct {
    pub const metadata = .{
        .images = .{  },
        .uniforms = .{ .DepthParamsFS = .{ .type = .float4, .array_count = 1 } },
    };

    near: f32 = 0,
    far: f32 = 0,
    _pad8_0_: [8]u8 = [_]u8{0} ** 8,
};

pub const RgbShiftParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .RgbShiftParams = .{ .type = .float4, .array_count = 1 } },
    };

    shift: f32 = 0,
    alpha: f32 = 0,
    screen_size: Vec2 = .{},
};

pub const InstancedVertParams = extern struct {
    pub const metadata = .{
        .uniforms = .{ .InstancedVertParams = .{ .type = .float4, .array_count = 2 } },
    };

    transform_matrix: [8]f32 = [_]f32{0} ** 8,
};

pub const MetaFlamesParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .MetaFlamesParams = .{ .type = .float4, .array_count = 2 } },
    };

    tear_sharpness: f32 = 0,
    tear_wave_length: f32 = 0,
    tear_wave_speed: f32 = 0,
    tear_wave_amplitude: f32 = 0,
    time: f32 = 0,
    _pad4_0_: [4]u8 = [_]u8{0} ** 4,
    screen_size: Vec2 = .{},
};

pub const SepiaParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .SepiaParams = .{ .type = .float4, .array_count = 1 } },
    };

    sepia_tone: Vec3 = .{},
    _pad12_0_: [4]u8 = [_]u8{0} ** 4,
};

pub const VertexParams = extern struct {
    pub const metadata = .{
        .uniforms = .{ .VertexParams = .{ .type = .float4, .array_count = 2 } },
    };

    transform_matrix: [8]f32 = [_]f32{0} ** 8,
};

pub const LinesParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .LinesParams = .{ .type = .float4, .array_count = 2 } },
    };

    line_color: [4]f32 = [_]f32{0} ** 4,
    line_size: f32 = 0,
    _pad20_0_: [12]u8 = [_]u8{0} ** 12,
};

pub const DissolveParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex", "dissolve_tex" },
        .uniforms = .{ .DissolveParams = .{ .type = .float4, .array_count = 2 } },
    };

    progress: f32 = 0,
    threshold: f32 = 0,
    _pad8_0_: [8]u8 = [_]u8{0} ** 8,
    threshold_color: [4]f32 = [_]f32{0} ** 4,
};

pub const Mode7Params = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex", "map_tex" },
        .uniforms = .{ .Mode7Params = .{ .type = .float4, .array_count = 3 } },
    };

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

pub const VignetteParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .VignetteParams = .{ .type = .float4, .array_count = 1 } },
    };

    radius: f32 = 0,
    power: f32 = 0,
    _pad8_0_: [8]u8 = [_]u8{0} ** 8,
};

pub const PixelGlitchParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .PixelGlitchParams = .{ .type = .float4, .array_count = 1 } },
    };

    vertical_size: f32 = 0,
    horizontal_offset: f32 = 0,
    screen_size: Vec2 = .{},
};

pub const CubeParamsVS = extern struct {
    pub const metadata = .{
        .uniforms = .{ .CubeParamsVS = .{ .type = .float4, .array_count = 4 } },
    };

    mvp: Mat4 = .{},
};

