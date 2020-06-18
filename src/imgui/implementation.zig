const std = @import("std");
const imgui = @import("../deps/imgui/imgui.zig");
const aya = @import("../aya.zig");
const sdl = aya.sdl;
const fna = aya.fna;

const Renderer = @import("renderer.zig").Renderer;
const Events = @import("events.zig").Events;

var state = struct {
    renderer: Renderer = undefined,
    events: Events = undefined,
}{};

// public methods
pub fn init(device: *fna.Device, window: *sdl.SDL_Window) void {
    state.renderer = Renderer.init();
    state.events = Events.init();
}

pub fn newFrame() void {
    var w: i32 = undefined;
    var h: i32 = undefined;
    aya.window.drawableSize(&w, &h);
    state.events.newFrame(aya.window.sdl_window, w, h);
    imgui.igNewFrame();
}

pub fn render() void {
    state.renderer.render();
}

pub fn handleEvent(event: *sdl.SDL_Event) bool {
    return state.events.handleEvent(event);
}
