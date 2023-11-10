const std = @import("std");
const aya = @This();

// libs
pub const rk = @import("renderkit");
pub const ig = @import("imgui");
pub const sdl = @import("sdl");

// types
const WindowConfig = @import("window.zig").WindowConfig;
const ImGuiConfig = ig.sdl.Config;

const Events = @import("events/events.zig").Events;

const Debug = @import("render/debug.zig").Debug;
const GraphicsContext = @import("render/graphics_context.zig").GraphicsContext;
const GraphicsConfig = @import("render/graphics_context.zig").Config;
const Resources = @import("resources.zig").Resources;

// exports for easy access
pub const audio = @import("audio/mod.zig");
pub const evt = @import("events/mod.zig");
pub const fs = @import("fs.zig");
pub const gamepad = @import("input/gamepad.zig");
pub const math = @import("math/mod.zig");
pub const mem = @import("mem/mem.zig");
pub const mouse = @import("input/mouse.zig");
pub const kb = @import("input/keyboard.zig");
pub const render = @import("render/mod.zig");
pub const time = @import("time.zig");
pub const utils = @import("utils.zig");
pub const window = @import("window.zig");

// essentially our fields, just made globals for ease of access
pub var debug: Debug = undefined;
pub var gfx: GraphicsContext = undefined;
pub var res: Resources = undefined;

const internal = @import("internal.zig");

pub const Config = struct {
    init: ?fn () anyerror!void = null,
    update: ?fn () anyerror!void = null,
    render: fn () anyerror!void,
    shutdown: ?fn () anyerror!void = null,

    gfx: GraphicsConfig = .{},
    window: WindowConfig = .{},
    imgui: ImGuiConfig = .{},

    update_rate: f64 = 60, // desired fps
};

fn init(comptime config: Config) void {
    mem.init();
    res = Resources.init();
    internal.init(); // needs res
    gamepad.init();
    window.init(config.window, config.imgui);
    debug = Debug.init();
    time.init(config.update_rate);
    gfx = GraphicsContext.init(config.gfx); // needs window
    audio.init();
}

fn deinit() void {
    window.deinit();
    debug.deinit();
    gfx.deinit();
    res.deinit();
    gamepad.deinit();

    audio.deinit();
    internal.deinit();
    rk.shutdown();
    mem.deinit(); // must be last so everyone else can deinit!
}

pub fn run(comptime config: Config) !void {
    init(config);

    if (config.init) |initFn| try initFn();

    while (!pollEvents()) {
        ig.sdl.newFrame();
        time.tick();

        if (config.update) |update| try update();

        gfx.beginFrame();
        try config.render();
        gfx.commitFrame();

        ig.sdl.render(window.sdl_window, window.gl_ctx);
        _ = sdl.SDL_GL_SwapWindow(window.sdl_window);

        // these rely on pollEvents so clear them before starting the loop
        internal.event_writers.newFrame();
        mouse.newFrame();
        kb.newFrame();
        gamepad.newFrame();
    }
    if (config.shutdown) |shutdown| try shutdown();

    deinit();
}

pub fn addEvent(comptime T: type) void {
    if (!res.contains(Events(T))) {
        _ = res.initResource(Events(T));
    }
}

pub fn getEventReader(comptime T: type) evt.EventReader(T) {
    return evt.EventReader(T){
        .events = res.get(Events(T)) orelse @panic("no EventWriter found for " ++ @typeName(T)),
    };
}

pub fn getEventWriter(comptime T: type) evt.EventWriter(T) {
    return evt.EventWriter(T){
        .events = res.get(Events(T)) orelse @panic("no EventWriter found for " ++ @typeName(T)),
    };
}

