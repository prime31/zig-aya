const std = @import("std");
const sdl = @import("sdl");
const aya = @import("../aya.zig");
const ig = @import("imgui");
const zgpu = @import("zgpu");

const App = aya.App;
const Window = aya.Window;
const Events = aya.Events;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

const WindowResized = aya.WindowResized;
const WindowMoved = aya.WindowMoved;
const WindowFocused = aya.WindowFocused;
const WindowScaleFactorChanged = aya.WindowScaleFactorChanged;
const WindowMouseFocused = aya.WindowMouseFocused;

const Input = aya.Input;
const Axis = aya.Axis;
const Scancode = aya.Scancode;

const MouseWheel = aya.MouseWheel;
const MouseMotion = aya.MouseMotion;
const MouseButton = aya.MouseButton;

const GamePads = aya.Gamepads;
const GamepadConnectionEvent = aya.GamepadConnectionEvent;

const WindowAndInputEventWriters = struct {
    window_resized: EventWriter(WindowResized),
    window_moved: EventWriter(WindowMoved),
    window_scale_factor: EventWriter(WindowScaleFactorChanged),
    window_focus_changed: EventWriter(WindowFocused),
    window_mouse_focused: EventWriter(WindowMouseFocused),

    mouse_wheel: EventWriter(MouseWheel),
    mouse_motion: EventWriter(MouseMotion),

    gamepad_connected: EventWriter(GamepadConnectionEvent),

    pub fn init(app: *App) WindowAndInputEventWriters {
        var self: WindowAndInputEventWriters = undefined;

        inline for (std.meta.fields(WindowAndInputEventWriters)) |field| {
            @field(self, field.name) = getEventWriter(field.type.event_type, app);
        }
        return self;
    }

    fn getEventWriter(comptime T: type, app: *App) EventWriter(T) {
        return EventWriter(T){
            .events = app.world.getResourceMut(Events(T)) orelse @panic("no EventWriter found for " ++ @typeName(T)),
        };
    }
};

