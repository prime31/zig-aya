const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders");
const Pipeline = aya.gfx.Pipeline;
usingnamespace @import("imgui");

pub const imgui = true;

var post_process = true;
var tex: aya.gfx.Texture = undefined;
var clouds_tex: aya.gfx.Texture = undefined;
var lines_pip: Pipeline = undefined;
var noise_pip: Pipeline = undefined;
var dissolve_pip: Pipeline = undefined;
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

fn init() void {
    tex = aya.gfx.Texture.initFromFile("assets/sword_dude.png", .nearest) catch unreachable;
    clouds_tex =  aya.gfx.Texture.initFromFile("assets/clouds.png", .linear) catch unreachable;
    lines_pip = aya.gfx.effects.Lines.init();
    noise_pip = aya.gfx.effects.Noise.init();
    dissolve_pip = aya.gfx.effects.Dissolve.init();

    var params = aya.gfx.effects.Lines.Params{
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
    _ = igCheckbox("Enable PostProcessing", &post_process);
    if (aya.utils.inspect("lines", &lines)) {
        std.debug.print("wtf: {d}\n", .{lines.line_color});
        lines_pip.setFragUniform(0, &lines);
    }

    _ = aya.utils.inspect("noise", &noise);
    noise.time = aya.time.seconds();
    noise_pip.setFragUniform(0, &noise);

    _ = aya.utils.inspect("glitch", &glitch);
    // if (@mod(aya.time.frames(), 5) == 0) {
    //      glitch.vertical_size = aya.math.rand.range(f32, 1, 5);
    //      glitch.horizontal_offset = aya.math.rand.range(f32, 1, 10);
    // }
    glitch.screen_size = aya.window.sizeVec2();
    stack.processors.items[0].getParent(aya.gfx.PixelGlitch).setParams(glitch);

    _ = aya.utils.inspect("dissolve", &dissolve);
    dissolve.progress = aya.math.pingpong(aya.time.seconds(), 1);
    dissolve_pip.setFragUniform(0, &dissolve);
}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.draw.text("Hold space to disable effects", 0, 30, null);
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

    if (post_process) {
        aya.gfx.postProcess(&stack);
    }
}
