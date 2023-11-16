const std = @import("std");
const aya = @import("aya");

const ShaderState = aya.render.ShaderState;
const Shader = aya.render.Shader;
const Vec2 = aya.math.Vec2;
const Vec3 = aya.math.Vec3;
const Mat4 = aya.math.Mat4;

pub const DeferredPointShader = ShaderState(DeferredPointParams);
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

pub fn createCubeShader() Shader {
    const vert = @embedFile("cube_vs.glsl");
    const frag = "examples/assets/shaders/cube_fs.glsl";
    return Shader.initWithVertFrag(CubeParamsVS, struct { pub const metadata = .{ .images = .{ "tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createDeferredShader() Shader {
    const vert = @embedFile("deferred_vs.glsl");
    const frag = "examples/assets/shaders/deferred_fs.glsl";
    return Shader.initWithVertFrag(DeferredVertexParams, struct { pub const metadata = .{ .images = .{ "main_tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createDeferredPointShader() DeferredPointShader {
    const frag = "examples/assets/shaders/deferred_point_fs.glsl";
    return DeferredPointShader.init(.{ .frag = frag, .onPostBind = DeferredPointShader.onPostBind });
}

pub fn createDepthShader() DepthShader {
    const frag = "examples/assets/shaders/depth_fs.glsl";
    return DepthShader.init(.{ .frag = frag, .onPostBind = DepthShader.onPostBind });
}

pub fn createDissolveShader() DissolveShader {
    const frag = "examples/assets/shaders/dissolve_fs.glsl";
    return DissolveShader.init(.{ .frag = frag, .onPostBind = DissolveShader.onPostBind });
}

pub fn createInstancedShader() Shader {
    const vert = @embedFile("instanced_vs.glsl");
    const frag = "examples/assets/shaders/instanced_fs.glsl";
    return Shader.initWithVertFrag(InstancedVertParams, struct { pub const metadata = .{ .images = .{ "main_tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createLinesShader() LinesShader {
    const frag = "examples/assets/shaders/lines_fs.glsl";
    return LinesShader.init(.{ .frag = frag, .onPostBind = LinesShader.onPostBind });
}

pub fn createMetaFlamesShader() MetaFlamesShader {
    const frag = "examples/assets/shaders/meta_flames_fs.glsl";
    return MetaFlamesShader.init(.{ .frag = frag, .onPostBind = MetaFlamesShader.onPostBind });
}

pub fn createMode7Shader() Mode7Shader {
    const frag = "examples/assets/shaders/mode7_fs.glsl";
    return Mode7Shader.init(.{ .frag = frag, .onPostBind = Mode7Shader.onPostBind });
}

pub fn createMrtShader() Shader {
    const vert = @embedFile("sprite_vs.glsl");
    const frag = "examples/assets/shaders/mrt_fs.glsl";
    return Shader.initWithVertFrag(VertexParams, struct { pub const metadata = .{ .images = .{ "main_tex" } }; }, .{ .frag = frag, .vert = vert });
}

pub fn createNoiseShader() NoiseShader {
    const frag = "examples/assets/shaders/noise_fs.glsl";
    return NoiseShader.init(.{ .frag = frag, .onPostBind = NoiseShader.onPostBind });
}

pub fn createPixelGlitchShader() PixelGlitchShader {
    const frag = "examples/assets/shaders/pixel_glitch_fs.glsl";
    return PixelGlitchShader.init(.{ .frag = frag, .onPostBind = PixelGlitchShader.onPostBind });
}

pub fn createRgbShiftShader() RgbShiftShader {
    const frag = "examples/assets/shaders/rgb_shift_fs.glsl";
    return RgbShiftShader.init(.{ .frag = frag, .onPostBind = RgbShiftShader.onPostBind });
}

pub fn createSepiaShader() SepiaShader {
    const frag = "examples/assets/shaders/sepia_fs.glsl";
    return SepiaShader.init(.{ .frag = frag, .onPostBind = SepiaShader.onPostBind });
}

pub fn createVignetteShader() VignetteShader {
    const frag = "examples/assets/shaders/vignette_fs.glsl";
    return VignetteShader.init(.{ .frag = frag, .onPostBind = VignetteShader.onPostBind });
}


pub const DeferredPointParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex", "normals_tex", "diffuse_tex" },
        .uniforms = .{ .DeferredPointParams = .{ .type = .float4, .array_count = 4 } },
    };

    min_angle: f32 = 0,
    max_angle: f32 = 0,
    falloff_angle: f32 = 0,
    volumetric_intensity: f32 = 0,
    resolution: Vec2 = .{},
    _pad8_0_: [8]u8 = [_]u8{0} ** 8,
    color: [4]f32 = [_]f32{0} ** 4,
    intensity: f32 = 0,
    __pad3: [3]f32 = [_]f32{0} ** 3,
};

pub const NoiseParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex" },
        .uniforms = .{ .NoiseParams = .{ .type = .float4, .array_count = 1 } },
    };

    time: f32 = 0,
    power: f32 = 0,
    __pad2: [2]f32 = [_]f32{0} ** 2,
};

pub const DepthParamsFS = extern struct {
    pub const metadata = .{
        .images = .{  },
        .uniforms = .{ .DepthParamsFS = .{ .type = .float4, .array_count = 1 } },
    };

    near: f32 = 0,
    far: f32 = 0,
    __pad2: [2]f32 = [_]f32{0} ** 2,
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
    __pad1: [1]f32 = [_]f32{0} ** 1,
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
    __pad3: [3]f32 = [_]f32{0} ** 3,
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

pub const DeferredVertexParams = extern struct {
    pub const metadata = .{
        .uniforms = .{ .DeferredVertexParams = .{ .type = .float4, .array_count = 2 } },
    };

    transform_matrix: [8]f32 = [_]f32{0} ** 8,
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
    __pad2: [2]f32 = [_]f32{0} ** 2,
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

