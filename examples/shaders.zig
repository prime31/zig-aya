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
var dissolve_shader: Shader = undefined;
var stack: aya.gfx.PostProcessStack = undefined;

var lines = struct {
    line_size: f32 = 4,
    line_color: aya.math.Vec4 = .{ .x = 0.9, .y = 0.8, .z = 0.6, .w = 1.0 },
}{};

var noise = struct {
    power: f32 = 100,
}{};

var dissolve = struct {
    threshold: f32 = 0.04,
    threshold_color: aya.math.Vec4 = aya.math.Color.orange.asVec4(),
}{};

var sepia = struct {
    sepia_tone: aya.math.Vec3 = .{ .x = 1.2, .y = 1.0, .z = 0.8 },
}{};

var vignette_param = struct {
    radius: f32 = 1.25,
    power: f32 = 1,
}{};

var glitch = aya.gfx.PixelGlitch.Params{};

const noise_frag: [:0]const u8 =
    \\uniform float time;
    \\uniform float power = 100;
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
    \\uniform float line_size = 4.0;
    \\uniform vec4 line_color = vec4(0.9, 0.8, 0.6, 1.0);
    \\
    \\vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    \\  float alpha = texture(tex, tex_coord).a;
    \\  vec2 screen_pos = gl_FragCoord.xy;
    \\
    \\  float flooredAlternate = mod(floor(screen_pos.y / line_size), 2.0);
    \\
    \\  vec4 finalColor = mix(vec4(0, 0, 0, 0), line_color, flooredAlternate);
    \\  return finalColor *= alpha;
    \\}
;

const dissolve_frag: [:0]const u8 =
    \\uniform float progress; // 0 - 1 where 0 is no change to s0 and 1 will discard all of s0 where dissolve_tex.r < value
    \\uniform float threshold; // 0.04
    \\uniform vec4 threshold_color; // the color that will be used when dissolve_tex is between progress +- threshold
    \\uniform sampler2D dissolve_tex;
    \\
    \\vec4 effect(sampler2D tex, vec2 tex_coord, vec4 vert_color) {
    \\  float _progress = progress + threshold;
    \\  vec4 color = texture(tex, tex_coord);
    \\
    \\  // get dissolve from 0 - 1 where 0 is pure white and 1 is pure black
    \\  float dissolve_amount = 1 - texture(dissolve_tex, tex_coord).r;
    \\
    \\  // when our dissolve.r (dissolve_amount) is less than progress we discard
    \\  if(dissolve_amount < _progress - threshold)
    \\  	discard;
    \\  float tmp = abs(_progress - threshold - dissolve_amount) / threshold;
    \\  float colorAmount = mix(1, 0, 1 - clamp(tmp, 0.0, 1.0));
    \\  vec4 thresholdColor = mix(vec4(0, 0, 0, 1), threshold_color, colorAmount);
    \\  float b = dissolve_amount < _progress ? 1.0 : 0.0;
    \\  return mix(color, color * thresholdColor, b);
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
    dissolve_shader = try Shader.initWithFrag(dissolve_frag);
    dissolve_shader.bind();
    dissolve_shader.setUniformName(i32, "dissolve_tex", 1);

    stack = aya.gfx.createPostProcessStack();
    _ = stack.add(aya.gfx.PixelGlitch, {});
    _ = stack.add(aya.gfx.Sepia, {});
    _ = stack.add(aya.gfx.Vignette, {});
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
    _ = igCheckbox("Enable PostProcessing", &post_process);

    if (aya.utils.inspect("lines", &lines)) {
        lines_shader.bind();
        lines_shader.setUniformName(f32, "line_size", lines.line_size);
        lines_shader.setUniformName(aya.math.Vec4, "line_color", lines.line_color);
    }
    if (aya.utils.inspect("noise", &noise)) {
        noise_shader.bind();
        noise_shader.setUniformName(f32, "power", 100);
    }
    if (aya.utils.inspect("dissolve", &dissolve)) {
        dissolve_shader.bind();
        dissolve_shader.setUniformName(f32, "threshold", dissolve.threshold);
        dissolve_shader.setUniformName(aya.math.Vec4, "threshold_color", dissolve.threshold_color);
    }
    if (aya.utils.inspect("pixel glitch", &glitch)) {
        stack.processors.items[0].getParent(aya.gfx.PixelGlitch).setUniforms(glitch.vertical_size, glitch.horizontal_offset);
    }
    if (aya.utils.inspect("sepia", &sepia)) {
        stack.processors.items[1].getParent(aya.gfx.Sepia).setTone(sepia.sepia_tone);
    }
    if (aya.utils.inspect("vignette", &vignette_param)) {
        stack.processors.items[2].getParent(aya.gfx.Vignette).setUniforms(vignette_param.radius, vignette_param.power);
    }

    if (@mod(aya.time.frames(), 5) == 0) {
         glitch.vertical_size = aya.math.rand.range(f32, 1, 5);
         glitch.horizontal_offset = aya.math.rand.range(f32, -20, 20);
    }
    stack.processors.items[0].getParent(aya.gfx.PixelGlitch).setUniforms(glitch.vertical_size, glitch.horizontal_offset);
}

fn render() !void {
    aya.gfx.beginPass(.{});
    aya.draw.text("Hold space to disable noise/lines effects", 0, 30, null);
    aya.draw.text("Hold d to disable dissolve effect", 00, 50, null);
    aya.draw.texScale(tex, 30, 30, 3);

    if (!aya.input.keyDown(.space)) {
        aya.gfx.setShader(lines_shader);
    }
    aya.draw.texScale(tex, 230, 230, 3);

    if (!aya.input.keyDown(.space)) {
        aya.gfx.setShader(noise_shader);
        noise_shader.setUniformName(f32, "time", aya.time.seconds());
    }
    aya.draw.texScale(tex, 100, 230, 3);
    aya.gfx.flush();

    if (!aya.input.keyDown(.d)) {
        aya.gfx.setShader(dissolve_shader);
        aya.draw.bindTexture(clouds_tex, 1);
        dissolve_shader.setUniformName(f32, "progress", aya.math.pingpong(aya.time.seconds(), 1));
    }
    aya.draw.texScale(tex, 330, 30, 3);

    aya.gfx.endPass();
    aya.draw.unbindTexture(1);

    if (post_process) {
        aya.gfx.postProcess(&stack);
    }
}
