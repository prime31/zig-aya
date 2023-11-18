const std = @import("std");
const shaders = @import("shaders");
const aya = @import("aya");
const ig = aya.ig;

const OffscreenPass = aya.render.OffscreenPass;
const Texture = aya.render.Texture;
const Color = aya.math.Color;
const Shader = aya.render.Shader;

const Vec2 = aya.math.Vec2;
const Mat32 = aya.math.Mat32;

const num_cascades: i32 = 7;

var tex: Texture = undefined;
var radiance_shader: RadianceShaderState = undefined;
var cascade_shaders: [num_cascades]RadianceShaderState = undefined;
var passes: [2]OffscreenPass = undefined;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .render = render,
        .update = update,
        .shutdown = shutdown,
    });
}

fn init() !void {
    tex = Texture.initFromFile("examples/assets/flatland-2d-demo.png", .nearest);
    radiance_shader = RadianceShaderState.init(.{
        .vert = "examples/assets/shaders/radiance_vs.glsl",
        .frag = "examples/assets/shaders/radiance_fs.glsl",
        .onPostBind = RadianceShaderState.onPostBind,
    });

    // set cascade uniforms
    for (0..num_cascades) |i| {
        cascade_shaders[i] = radiance_shader.clone();
        cascade_shaders[i].frag_uniform.ci = @floatFromInt(i);
        cascade_shaders[i].frag_uniform.add_sky_light = 1;
    }

    // set render uniforms
    radiance_shader.frag_uniform.ci = 0;
    radiance_shader.frag_uniform.should_do_render = 1;

    const size = aya.window.sizeInPixels();
    const d0: f32 = 1; // distance between probes in cascade 0
    const r0 = 4; // number of rays in cascade 0
    const n0: i32 = @intFromFloat(@floor(2 * @floatFromInt(size.w) / d0)); // number of probes in cascade 0 per dimension
    const pass_w = r0 * n0;
    const pass_h = n0;

    passes[0] = OffscreenPass.init(pass_w, pass_h);
    passes[1] = OffscreenPass.init(pass_w, pass_h);
}

fn update() !void {}

fn render() !void {
    // clear
    aya.gfx.beginPass(.{ .pass = passes[@mod(num_cascades - 1, 2)] });
    aya.gfx.endPass();

    // build cascades
    var i: usize = num_cascades - 1;
    while (i >= 0) : (i -= 1) {
        std.debug.print("tex (input): {}, pass: (output) {}\n", .{ @mod(i + 1, 2), @mod(i, 2) });
        cascade_shaders[i].textures[0] = passes[@mod(i + 1, 2)].color_texture;
        aya.gfx.beginPass(.{ .shader = &cascade_shaders[i].shader, .pass = passes[@mod(i, 2)] });
        aya.gfx.draw.tex(tex, 0, 0);
        aya.gfx.endPass();

        if (i == 0) break;
    }

    std.debug.print("final renderpass: {}\n\n", .{@mod(i + 1, 2)});
    radiance_shader.textures[0] = passes[@mod(num_cascades, 2)].color_texture;
    aya.gfx.beginPass(.{ .shader = &radiance_shader.shader });
    aya.gfx.draw.tex(tex, 0, 0);
    aya.gfx.endPass();
}

fn shutdown() !void {
    tex.deinit();
    radiance_shader.deinit();
    for (cascade_shaders) |shd| shd.deinit();
    for (passes) |pass| pass.deinit();
}

pub const RadianceShaderState = aya.render.ShaderState(RadianceParams);

pub const RadianceParams = extern struct {
    pub const metadata = .{
        .images = .{ "main_tex", "u_prev" },
        .uniforms = .{ .RadianceParams = .{ .type = .float4, .array_count = 3 } },
    };

    d0: f32 = 1, // distance between probes in cascade 0
    ro: f32 = 4, // number of rays in cascade 0
    n0: f32 = @floor(2.0 * 1024.0 / 1.0), // number of probes in cascade 0 (per dimension)
    ci: f32 = 0, // cascade number

    cn: f32 = num_cascades, // total number of cascades
    should_do_render: f32 = 0, // we switch on this to render instead of building the cascades
    add_sky_light: f32 = 0, // set to 1 to add sky lighting to uppermost cascade
    padding: f32 = 0,

    u_resolution: Vec2 = .{ .x = 1024, .y = 768 }, // resolution of the input texture
    padding4: Vec2 = .{},
};
