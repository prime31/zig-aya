const std = @import("std");
const aya = @import("aya");
const ig = @import("imgui");

const Texture = aya.render.Texture;
const Color = aya.math.Color;

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .render = render,
        .shutdown = shutdown,
    });
}

var clear_color = Color.aya;
var tex: Texture = undefined;

fn init() !void {
    tex = aya.assets.loadTexture("examples/assets/sword_dude.png", .nearest);
}

fn render() !void {
    if (ig.igBegin("Clear Color Window", null, ig.ImGuiWindowFlags_Modal)) {
        defer ig.igEnd();

        var col = clear_color.asVec4();
        if (ig.igColorPicker4("Clear Color", &col.x, 0, ig.ImGuiColorEditFlags_None)) {
            clear_color = Color.fromVec4(col);
        }
    }

    if (!aya.input.keyPressed(.k)) {
        aya.debug.drawTextFmt("fps: {d:0.4}, dt: {d:0.4}", .{ aya.time.fps(), aya.time.rawDeltaTime() }, .{ .x = 400, .y = 20 }, null);
        aya.debug.drawHollowCircle(.{ .x = 600, .y = 600 }, 30, 4, Color.dark_purple);
    }

    aya.gfx.beginPass(.{ .color = clear_color });
    aya.gfx.draw.text("go fuck yourself", 24, 20, null);
    aya.gfx.draw.rect(aya.math.Vec2.init(50, 50), 200, 400, Color.lime);
    aya.gfx.draw.texScale(tex, 5, 400, 10);
    aya.gfx.endPass();
}

fn shutdown() !void {
    aya.assets.releaseTexture(tex);
}
