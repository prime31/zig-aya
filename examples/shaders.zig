const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");
const shaders = @import("assets/shaders/shaders.zig");

pub const renderer: aya.renderkit.Renderer = .opengl;

const Shader = aya.gfx.Shader;
const effects = @import("assets/effects.zig");

pub const enable_imgui = renderer == .opengl;

var post_process = false;
var tex: aya.gfx.Texture = undefined;
var clouds_tex: aya.gfx.Texture = undefined;
var lines_shader: shaders.LinesShader = undefined;
var noise_shader: shaders.NoiseShader = undefined;
var dissolve_shader: shaders.DissolveShader = undefined;
var stack: aya.gfx.PostProcessStack = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .window = .{
            .width = 1024,
            .height = 768,
        },
    });
}

fn init() !void {
    tex = aya.gfx.Texture.initFromFile("examples/assets/textures/sword_dude.png", .nearest) catch unreachable;
    clouds_tex = aya.gfx.Texture.initFromFile("examples/assets/textures/clouds.png", .linear) catch unreachable;

    lines_shader = shaders.createLinesShader();
    lines_shader.frag_uniform.line_color = [_]f32{ 0.9, 0.8, 0.2, 1 };
    lines_shader.frag_uniform.line_size = 4;

    noise_shader = shaders.createNoiseShader();
    noise_shader.frag_uniform.power = 100;

    dissolve_shader = shaders.createDissolveShader();
    dissolve_shader.frag_uniform.threshold = 0.04;
    dissolve_shader.frag_uniform.threshold_color = [_]f32{ 1, 0.6, 0, 1 };

    stack = aya.gfx.createPostProcessStack();
    _ = stack.add(effects.PixelGlitch, {});
    _ = stack.add(effects.Sepia, {});
    _ = stack.add(effects.Vignette, {});
}

fn shutdown() !void {
    tex.deinit();
    clouds_tex.deinit();

    lines_shader.deinit();
    noise_shader.deinit();
    dissolve_shader.deinit();
    stack.deinit();
}

fn update() !void {
    if (aya.renderkit.current_renderer != .opengl) return;

    _ = imgui.igCheckbox("Enable PostProcessing", &post_process);

    var pixel_glitch = stack.processors.items[0].getParent(effects.PixelGlitch);
    _ = stack.processors.items[1].getParent(effects.Sepia);
    _ = stack.processors.items[1].getParent(effects.Vignette);

    // _ = aya.utils.inspect("lines", &lines_shader.frag_uniform);
    // _ = aya.utils.inspect("noise", &noise_shader.frag_uniform);
    // _ = aya.utils.inspect("dissolve", &dissolve_shader.frag_uniform);
    // _ = aya.utils.inspect("pixel glitch", &pixel_glitch.shader.frag_uniform);
    // _ = aya.utils.inspect("sepia", &sepia.shader.frag_uniform);
    // _ = aya.utils.inspect("sepia", &vignette.shader.frag_uniform);

    if (@mod(aya.time.frames(), 5) == 0) {
        pixel_glitch.shader.frag_uniform.vertical_size = aya.math.rand.range(f32, 1, 5);
        pixel_glitch.shader.frag_uniform.horizontal_offset = aya.math.rand.range(f32, -20, 20);
    }
}

fn render() !void {
    aya.gfx.beginPass(.{});
    aya.draw.text("Hold space to disable noise/lines effects", 10, 30, null);
    aya.draw.text("Hold d to disable dissolve effect", 10, 50, null);
    aya.draw.texScale(tex, 30, 30, 3);

    if (!aya.input.keyDown(.space)) {
        aya.gfx.setShader(&lines_shader.shader);
    }
    aya.draw.texScale(tex, 230, 230, 3);

    if (!aya.input.keyDown(.space)) {
        noise_shader.frag_uniform.time = aya.time.seconds();
        aya.gfx.setShader(&noise_shader.shader);
    }
    aya.draw.texScale(tex, 100, 230, 3);
    aya.gfx.flush();

    if (!aya.input.keyDown(.d)) {
        dissolve_shader.frag_uniform.progress = aya.math.pingpong(aya.time.seconds(), 1);
        aya.gfx.setShader(&dissolve_shader.shader);
        aya.draw.bindTexture(clouds_tex, 1);
    }
    aya.draw.texScale(tex, 330, 30, 3);

    aya.gfx.endPass();
    aya.draw.unbindTexture(1);

    if (post_process) aya.gfx.postProcess(&stack);
}
