const std = @import("std");
const aya = @This();

// types
const Window = @import("window/window.zig").Window;
const WindowConfig = @import("window/window.zig").WindowConfig;
const Debug = @import("render/debug.zig").Debug;
const Time = @import("time.zig").Time;
const Input = @import("input.zig").Input;
const GraphicsContext = @import("render/gfx.zig").GraphicsContext;
const GraphicsConfig = @import("render/gfx.zig").Config;
const Resources = @import("app/resources.zig").Resources;
const ScratchAllocator = @import("mem/scratch_allocator.zig").ScratchAllocator;
const Events = @import("app/event.zig").Events;

// exports for easy access
pub const utils = @import("utils.zig");
pub const trait = @import("trait.zig");
pub const fs = @import("fs.zig");
pub const rk = @import("renderkit");
pub const ig = @import("imgui");
pub const sdl = @import("sdl");
pub const mem = @import("mem/mem.zig");

// inner modules
// TODO: be more restrictive with exports and possibly dump them into sub-structs per module
pub usingnamespace @import("app/mod.zig");
pub usingnamespace @import("window/mod.zig");
pub usingnamespace @import("math/mod.zig");
pub usingnamespace @import("render/mod.zig");

// essentially our fields, just made globals for ease of access
pub var window: Window = undefined;
pub var debug: Debug = undefined;
pub var time: Time = undefined;
pub var input: Input = undefined;
pub var gfx: GraphicsContext = undefined;
pub var res: Resources = undefined;

var event_writers: WindowAndInputEventWriters = undefined;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub var allocator = gpa.allocator();

// temp allocator is a ring buffer so memory doesnt need to be freed
pub var tmp_allocator: std.mem.Allocator = undefined;
var tmp_allocator_instance: ScratchAllocator = undefined;

pub const Config = struct {
    init: ?fn () anyerror!void = null,
    update: ?fn () anyerror!void = null,
    render: fn () anyerror!void,
    shutdown: ?fn () anyerror!void = null,
    onFileDropped: ?fn ([:0]const u8) void = null,

    gfx: GraphicsConfig = .{},
    window: WindowConfig = .{},

    update_rate: f64 = 60, // desired fps
    imgui_icon_font: bool = true,
    imgui_viewports: bool = true, // whether imgui viewports should be enabled
    imgui_docking: bool = true, // whether imgui docking should be enabled
};

fn init() void {
    tmp_allocator_instance = ScratchAllocator.init(allocator);
    tmp_allocator = tmp_allocator_instance.allocator();

    window = Window.init(.{});
    debug = Debug.init();
    time = Time.init(60);
    input = Input.init();
    gfx = GraphicsContext.init();
    res = Resources.init();
    event_writers = WindowAndInputEventWriters.init();
}

fn deinit() void {
    window.deinit();
    debug.deinit();
    input.deinit();
    gfx.deinit();
    res.deinit();

    rk.shutdown();
}

pub fn run(comptime config: Config) !void {
    init();

    if (config.init) |initFn| try initFn();

    while (!pollEvents(config.onFileDropped)) {
        ig.sdl.newFrame();
        input.newFrame();
        time.tick();
        WindowAndInputEventWriters.update();

        if (config.update) |update| try update();

        gfx.beginFrame();
        try config.render();
        gfx.commitFrame();

        ig.sdl.render(window.sdl_window, window.gl_ctx);
        _ = sdl.SDL_GL_SwapWindow(window.sdl_window);
    }
    if (config.shutdown) |shutdown| try shutdown();

    deinit();
}

pub fn addEvent(comptime T: type) void {
    if (!res.contains(Events(T))) {
        _ = res.initResource(Events(T));
    }
}