pub fn eventLoop(app: *App) void {
    const window = app.world.getResource(Window).?;
    const gctx = app.world.getResourceMut(zgpu.GraphicsContext).?;

    const mouse_buttons = app.world.getResourceMut(Input(MouseButton)).?;
    const keys: *Input(Scancode) = app.world.getResourceMut(Input(Scancode)).?;
    const gamepads: *GamePads = app.world.getResourceMut(GamePads).?;

    const exit_event_reader = EventReader(aya.AppExitEvent){
        .events = app.world.getResourceMut(Events(aya.AppExitEvent)) orelse @panic("no EventReader found for " ++ @typeName(aya.AppExitEvent)),
    };

    const event_writers = WindowAndInputEventWriters.init(app);

    blk: while (true) {
        if (exit_event_reader.read().len > 0) break :blk;

        mouse_buttons.clear();
        keys.clear();
        gamepads.update();

        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (ig.sdl.handleEvent(&event)) continue;

            switch (event.type) {
                sdl.SDL_EVENT_QUIT => break :blk,
                // window
                sdl.SDL_EVENT_WINDOW_CLOSE_REQUESTED => break :blk,
                sdl.SDL_EVENT_WINDOW_RESIZED => event_writers.window_resized.send(.{
                    .width = @floatFromInt(event.window.data1),
                    .height = @floatFromInt(event.window.data2),
                }),
                sdl.SDL_EVENT_WINDOW_MOVED => event_writers.window_moved.send(.{
                    .x = @floatFromInt(event.window.data1),
                    .y = @floatFromInt(event.window.data2),
                }),
                sdl.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => event_writers.window_scale_factor.send(.{
                    .scale_factor = sdl.SDL_GetWindowDisplayScale(window.sdl_window),
                }),

                sdl.SDL_EVENT_WINDOW_HIDDEN => std.debug.print("SDL_EVENT_WINDOW_HIDDEN\n", .{}),
                sdl.SDL_EVENT_WINDOW_EXPOSED => std.debug.print("SDL_EVENT_WINDOW_EXPOSED\n", .{}),
                sdl.SDL_EVENT_WINDOW_MINIMIZED => std.debug.print("SDL_EVENT_WINDOW_MINIMIZED\n", .{}),
                sdl.SDL_EVENT_WINDOW_MAXIMIZED => std.debug.print("SDL_EVENT_WINDOW_MAXIMIZED\n", .{}),
                sdl.SDL_EVENT_WINDOW_RESTORED => std.debug.print("SDL_EVENT_WINDOW_RESTORED\n", .{}),
                sdl.SDL_EVENT_WINDOW_MOUSE_ENTER => event_writers.window_mouse_focused.send(.{ .focused = true }),
                sdl.SDL_EVENT_WINDOW_MOUSE_LEAVE => event_writers.window_mouse_focused.send(.{ .focused = false }),
                sdl.SDL_EVENT_WINDOW_FOCUS_GAINED => event_writers.window_focus_changed.send(.{ .focused = true }),
                sdl.SDL_EVENT_WINDOW_FOCUS_LOST => event_writers.window_focus_changed.send(.{ .focused = false }),
                sdl.SDL_EVENT_WINDOW_TAKE_FOCUS => std.debug.print("SDL_EVENT_WINDOW_TAKE_FOCUS\n", .{}),
                sdl.SDL_EVENT_WINDOW_HIT_TEST => std.debug.print("SDL_EVENT_WINDOW_HIT_TEST\n", .{}),
                sdl.SDL_EVENT_WINDOW_DISPLAY_CHANGED => std.debug.print("SDL_EVENT_WINDOW_DISPLAY_CHANGED\n", .{}),

                // keyboard
                sdl.SDL_EVENT_KEY_DOWN, sdl.SDL_EVENT_KEY_UP => {
                    if (event.key.state == 0) {
                        keys.release(@enumFromInt(event.key.keysym.scancode));
                    } else {
                        keys.press(@enumFromInt(event.key.keysym.scancode));
                    }
                },
                // mouse
                sdl.SDL_EVENT_MOUSE_BUTTON_DOWN, sdl.SDL_EVENT_MOUSE_BUTTON_UP => {
                    if (event.button.state == 0) {
                        mouse_buttons.release(@enumFromInt(event.button.button));
                    } else {
                        mouse_buttons.press(@enumFromInt(event.button.button));
                    }
                },
                sdl.SDL_EVENT_MOUSE_MOTION => {
                    event_writers.mouse_motion.send(.{
                        .x = event.motion.x,
                        .y = event.motion.y,
                        .xrel = event.motion.xrel,
                        .yrel = event.motion.yrel,
                    });
                },
                sdl.SDL_EVENT_MOUSE_WHEEL => event_writers.mouse_wheel.send(.{
                    .x = event.wheel.x,
                    .y = event.wheel.y,
                    .direction = @enumFromInt(event.wheel.direction),
                }),
                // gamepads
                sdl.SDL_EVENT_GAMEPAD_ADDED => {
                    gamepads.register(event.gdevice.which);
                    event_writers.gamepad_connected.send(.{ .gamepad_id = event.gdevice.which, .status = .connected });
                },
                sdl.SDL_EVENT_GAMEPAD_REMOVED => {
                    gamepads.deregister(event.gdevice.which);
                    event_writers.gamepad_connected.send(.{ .gamepad_id = event.gdevice.which, .status = .disconnected });
                },
                sdl.SDL_EVENT_GAMEPAD_AXIS_MOTION => {
                    const gamepad = gamepads.get(event.gaxis.which) orelse continue;
                    gamepad.axes.put(@enumFromInt(event.gaxis.axis), @as(f32, @floatFromInt(event.gaxis.value)) / @as(f32, std.math.maxInt(i16)));
                },
                sdl.SDL_EVENT_GAMEPAD_BUTTON_DOWN => {
                    const gamepad = gamepads.get(event.gaxis.which) orelse continue;
                    gamepad.buttons.press(@enumFromInt(event.gbutton.button));
                },
                sdl.SDL_EVENT_GAMEPAD_BUTTON_UP => {
                    const gamepad = gamepads.get(event.gaxis.which) orelse continue;
                    gamepad.buttons.release(@enumFromInt(event.gbutton.button));
                },
                sdl.SDL_EVENT_GAMEPAD_REMAPPED => std.debug.print("GAMEPAD REMAPPED\n", .{}),
                sdl.SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN => std.debug.print("GAMEPAD TOUCHPAD_DOWN\n", .{}),
                sdl.SDL_EVENT_GAMEPAD_TOUCHPAD_UP => std.debug.print("GAMEPAD TOUCHPAD_UP\n", .{}),
                sdl.SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION => std.debug.print("GAMEPAD TOUCHPAD_MOTION\n", .{}),
                sdl.SDL_EVENT_GAMEPAD_SENSOR_UPDATE => std.debug.print("GAMEPAD SENSOR_UPDATE\n", .{}),
                else => {},
            }
        }

        ig.sdl.newFrame();
        ig.igShowDemoWindow(null);

        app.world.progress(0);

        ig.sdl.draw(gctx, zgpu);
        _ = gctx.present();
    }

    ig.sdl.shutdown();

    if (app.world.getResource(Window)) |win| sdl.SDL_DestroyWindow(win.sdl_window);
    sdl.SDL_Quit();
}
