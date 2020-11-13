const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");

const Shader = aya.gfx.Shader;

pub const enable_imgui = true;

var post_process = true;
var tex: aya.gfx.Texture = undefined;
var clouds_tex: aya.gfx.Texture = undefined;
var lines_shader: Shader = undefined;
var noise_shader: Shader = undefined;
var dissolve_pip: Shader = undefined;
var stack: aya.gfx.PostProcessStack = undefined;

var noise = aya.gfx.effects.Noise.Params{
    .time = 0,
    .power = 100,
};

var lines = aya.gfx.effects.Lines.Params{
    .line_size = 4,
    .line_color = .{ .x = 0.9, .y = 0.8, .z = 0.6, .w = 1.0 },
};

var dissolve = aya.gfx.effects.Dissolve.Params{
    .progress = 0,
    .threshold = 0.04,
    .threshold_color = aya.math.Color.orange.asVec4(),
};

var glitch = aya.gfx.PixelGlitch.Params{
    .vertical_size = 1,
    .horizontal_offset = 1,
    .screen_size = .{},
};

const noise_frag: [:0]const u8 =
    \\uniform float time;
    \\uniform float power;
    \\
    \\float rand(vec2 co){
    \\  return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
    \\}
    \\
    \\vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    \\  vec4 color = texture(tex, tex_coord);
    \\  float x = (tex_coord.x + 4) * (tex_coord.y + 4) * (sin(time) * 10);
    \\  vec3 grain = vec3(mod((mod(x, 13) + 1) * (mod(x, 123) + 1), 0.01) - 0.005) * power;
    \\  color.rgb += grain;
    \\  return color;
    \\}
;

const lines_frag: [:0]const u8 =
    \\uniform float line_size;
    \\uniform vec4 line_color;
    \\
    \\vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    \\  float alpha = texture(tex, tex_coord).a;
    \\  vec2 screen_size = vec2(1024.0, 768.0);
    \\  vec2 screen_pos = gl_FragCoord.xy;
    \\
    \\  float flooredAlternate = mod(floor(screen_pos.y / line_size), 2.0);
    \\
    \\  vec4 finalColor = mix(vec4(0, 0, 0, 0), line_color, flooredAlternate);
    \\  return finalColor *= alpha;
    \\}
;

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
    tex = aya.gfx.Texture.initFromFile("assets/sword_dude.png", .nearest) catch unreachable;
    clouds_tex = aya.gfx.Texture.initFromFile("assets/clouds.png", .linear) catch unreachable;
    lines_shader = try Shader.initWithFrag(lines_frag);
    noise_shader = try Shader.initWithFrag(noise_frag);
    // dissolve_pip = aya.gfx.effects.Dissolve.init();

    stack = aya.gfx.createPostProcessStack();
    // _ = stack.add(aya.gfx.PixelGlitch, {});
    // _ = stack.add(aya.gfx.Sepia, {});
    // _ = stack.add(aya.gfx.Vignette, {});
}

fn shutdown() !void {
    tex.deinit();
    clouds_tex.deinit();

    lines_shader.deinit();
    noise_shader.deinit();
    // dissolve_pip.deinit();
    stack.deinit();
}

fn update() !void {
    _ = igCheckbox("Enable PostProcessing", &post_process);

    // _ = aya.utils.inspect("glitch", &glitch);
    // // if (@mod(aya.time.frames(), 5) == 0) {
    // //      glitch.vertical_size = aya.math.rand.range(f32, 1, 5);
    // //      glitch.horizontal_offset = aya.math.rand.range(f32, 1, 10);
    // // }
    // glitch.screen_size = aya.window.sizeVec2();
    // stack.processors.items[0].getParent(aya.gfx.PixelGlitch).setParams(glitch);

    // _ = aya.utils.inspect("dissolve", &dissolve);
    // dissolve.progress = aya.math.pingpong(aya.time.seconds(), 1);
    // dissolve_pip.setFragUniform(0, &dissolve);
}

fn render() !void {
    aya.gfx.beginPass(.{});
    aya.draw.text("Hold space to disable effects", 0, 30, null);
    aya.draw.texScale(tex, 30, 30, 3);

    if (!aya.input.keyDown(.space)) {
        aya.gfx.setShader(lines_shader);
        lines_shader.setUniformName(f32, "line_size", 4);
        lines_shader.setUniformName(aya.math.Vec4, "line_color", .{.x = 1, .y = 0.8, .z = 0.6, .w = 1});
    }
    aya.draw.texScale(tex, 230, 230, 3);

    if (!aya.input.keyDown(.space)) {
        aya.gfx.setShader(noise_shader);
        noise_shader.setUniformName(f32, "power", 100);
        noise_shader.setUniformName(f32, "time", aya.time.seconds());
    }
    aya.draw.texScale(tex, 100, 230, 3);
    aya.gfx.flush();

    if (!aya.input.keyDown(.d)) {
        // aya.gfx.setPipeline(dissolve_pip);
        aya.draw.bindTexture(clouds_tex, 1);
    }
    aya.draw.texScale(tex, 330, 30, 3);

    aya.gfx.endPass();
    aya.draw.unbindTexture(1);

    if (post_process) {
        aya.gfx.postProcess(&stack);
    }
}