fn pollEvents(comptime onFileDropped: ?fn ([:0]const u8) void) bool {
    _ = onFileDropped;
    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) != 0) {
        if (ig.sdl.handleEvent(&event)) continue;

        switch (event.type) {
            sdl.SDL_EVENT_QUIT => return true,
            // window
            sdl.SDL_EVENT_WINDOW_CLOSE_REQUESTED => return true,
            sdl.SDL_EVENT_WINDOW_RESIZED => {
                event_writers.window_resized.send(.{
                    .width = @floatFromInt(event.window.data1),
                    .height = @floatFromInt(event.window.data2),
                });
                gfx.setWindowPixelSize(.{ .w = event.window.data1, .h = event.window.data2 });
            },
            sdl.SDL_EVENT_WINDOW_MOVED => event_writers.window_moved.send(.{
                .x = @floatFromInt(event.window.data1),
                .y = @floatFromInt(event.window.data2),
            }),
            sdl.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => event_writers.window_scale_factor.send(.{
                .scale_factor = sdl.SDL_GetWindowDisplayScale(aya.window.sdl_window),
            }),

            sdl.SDL_EVENT_WINDOW_HIDDEN => std.debug.print("SDL_EVENT_WINDOW_HIDDEN\n", .{}),
            sdl.SDL_EVENT_WINDOW_EXPOSED => std.debug.print("SDL_EVENT_WINDOW_EXPOSED\n", .{}),
            sdl.SDL_EVENT_WINDOW_MINIMIZED => std.debug.print("SDL_EVENT_WINDOW_MINIMIZED\n", .{}),
            sdl.SDL_EVENT_WINDOW_MAXIMIZED => std.debug.print("SDL_EVENT_WINDOW_MAXIMIZED\n", .{}),
            sdl.SDL_EVENT_WINDOW_RESTORED => std.debug.print("SDL_EVENT_WINDOW_RESTORED\n", .{}),
            sdl.SDL_EVENT_WINDOW_MOUSE_ENTER => event_writers.window_mouse_focused.send(.{ .focused = true }),
            sdl.SDL_EVENT_WINDOW_MOUSE_LEAVE => event_writers.window_mouse_focused.send(.{ .focused = false }),
            sdl.SDL_EVENT_WINDOW_FOCUS_GAINED => {
                event_writers.window_focus_changed.send(.{ .focused = true });
                aya.window.focused = true;
            },
            sdl.SDL_EVENT_WINDOW_FOCUS_LOST => {
                event_writers.window_focus_changed.send(.{ .focused = false });
                aya.window.focused = false;
            },
            sdl.SDL_EVENT_WINDOW_TAKE_FOCUS => std.debug.print("SDL_EVENT_WINDOW_TAKE_FOCUS\n", .{}),
            sdl.SDL_EVENT_WINDOW_HIT_TEST => std.debug.print("SDL_EVENT_WINDOW_HIT_TEST\n", .{}),
            sdl.SDL_EVENT_WINDOW_DISPLAY_CHANGED => std.debug.print("SDL_EVENT_WINDOW_DISPLAY_CHANGED\n", .{}),

            // keyboard
            sdl.SDL_EVENT_KEY_DOWN, sdl.SDL_EVENT_KEY_UP => {
                if (event.key.state == 0) {
                    aya.input.keys.release(@enumFromInt(event.key.keysym.scancode));
                } else {
                    aya.input.keys.press(@enumFromInt(event.key.keysym.scancode));
                }
            },
            // mouse
            sdl.SDL_EVENT_MOUSE_BUTTON_DOWN, sdl.SDL_EVENT_MOUSE_BUTTON_UP => {
                if (event.button.state == 0) {
                    aya.input.mouse.buttons.release(@enumFromInt(event.button.button));
                } else {
                    aya.input.mouse.buttons.press(@enumFromInt(event.button.button));
                }
            },
            sdl.SDL_EVENT_MOUSE_MOTION => {
                event_writers.mouse_motion.send(.{
                    .x = event.motion.x,
                    .y = event.motion.y,
                    .xrel = event.motion.xrel,
                    .yrel = event.motion.yrel,
                });
                aya.input.mouse.pos = aya.Vec2.init(event.motion.x, event.motion.y);
            },
            sdl.SDL_EVENT_MOUSE_WHEEL => {
                event_writers.mouse_wheel.send(.{
                    .x = event.wheel.x,
                    .y = event.wheel.y,
                    .direction = @enumFromInt(event.wheel.direction),
                });
                aya.input.mouse.wheel_x = event.wheel.x;
                aya.input.mouse.wheel_y = event.wheel.y;
            },
            // gamepads
            sdl.SDL_EVENT_GAMEPAD_ADDED => {
                aya.input.gamepads.register(event.gdevice.which);
                event_writers.gamepad_connected.send(.{ .gamepad_id = event.gdevice.which, .status = .connected });
            },
            sdl.SDL_EVENT_GAMEPAD_REMOVED => {
                aya.input.gamepads.deregister(event.gdevice.which);
                event_writers.gamepad_connected.send(.{ .gamepad_id = event.gdevice.which, .status = .disconnected });
            },
            sdl.SDL_EVENT_GAMEPAD_AXIS_MOTION => {
                const gamepad = aya.input.gamepads.get(event.gaxis.which) orelse continue;
                gamepad.axes.put(@enumFromInt(event.gaxis.axis), @as(f32, @floatFromInt(event.gaxis.value)) / @as(f32, std.math.maxInt(i16)));
            },
            sdl.SDL_EVENT_GAMEPAD_BUTTON_DOWN => {
                const gamepad = aya.input.gamepads.get(event.gaxis.which) orelse continue;
                gamepad.buttons.press(@enumFromInt(event.gbutton.button));
            },
            sdl.SDL_EVENT_GAMEPAD_BUTTON_UP => {
                const gamepad = aya.input.gamepads.get(event.gaxis.which) orelse continue;
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

    return false;
}

const WindowAndInputEventWriters = struct {
    const EventReader = aya.EventReader;
    const EventWriter = aya.EventWriter;

    const WindowResized = aya.WindowResized;
    const WindowMoved = aya.WindowMoved;
    const WindowFocused = aya.WindowFocused;
    const WindowScaleFactorChanged = aya.WindowScaleFactorChanged;
    const WindowMouseFocused = aya.WindowMouseFocused;

    const MouseWheel = aya.MouseWheel;
    const MouseMotion = aya.MouseMotion;
    const MouseButton = aya.MouseButton;

    const GamePads = aya.Gamepads;
    const GamepadConnectionEvent = aya.GamepadConnectionEvent;

    window_resized: EventWriter(WindowResized),
    window_moved: EventWriter(WindowMoved),
    window_scale_factor: EventWriter(WindowScaleFactorChanged),
    window_focus_changed: EventWriter(WindowFocused),
    window_mouse_focused: EventWriter(WindowMouseFocused),

    mouse_wheel: EventWriter(MouseWheel),
    mouse_motion: EventWriter(MouseMotion),

    gamepad_connected: EventWriter(GamepadConnectionEvent),

    fn init() WindowAndInputEventWriters {
        var self: WindowAndInputEventWriters = undefined;

        inline for (std.meta.fields(WindowAndInputEventWriters)) |field| {
            aya.addEvent(field.type.event_type);
            @field(self, field.name) = getEventWriter(field.type.event_type);
        }
        return self;
    }

    fn getEventWriter(comptime T: type) EventWriter(T) {
        return EventWriter(T){
            .events = aya.res.get(Events(T)) orelse @panic("no EventWriter found for " ++ @typeName(T)),
        };
    }

    fn update() void {
        inline for (std.meta.fields(WindowAndInputEventWriters)) |field| {
            aya.res.get(Events(field.type.event_type)).?.update();
        }
    }
};
