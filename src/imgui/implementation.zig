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

pub fn deinit() void {
    state.renderer.deinit();
    state.events.deinit();
}

pub fn newFrame() void {
    state.events.newFrame(aya.window.sdl_window);
    imgui.igNewFrame();
}

pub fn render() void {
    state.renderer.render();
}

pub fn handleEvent(event: *sdl.SDL_Event) bool {
    return state.events.handleEvent(event);
}
