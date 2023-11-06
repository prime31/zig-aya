const std = @import("std");
const aya = @import("aya");
const ig = @import("imgui");

pub fn main() !void {
    std.debug.print("\n", .{});
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
    });
}

fn init() !void {
    aya.audio.start();
}

fn update() !void {
    if (ig.igBegin("Audio Shit", null, ig.ImGuiWindowFlags_None)) {
        defer ig.igEnd();
    }
}

fn render() !void {
    if (aya.input.keyJustPressed(.a)) aya.audio.snd3.start() catch unreachable;
    if (aya.input.keyJustPressed(.b)) aya.audio.snd1.start() catch unreachable;
    if (aya.input.keyJustPressed(.c)) aya.audio.snd2.start() catch unreachable;

    aya.gfx.beginPass(.{});
    aya.gfx.draw.rect(aya.math.Vec2.init(50, 50), 200, 400, aya.math.Color.lime);
    aya.gfx.endPass();
}
