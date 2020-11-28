const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");
const shaders = @import("assets/shaders/shaders.zig");

pub const renderer: aya.renderkit.Renderer = .opengl;

const Shader = aya.gfx.Shader;
const effects = @import("assets/effects.zig");

pub const enable_imgui = renderer == .opengl;

pub const Flames = struct {
    postprocessor: aya.gfx.PostProcessor,
    shader: shaders.MetaFlamesShader,

    pub fn deinit(self: @This()) void {
        self.shader.deinit();
    }

    pub fn initialize(self: *@This(), data: anytype) void {
        self.postprocessor = .{ .process = process };
        self.shader = shaders.createMetaFlamesShader();
        self.shader.frag_uniform.tear_sharpness = 7;
        self.shader.frag_uniform.tear_wave_length = 5;
        self.shader.frag_uniform.tear_wave_speed = 500;
        self.shader.frag_uniform.tear_wave_amplitude = 10;
        self.shader.frag_uniform.iResolution = .{ .x = 785, .y = 577 };
    }

    pub fn process(processor: *aya.gfx.PostProcessor, pass: aya.gfx.OffscreenPass, texture: aya.gfx.Texture) void {
        const self = processor.getParent(@This());
        processor.blit(pass, texture, &self.shader.shader);
    }

    pub fn setTone(self: *@This(), tone: aya.math.Vec3) void {
        self.shader.frag_uniform.sepia_tone = tone;
    }
};

var post_process = true;
var tex: aya.gfx.Texture = undefined;
var stack: aya.gfx.PostProcessStack = undefined;
var flames_params: shaders.MetaFlamesParams = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .window = .{
            .width = 785,
            .height = 577,
        },
    });
}

fn init() !void {
    tex = aya.gfx.Texture.initFromFile("examples/assets/textures/flames_scene.png", .nearest) catch unreachable;

    stack = aya.gfx.createPostProcessStack();
    _ = stack.add(effects.Vignette, {});
    _ = stack.add(Flames, {});
}

fn shutdown() !void {
    tex.deinit();
    stack.deinit();
}

fn update() !void {
    if (aya.renderkit.current_renderer != .opengl) return;

    _ = igCheckbox("Enable PostProcessing", &post_process);

    var flames = stack.processors.items[1].getParent(Flames);
    flames.shader.frag_uniform.iTime = aya.time.seconds();

    flames_params = flames.shader.frag_uniform;
    if (aya.utils.inspect(shaders.MetaFlamesParams, "Flames", &flames_params)) {
        flames.shader.frag_uniform = flames_params;
    }
}

fn render() !void {
    aya.gfx.beginPass(.{});
    aya.draw.texScale(tex, 0, 0, 1);
    aya.gfx.endPass();

    if (post_process) aya.gfx.postProcess(&stack);
}
