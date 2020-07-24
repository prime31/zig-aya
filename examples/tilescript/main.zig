const std = @import("std");
const aya = @import("aya");
const sdl = @import("sdl");
const imgui = @import("imgui");
const TileScript = @import("tilescript.zig").TileScript;

var tk: TileScript = undefined;

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
            .title = "TileScript",
        },
    });
    sdl.SDL_DelEventWatch(onSdlEvent, null);
}

fn init() void {
    tk = TileScript.init();
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

    // stall whenever we dont have events so that we render as little as possible
    var evt: sdl.SDL_Event = undefined;
    if (sdl.SDL_WaitEventTimeout(&evt, if (aya.window.focused) 50 else 5000) == 1) {
        _ = sdl.SDL_PushEvent(&evt);
    }
    aya.time.resync();
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
