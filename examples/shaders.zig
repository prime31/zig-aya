const std = @import("std");
const aya = @import("aya");
const shaders = @import("shaders");

var tex: aya.gfx.Texture = undefined;
var lines_pip: aya.gfx.Pipeline = undefined;

pub const Params = extern struct {
    line_size: f32,
    line_color: aya.math.Vec4 align(16),
};

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() void {
    tex = aya.gfx.Texture.initFromFile("assets/sword_dude.png", .nearest) catch unreachable;
    lines_pip = aya.gfx.Pipeline.init(shaders.lines_shader_desc());

    var params = Params{
        .line_size = 4,
        .line_color = .{ .x = 0.9, .y = 0.8, .z = 0.6, .w = 1.0 },
    };
    lines_pip.setFragUniform(0, std.mem.asBytes(&params));
}

fn update() void {
    if (aya.input.keyPressed(.SAPP_KEYCODE_3) or aya.input.keyPressed(.SAPP_KEYCODE_4) or aya.input.keyPressed(.SAPP_KEYCODE_5)) {
        var line_size: f32 = blk: {
            if (aya.input.keyPressed(.SAPP_KEYCODE_3)) break :blk 3;
            if (aya.input.keyPressed(.SAPP_KEYCODE_4)) break :blk 4;
            if (aya.input.keyPressed(.SAPP_KEYCODE_5)) break :blk 5;
            break :blk 3;
        };
        var params = Params{
            .line_size = line_size,
            .line_color = .{ .x = 0.9, .y = 0.8, .z = 0.6, .w = 1.0 },
        };
        lines_pip.setFragUniform(0, std.mem.asBytes(&params));
    }
    if (aya.input.keyPressed(.SAPP_KEYCODE_1)) {

    }
}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.draw.text("Hold space to disable effect", 0, 30, null);
    aya.draw.text("3 - 5 for line thickness", 0, 65, null);
    aya.draw.texScale(tex, 30, 30, 3);

    if (!aya.input.keyDown(.SAPP_KEYCODE_SPACE)) {
        aya.gfx.setPipeline(lines_pip);
    }
    aya.draw.texScale(tex, 230, 230, 3);
    aya.gfx.endPass();
}
