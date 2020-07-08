const std = @import("std");
const aya = @import("aya");
const sdl = @import("sdl");
const imgui = @import("imgui");
const TileKit = @import("tilekit.zig").TileKit;

var tk: TileKit = undefined;

pub fn main() !void {
    try aya.run(.{
        .init = init,
        .update = update,
        .render = render,
        .shutdown = shutdown,
        .imgui = true,
        .gfx = .{
            .disable_debug_render = true,
            .resolution_policy = .none,
        },
        .window = .{
            .width = 1024,
            .height = 768,
            .title = "Aya Tile",
        },
    });
    sdl.SDL_DelEventWatch(onSdlEvent, null);
}

fn init() void {
    tk = TileKit.init();
    sdl.SDL_AddEventWatch(onSdlEvent, null);
}

fn update() void {}

fn shutdown() void {
    tk.state.savePrefs();
}

fn render() void {
    tk.draw();

    aya.gfx.beginNullPass();
    aya.gfx.endPass();

    // slow down rendering when we arent active and when a file is not being dragged into the window
    if (!aya.window.focused) {
        aya.time.sleep(200);
    } else if (!imgui.igGetIO().WantCaptureKeyboard and !imgui.igGetIO().WantCaptureMouse) {
        aya.time.sleep(100);
    }
}

fn onSdlEvent(context: ?*c_void, event: *sdl.SDL_Event) callconv(.C) c_int {
    switch (event.type) {
        sdl.SDL_DROPFILE => {
            var file = aya.mem.tmp_allocator.alloc(u8, sdl.SDL_strlen(event.drop.file)) catch unreachable;
            std.mem.copy(u8, file, std.mem.span(event.drop.file));
            tk.handleDroppedFile(file);
            sdl.SDL_free(event.drop.file);
        },
        else => {},
    }
    return 1;
}
