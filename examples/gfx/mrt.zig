const std = @import("std");
const shaders = @import("shaders");
const aya = @import("aya");
const ig = aya.ig;

const Texture = aya.render.Texture;
const Color = aya.math.Color;
const Shader = aya.render.Shader;
const OffscreenPass = aya.render.OffscreenPass;
const ColorAttachmentAction = aya.render.PassConfig.ColorAttachmentAction;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

var tex: Texture = undefined;
var shader: Shader = undefined;
var pass: OffscreenPass = undefined;

fn init() !void {
    tex = Texture.initFromFile("examples/assets/sword_dude.png", .nearest);
    shader = shaders.createMrtShader();
    pass = OffscreenPass.initMrt(200, 200, 2, .nearest, .clamp);
}

fn render() !void {
    aya.gfx.beginPass(.{ .pass = pass, .mrt_colors = .{.{ .color = Color.lime }} ** 3 });
    aya.gfx.setShader(&shader);
    aya.gfx.draw.texScale(tex, 0, 0, 2);
    aya.gfx.endPass();

    // render our render textures
    aya.gfx.beginPass(.{ .color = Color.black });
    aya.gfx.draw.tex(pass.color_texture, 50, 50);
    aya.gfx.draw.tex(pass.color_texture2.?, 350, 50);
    aya.gfx.draw.text("Multiple Render Targets", 5, 20, null);
    aya.gfx.endPass();
}

fn shutdown() !void {
    tex.deinit();
    shader.deinit();
    pass.deinit();
}
