const std = @import("std");
const aya = @import("aya");
usingnamespace @import("imgui");
usingnamespace @import("sokol");

var demo_open: bool = true;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .window = .{
            .width = 1024,
            .height = 768,
        },
    });
}

fn init() void {
    var imgui_desc = std.mem.zeroes(simgui_desc_t);
    imgui_desc.dpi_scale = sapp_dpi_scale();
    imgui_desc.ini_filename = "imgui.ini";
    simgui_setup(&imgui_desc);
}

fn update() void {
    // TODO: wire up an input event
    simgui_new_frame(aya.window.width(), aya.window.height(), 0.017);
    igShowDemoWindow(&demo_open);
}

fn render() void {
    aya.gfx.beginPass(.{});
    aya.gfx.endPass();

    aya.gfx.blitToScreen(aya.math.Color.black);

    aya.gfx.beginPass(.{});
    simgui_render();
    aya.gfx.endPass();
}
