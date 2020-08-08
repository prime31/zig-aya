const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders");
const Pipeline = aya.gfx.Pipeline;
usingnamespace @import("imgui");

pub const imgui = true;

var tex: aya.gfx.Texture = undefined;
var clouds_tex: aya.gfx.Texture = undefined;
var lines_pip: Pipeline = undefined;
var noise_pip: Pipeline = undefined;
var dissolve_pip: Pipeline = undefined;
var stack: aya.gfx.PostProcessStack = undefined;

pub const NoiseParams = extern struct {
    time: f32,
    power: f32,
};

pub const LinesParams = extern struct {
    line_size: f32,
    line_color: aya.math.Vec4 align(16),
};

pub const DissolveParams = extern struct {
    progress: f32 = 0.5,
    dissolve_threshold: f32 = 0.5,
    dissolve_threshold_color: aya.math.Vec4 align(16),
};

var lines = LinesParams{
    .line_size = 4,
    .line_color = .{ .x = 0.9, .y = 0.8, .z = 0.6, .w = 1.0 },
};

var noise = NoiseParams{
    .time = 0,
    .power = 100,
};

var dissolve = DissolveParams{
    .progress = 0,
    .dissolve_threshold = 0.04,
    .dissolve_threshold_color = aya.math.Color.orange.asVec4(),
};

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
    });
}

fn init() void {
    tex = aya.gfx.Texture.initFromFile("assets/sword_dude.png", .nearest) catch unreachable;
    clouds_tex = aya.gfx.Texture.initFromFile("assets/clouds.png", .linear) catch unreachable;
    lines_pip = Pipeline.init(shaders.lines_shader_desc());
    noise_pip = Pipeline.init(shaders.noise_shader_desc());
    dissolve_pip = Pipeline.init(shaders.dissolve_shader_desc());

    var params = LinesParams{
        .line_size = 4,
        .line_color = .{ .x = 0.9, .y = 0.8, .z = 0.6, .w = 1.0 },
    };
    lines_pip.setFragUniform(0, &params);

    stack = aya.gfx.createPostProcessStack();
    _ = stack.add(aya.gfx.PixelGlitch, {});
    // _ = stack.add(aya.gfx.Sepia, {});
    _ = stack.add(aya.gfx.Vignette, {});
}

fn shutdown() void {
    tex.deinit();
    clouds_tex.deinit();

    lines_pip.deinit();
    noise_pip.deinit();
    dissolve_pip.deinit();
    stack.deinit();
}

fn update() void {
    if (igCollapsingHeaderBoolPtr("lines", null, ImGuiTreeNodeFlags_None)) {
        aya.utils.inspect("lines", &lines);
        lines_pip.setFragUniform(0, &lines);
    }

    if (igCollapsingHeaderBoolPtr("noise", null, ImGuiTreeNodeFlags_None)) {
        noise.time = aya.time.seconds();
        aya.utils.inspect("noise", &noise);
        noise_pip.setFragUniform(0, &noise);
    }

    if (@mod(aya.time.frames(), 5) == 0) {
        var glitch = aya.gfx.PixelGlitch.Params{
            .vertical_size = aya.math.rand.range(f32, 1, 5),
            .horizontal_offset = aya.math.rand.range(f32, 1, 10),
            .screen_size = aya.window.sizeVec2(),
        };
        stack.processors.items[0].getParent(aya.gfx.PixelGlitch).setParams(glitch);
    }

    if (igCollapsingHeaderBoolPtr("dissolve", null, ImGuiTreeNodeFlags_None)) {
        dissolve.progress = aya.math.pingpong(aya.time.seconds(), 1);
        aya.utils.inspect("dissolve", &dissolve);
        dissolve_pip.setFragUniform(0, &dissolve);
    }
}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.draw.text("Hold space to disable effect, p disables post processing", 0, 30, null);
    aya.draw.texScale(tex, 30, 30, 3);

    if (!aya.input.keyDown(.SAPP_KEYCODE_SPACE)) {
        aya.gfx.setPipeline(lines_pip);
    }
    aya.draw.texScale(tex, 230, 230, 3);

    if (!aya.input.keyDown(.SAPP_KEYCODE_SPACE)) {
        aya.gfx.setPipeline(noise_pip);
    }
    aya.draw.texScale(tex, 100, 230, 3);
    aya.gfx.flush();

    if (!aya.input.keyDown(.SAPP_KEYCODE_D)) {
        aya.gfx.setPipeline(dissolve_pip);
        aya.draw.bindTexture(clouds_tex, 1);
    }
    aya.draw.texScale(tex, 330, 30, 3);

    aya.gfx.endPass();
    aya.draw.unbindTexture(1);

    if (!aya.input.keyDown(.SAPP_KEYCODE_P)) {
        aya.gfx.postProcess(&stack);
    }
}