fn pollEvents() bool {
    const event_writers = internal.event_writers;

    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) != 0) {
        if (ig.sdl.handleEvent(&event)) continue;

        switch (event.type) {
            sdl.SDL_EVENT_QUIT => return true,
            // window
            sdl.SDL_EVENT_WINDOW_CLOSE_REQUESTED => return true,
            sdl.SDL_EVENT_WINDOW_RESIZED => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.window_resized.send(.{
                    .width = @floatFromInt(event.window.data1),
                    .height = @floatFromInt(event.window.data2),
                });
                gfx.setWindowPixelSize(.{ .w = event.window.data1, .h = event.window.data2 });
            },
            sdl.SDL_EVENT_WINDOW_MOVED => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.window_moved.send(.{
                    .x = @floatFromInt(event.window.data1),
                    .y = @floatFromInt(event.window.data2),
                });
            },
            sdl.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.window_scale_factor.send(.{
                    .scale_factor = sdl.SDL_GetWindowDisplayScale(aya.window.sdl_window),
                });
            },

            sdl.SDL_EVENT_WINDOW_HIDDEN => std.debug.print("SDL_EVENT_WINDOW_HIDDEN\n", .{}),
            sdl.SDL_EVENT_WINDOW_EXPOSED => std.debug.print("SDL_EVENT_WINDOW_EXPOSED\n", .{}),
            sdl.SDL_EVENT_WINDOW_MINIMIZED => std.debug.print("SDL_EVENT_WINDOW_MINIMIZED\n", .{}),
            sdl.SDL_EVENT_WINDOW_MAXIMIZED => std.debug.print("SDL_EVENT_WINDOW_MAXIMIZED\n", .{}),
            sdl.SDL_EVENT_WINDOW_RESTORED => std.debug.print("SDL_EVENT_WINDOW_RESTORED\n", .{}),
            sdl.SDL_EVENT_WINDOW_MOUSE_ENTER => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.window_mouse_focused.send(.{ .focused = true });
            },
            sdl.SDL_EVENT_WINDOW_MOUSE_LEAVE => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.window_mouse_focused.send(.{ .focused = false });
            },
            sdl.SDL_EVENT_WINDOW_FOCUS_GAINED => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.window_focus_changed.send(.{ .focused = true });
                aya.window.focused = true;
            },
            sdl.SDL_EVENT_WINDOW_FOCUS_LOST => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.window_focus_changed.send(.{ .focused = false });
                aya.window.focused = false;
            },
            sdl.SDL_EVENT_WINDOW_TAKE_FOCUS => std.debug.print("SDL_EVENT_WINDOW_TAKE_FOCUS\n", .{}),
            sdl.SDL_EVENT_WINDOW_HIT_TEST => std.debug.print("SDL_EVENT_WINDOW_HIT_TEST\n", .{}),
            sdl.SDL_EVENT_WINDOW_DISPLAY_CHANGED => std.debug.print("SDL_EVENT_WINDOW_DISPLAY_CHANGED\n", .{}),
            // drop file
            sdl.SDL_EVENT_DROP_FILE => {
                if (event.window.windowID != aya.window.id) continue;
                event_writers.file_dropped.send(.{
                    .file = mem.tmp_allocator.dupe(u8, std.mem.span(event.drop.file)) catch unreachable,
                });
                sdl.SDL_free(event.drop.file);
            },
            // keyboard
            sdl.SDL_EVENT_KEY_DOWN, sdl.SDL_EVENT_KEY_UP => {
                if (event.key.state == 0) {
                    aya.kb.keys.release(@enumFromInt(event.key.keysym.scancode));
                } else {
                    aya.kb.keys.press(@enumFromInt(event.key.keysym.scancode));
                }
            },
            // mouse
            sdl.SDL_EVENT_MOUSE_BUTTON_DOWN, sdl.SDL_EVENT_MOUSE_BUTTON_UP => {
                if (event.button.state == 0) {
                    aya.mouse.buttons.release(@enumFromInt(event.button.button));
                } else {
                    aya.mouse.buttons.press(@enumFromInt(event.button.button));
                }
            },
            sdl.SDL_EVENT_MOUSE_MOTION => {
                if (event.motion.windowID != aya.window.id) continue;
                event_writers.mouse_motion.send(.{
                    .x = event.motion.x,
                    .y = event.motion.y,
                    .xrel = event.motion.xrel,
                    .yrel = event.motion.yrel,
                });
                aya.mouse.pos = aya.math.Vec2.init(event.motion.x, event.motion.y);
            },
            sdl.SDL_EVENT_MOUSE_WHEEL => {
                if (event.wheel.windowID != aya.window.id) continue;
                event_writers.mouse_wheel.send(.{
                    .x = event.wheel.x,
                    .y = event.wheel.y,
                    .direction = @enumFromInt(event.wheel.direction),
                });
                mouse.wheel_x = event.wheel.x;
                mouse.wheel_y = event.wheel.y;
            },
            // gamepads
            sdl.SDL_EVENT_GAMEPAD_ADDED => {
                gamepad.register(event.gdevice.which);
                event_writers.gamepad_connected.send(.{ .gamepad_id = event.gdevice.which, .status = .connected });
            },
            sdl.SDL_EVENT_GAMEPAD_REMOVED => {
                gamepad.deregister(event.gdevice.which);
                event_writers.gamepad_connected.send(.{ .gamepad_id = event.gdevice.which, .status = .disconnected });
            },
            sdl.SDL_EVENT_GAMEPAD_AXIS_MOTION => {
                const gpad = gamepad.get(event.gaxis.which) orelse continue;
                gpad.axes.put(@enumFromInt(event.gaxis.axis), @as(f32, @floatFromInt(event.gaxis.value)) / @as(f32, std.math.maxInt(i16)));
            },
            sdl.SDL_EVENT_GAMEPAD_BUTTON_DOWN => {
                const gpad = gamepad.get(event.gaxis.which) orelse continue;
                gpad.buttons.press(@enumFromInt(event.gbutton.button));
            },
            sdl.SDL_EVENT_GAMEPAD_BUTTON_UP => {
                const gpad = gamepad.get(event.gaxis.which) orelse continue;
                gpad.buttons.release(@enumFromInt(event.gbutton.button));
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
