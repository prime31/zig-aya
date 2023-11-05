const std = @import("std");
const aya = @import("aya");
const ig = @import("imgui");

const App = aya.App;
const ResMut = aya.ResMut;
const Res = aya.Res;
const Input = aya.Input;
const Scancode = aya.Scancode;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .render = render,
    });
}

var clear_color = aya.Color.aya;

fn render() !void {
    const tex = aya.Texture.initCheckerTexture(25);
    defer tex.deinit();

    if (ig.igBegin("poop", null, ig.ImGuiWindowFlags_Modal)) {
        defer ig.igEnd();

        var col = clear_color.asVec4();
        if (ig.igColorPicker4("col", &col.x, 0, ig.ImGuiColorEditFlags_None)) {
            clear_color = aya.Color.fromVec4(col);
        }
    }

    if (!aya.input.keyPressed(.k)) {
        aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 400, .y = 20 }, null);
        aya.debug.drawHollowCircle(.{ .x = 600, .y = 600 }, 30, 4, aya.Color.dark_purple);
    }

    aya.gfx.beginPass(.{ .color = clear_color });
    aya.gfx.draw.text("go fuck yourself", 24, 20, null);
    aya.gfx.draw.rect(aya.Vec2.init(50, 50), 200, 400, aya.Color.lime);
    aya.gfx.draw.tex(tex, 5, 400);
    aya.gfx.endPass();
}
