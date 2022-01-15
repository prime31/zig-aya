const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders/shaders.zig");

const PostProcessor = aya.gfx.PostProcessor;
const OffscreenPass = aya.gfx.OffscreenPass;

pub const Sepia = struct {
    postprocessor: PostProcessor,
    shader: shaders.SepiaShader,

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        _ = data;
        self.postprocessor = .{ .process = process };
        self.shader = shaders.createSepiaShader();
        self.shader.frag_uniform.sepia_tone = .{ .x = 1.2, .y = 1.0, .z = 0.8 };
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, &self.shader.shader);
    }

    pub fn setTone(self: *@This(), tone: aya.math.Vec3) void {
        self.shader.frag_uniform.sepia_tone = tone;
    }
};

pub const Vignette = struct {
    postprocessor: PostProcessor,
    shader: shaders.VignetteShader,

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        _ = data;
        self.postprocessor = .{ .process = process };
        self.shader = shaders.createVignetteShader();
        self.shader.frag_uniform.radius = 1.2;
        self.shader.frag_uniform.power = 1;
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, &self.shader.shader);
    }

    pub fn setUniforms(self: *@This(), radius: f32, power: f32) void {
        _ = radius;
        _ = power;
        self.shader.frag_uniform.radius = 1.2;
        self.shader.frag_uniform.power = 1;
    }
};

pub const PixelGlitch = struct {
    postprocessor: PostProcessor,
    shader: shaders.PixelGlitchShader,

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        _ = data;
        self.postprocessor = .{ .process = process };
        self.shader = shaders.createPixelGlitchShader();

        const size = aya.window.size();
        self.shader.frag_uniform.screen_size = .{ .x = @intToFloat(f32, size.w), .y = @intToFloat(f32, size.h) };
        self.shader.frag_uniform.vertical_size = 0.5;
        self.shader.frag_uniform.horizontal_offset = 10;
    }

    pub fn process(processor: *PostProcessor, pass: OffscreenPass, tex: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, tex, &self.shader.shader);
    }

    pub fn setUniforms(self: *@This(), vertical_size: f32, horizontal_offset: f32) void {
        _ = vertical_size;
        _ = horizontal_offset;
        const size = aya.window.size();
        self.params.screen_size = .{ .x = @intToFloat(f32, size.w), .y = @intToFloat(f32, size.h) };
        self.shader.frag_uniform.vertical_size = 0.5;
        self.shader.frag_uniform.horizontal_offset = 10;
    }
};
