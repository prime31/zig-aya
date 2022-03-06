const std = @import("std");
const aya = @import("aya");
const gfx = aya.gfx;
const math = aya.math;
const renderkit = aya.renderkit;

pub const DepthShader = gfx.ShaderState(DepthParamsFS);
pub const DissolveShader = gfx.ShaderState(DissolveParams);
pub const LinesShader = gfx.ShaderState(LinesParams);
pub const MetaFlamesShader = gfx.ShaderState(MetaFlamesParams);
pub const Mode7Shader = gfx.ShaderState(Mode7Params);
pub const NoiseShader = gfx.ShaderState(NoiseParams);
pub const PixelGlitchShader = gfx.ShaderState(PixelGlitchParams);
pub const RgbShiftShader = gfx.ShaderState(RgbShiftParams);
pub const SepiaShader = gfx.ShaderState(SepiaParams);
pub const VignetteShader = gfx.ShaderState(VignetteParams);

pub fn createCubeShader() !gfx.Shader {
    const vert = if (renderkit.current_renderer == .opengl) @embedFile("cube_vs.glsl") else @embedFile("cube_vs.metal");
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("cube_fs.glsl") else @embedFile("cube_fs.metal");
    return try gfx.Shader.initWithVertFrag(CubeParamsVS, struct { pub const metadata = .{ .images = .{ "tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createDepthShader() DepthShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("depth_fs.glsl") else @embedFile("depth_fs.metal");
    return DepthShader.init(.{ .frag = frag, .onPostBind = DepthShader.onPostBind });
}

pub fn createDissolveShader() DissolveShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("dissolve_fs.glsl") else @embedFile("dissolve_fs.metal");
    return DissolveShader.init(.{ .frag = frag, .onPostBind = DissolveShader.onPostBind });
}

pub fn createInstancedShader() !gfx.Shader {
    const vert = if (renderkit.current_renderer == .opengl) @embedFile("instanced_vs.glsl") else @embedFile("instanced_vs.metal");
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("instanced_fs.glsl") else @embedFile("instanced_fs.metal");
    return try gfx.Shader.initWithVertFrag(InstancedVertParams, struct { pub const metadata = .{ .images = .{ "main_tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createLinesShader() LinesShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("lines_fs.glsl") else @embedFile("lines_fs.metal");
    return LinesShader.init(.{ .frag = frag, .onPostBind = LinesShader.onPostBind });
}

pub fn createMetaFlamesShader() MetaFlamesShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("meta_flames_fs.glsl") else @embedFile("meta_flames_fs.metal");
    return MetaFlamesShader.init(.{ .frag = frag, .onPostBind = MetaFlamesShader.onPostBind });
}

pub fn createMode7Shader() Mode7Shader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("mode7_fs.glsl") else @embedFile("mode7_fs.metal");
    return Mode7Shader.init(.{ .frag = frag, .onPostBind = Mode7Shader.onPostBind });
}

pub fn createNoiseShader() NoiseShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("noise_fs.glsl") else @embedFile("noise_fs.metal");
    return NoiseShader.init(.{ .frag = frag, .onPostBind = NoiseShader.onPostBind });
}

pub fn createPixelGlitchShader() PixelGlitchShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("pixel_glitch_fs.glsl") else @embedFile("pixel_glitch_fs.metal");
    return PixelGlitchShader.init(.{ .frag = frag, .onPostBind = PixelGlitchShader.onPostBind });
}

pub fn createRgbShiftShader() RgbShiftShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("rgb_shift_fs.glsl") else @embedFile("rgb_shift_fs.metal");
    return RgbShiftShader.init(.{ .frag = frag, .onPostBind = RgbShiftShader.onPostBind });
}

pub fn createSepiaShader() SepiaShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("sepia_fs.glsl") else @embedFile("sepia_fs.metal");
    return SepiaShader.init(.{ .frag = frag, .onPostBind = SepiaShader.onPostBind });
}

pub fn createVignetteShader() VignetteShader {
    const frag = if (renderkit.current_renderer == .opengl) @embedFile("vignette_fs.glsl") else @embedFile("vignette_fs.metal");
    return VignetteShader.init(.{ .frag = frag, .onPostBind = VignetteShader.onPostBind });
}


pub const InstancedVertParams = extern struct {
    pub const metadata = .{
        .uniforms = .{ .InstancedVertParams = .{ .type = .float4, .array_count = 2 } },
    };

    transform_matrix: [8]f32 = [_]f32{0} ** 8,
};

pub const NoiseParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .NoiseParams = .{ .type = .float4, .array_count = 1 } },
    };

    time: f32 = 0,
    power: f32 = 0,
    _pad8_0_: [8]u8 = [_]u8{0} ** 8,
};

pub const SepiaParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .SepiaParams = .{ .type = .float4, .array_count = 1 } },
    };

    sepia_tone: math.Vec3 = .{},
    _pad12_0_: [4]u8 = [_]u8{0} ** 4,
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

pub const PixelGlitchParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .PixelGlitchParams = .{ .type = .float4, .array_count = 1 } },
    };

    vertical_size: f32 = 0,
    horizontal_offset: f32 = 0,
    screen_size: math.Vec2 = .{},
};

pub const VertexParams = extern struct {
    pub const metadata = .{
        .uniforms = .{ .VertexParams = .{ .type = .float4, .array_count = 2 } },
    };

    transform_matrix: [8]f32 = [_]f32{0} ** 8,
};

pub const RgbShiftParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .RgbShiftParams = .{ .type = .float4, .array_count = 1 } },
    };

    shift: f32 = 0,
    alpha: f32 = 0,
    screen_size: math.Vec2 = .{},
};

pub const CubeParamsVS = extern struct {
    pub const metadata = .{
        .uniforms = .{ .CubeParamsVS = .{ .type = .float4, .array_count = 4 } },
    };

    mvp: math.Mat4 = .{},
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
    screen_size: math.Vec2 = .{},
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

pub const LinesParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .LinesParams = .{ .type = .float4, .array_count = 2 } },
    };

    line_color: [4]f32 = [_]f32{0} ** 4,
    line_size: f32 = 0,
    _pad20_0_: [12]u8 = [_]u8{0} ** 12,
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

