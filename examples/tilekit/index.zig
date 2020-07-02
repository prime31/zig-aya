const std = @import("std");
const aya = @import("aya");
const imgui = @import("imgui");
const TileKit = @import("tilekit.zig").TileKit;

var tk: TileKit = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .imgui = true,
        .gfx = .{
            .disable_debug_render = true,
            .resolution_policy = .none,
        },
        .window = .{
            .width = 1024,
            .height = 768,
        },
    });
}

fn init() void {
    tk = TileKit.init();
}

fn update() void {}

fn render() void {
    tk.draw();

    aya.gfx.beginNullPass();
    aya.gfx.endPass();

    // slow down rendering when we arent active
    if (!aya.window.focused) {
        aya.time.sleep(1000);
    } else if (!imgui.igGetIO().WantCaptureKeyboard and !imgui.igGetIO().WantCaptureMouse) {
        aya.time.sleep(100);
    }
}
