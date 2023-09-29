const std = @import("std");
const sdl = @import("sdl");

const released: u3 = 1; // true only the frame the key is released
const down: u3 = 2; // true the entire time the key is down
const pressed: u3 = 3; // only true if down this frame and not down the previous frame

const Scancode = @import("keyboard.zig").Scancode;

pub const MouseButton = enum(usize) {
    left = 1,
    middle = 2,
    right = 3,
};

pub const Input = struct {
    mouse: Mouse = .{},
    keyboard: Keyboard = .{},

    pub fn handleEvent(self: *Input, event: *sdl.SDL_Event) void {
        switch (event.type) {
            sdl.SDL_EVENT_KEY_DOWN, sdl.SDL_EVENT_KEY_UP => {
                const scancode = event.key.keysym.scancode;
                self.keyboard.dirty_keys.appendAssumeCapacity(scancode);

                if (event.key.state == 0) {
                    self.keyboard.keys[@as(usize, @intCast(scancode))] = released;
                } else {
                    self.keyboard.keys[@as(usize, @intCast(scancode))] = pressed;
                }
            },
            sdl.SDL_EVENT_MOUSE_MOTION => {
                self.mouse.x_rel = event.motion.xrel;
                self.mouse.y_rel = event.motion.yrel;
            },
            sdl.SDL_EVENT_MOUSE_BUTTON_DOWN, sdl.SDL_EVENT_MOUSE_BUTTON_UP => {
                self.mouse.dirty_buttons.appendAssumeCapacity(@as(u2, @intCast(event.button.button)));
                if (event.button.state == 0) {
                    self.mouse.buttons[@as(usize, @intCast(event.button.button))] = released;
                } else {
                    self.mouse.buttons[@as(usize, @intCast(event.button.button))] = pressed;
                }
            },
            sdl.SDL_EVENT_MOUSE_WHEEL => self.mouse.wheel_y = event.wheel.y,
            else => {},
        }
    }

    pub fn newFrame(self: *Input) void {
        if (self.keyboard.dirty_keys.len > 0) {
            for (self.keyboard.dirty_keys.slice()) |key| {
                const ukey = @as(usize, @intCast(key));

                // guard against double key presses
                if (self.keyboard.keys[ukey] > 0)
                    self.keyboard.keys[ukey] -= 1;
            }
            self.keyboard.dirty_keys.resize(0) catch unreachable;
        }

        if (self.mouse.dirty_buttons.len > 0) {
            for (self.mouse.dirty_buttons.slice()) |button| {
                // guard against double mouse presses
                if (self.mouse.buttons[button] > 0)
                    self.mouse.buttons[button] -= 1;
            }

            self.mouse.dirty_buttons.resize(0) catch unreachable;
        }

        self.mouse.x_rel = 0;
        self.mouse.y_rel = 0;
        self.mouse.wheel_y = 0;
    }

    /// only true if down this frame and not down the previous frame
    pub fn keyPressed(self: Input, key: Scancode) bool {
        return self.keyboard.keys[@as(usize, @intCast(@intFromEnum(key)))] == pressed;
    }

    /// true the entire time the key is down
    pub fn keyDown(self: Input, key: Scancode) bool {
        return self.keyboard.keys[@as(usize, @intCast(@intFromEnum(key)))] > released;
    }

    /// true only the frame the key is released
    pub fn keyUp(self: Input, key: Scancode) bool {
        return self.keyboard.keys[@as(usize, @intCast(@intFromEnum(key)))] == released;
    }

    /// only true if down this frame and not down the previous frame
    pub fn mousePressed(self: Input, button: MouseButton) bool {
        return self.mouse.buttons[@intFromEnum(button)] == pressed;
    }

    /// true the entire time the button is down
    pub fn mouseDown(self: Input, button: MouseButton) bool {
        return self.mouse.buttons[@intFromEnum(button)] > released;
    }

    /// true only the frame the button is released
    pub fn mouseUp(self: Input, button: MouseButton) bool {
        return self.mouse.buttons[@intFromEnum(button)] == released;
    }

    pub fn mouseWheel(self: Input) i32 {
        return self.mouse.wheel_y;
    }

    pub fn mousePos(self: Input) struct { x: f32, y: f32 } {
        _ = self;
        var xc: c_int = undefined;
        var yc: c_int = undefined;
        _ = sdl.SDL_GetMouseState(&xc, &yc);
        const window_scale = 1;
        return .{ .x = @as(f32, @floatFromInt(xc * window_scale)), .y = @as(f32, @floatFromInt(yc * window_scale)) };
    }

    pub fn mouseRelMotion(self: Input) struct { x: f32, y: f32 } {
        return .{ .x = @as(f32, @floatFromInt(self.mouse.x_rel)), .y = @as(f32, @floatFromInt(self.mouse.y_rel)) };
    }
};

const Mouse = struct {
    x_rel: f32 = 0,
    y_rel: f32 = 0,
    wheel_y: f32 = 0,

    buttons: [4]u2 = [_]u2{0} ** 4,
    dirty_buttons: std.BoundedArray(u2, 3) = .{},
};

const Keyboard = struct {
    keys: [@as(usize, @intCast(@intFromEnum(Scancode.endcall)))]u2 = [_]u2{0} ** @as(usize, @intCast(@intFromEnum(Scancode.endcall))),
    dirty_keys: std.BoundedArray(u32, 10) = .{},
};
