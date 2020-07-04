const std = @import("std");
const aya = @import("aya");
const sdl = @import("sdl");
const imgui = @import("imgui");
const TileKit = @import("tilekit.zig").TileKit;

var tk: TileKit = undefined;
var drag_in_progress = false;

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
    sdl.SDL_DelEventWatch(onSdlEvent, null);
}

fn init() void {
    tk = TileKit.init();
    sdl.SDL_AddEventWatch(onSdlEvent, null);
}

fn update() void {}

fn render() void {
    tk.draw();

    aya.gfx.beginNullPass();
    aya.gfx.endPass();

    // slow down rendering when we arent active and when a file is not being dragged into the window
    if (!drag_in_progress and !true) {
        if (!aya.window.focused) {
            aya.time.sleep(1000);
        } else if (!imgui.igGetIO().WantCaptureKeyboard and !imgui.igGetIO().WantCaptureMouse) {
            aya.time.sleep(100);
        }
    }
}

fn onSdlEvent(context: ?*c_void, event: *sdl.SDL_Event) callconv(.C) c_int {
    switch (event.type) {
        sdl.SDL_DROPBEGIN => {
            drag_in_progress = true;
            std.debug.print("bgin\n", .{});
        },
        sdl.SDL_DROPCOMPLETE => {
            drag_in_progress = false;
            std.debug.print("end\n", .{});
        },
        sdl.SDL_DROPFILE => {
            std.debug.print("SDL_DropEvent: {s}\n", .{event.drop.file});
        },
        else => {},
    }
    return 1;
}
