const std = @import("std");
const sdl = @import("sdl");

pub const Input = struct {
    mouse: struct {
        x: f32 = 0,
        y: f32 = 0,
        wheel_y: f32 = 0,
    } = .{},

    pub fn handleEvent(self: *Input, event: *sdl.SDL_Event) void {
        switch (event.type) {
            sdl.SDL_EVENT_MOUSE_MOTION => {
                self.mouse.x = event.motion.xrel;
                self.mouse.y = event.motion.yrel;
            },
            sdl.SDL_EVENT_MOUSE_BUTTON_DOWN, sdl.SDL_EVENT_MOUSE_BUTTON_UP => {},
            sdl.SDL_EVENT_MOUSE_WHEEL => self.mouse.wheel_y = event.wheel.y,
            else => {},
        }
    }
};
