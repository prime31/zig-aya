const std = @import("std");
const aya = @import("aya.zig");
const evt = aya.evt;
const win = aya.win;

const Events = @import("events/events.zig").Events;
const EventWriter = evt.EventWriter;

const WindowResized = win.WindowResized;
const WindowMoved = win.WindowMoved;
const WindowFocused = win.WindowFocused;
const WindowScaleFactorChanged = win.WindowScaleFactorChanged;
const WindowMouseFocused = win.WindowMouseFocused;

const FileDropped = evt.FileDropped;

const MouseWheel = win.MouseWheel;
const MouseMotion = win.MouseMotion;
const MouseButton = win.MouseButton;

const GamePads = win.Gamepads;
const GamepadConnectionEvent = win.GamepadConnectionEvent;

pub const EventWriters = struct {
    window_resized: EventWriter(WindowResized),
    window_moved: EventWriter(WindowMoved),
    window_scale_factor: EventWriter(WindowScaleFactorChanged),
    window_focus_changed: EventWriter(WindowFocused),
    window_mouse_focused: EventWriter(WindowMouseFocused),

    file_dropped: EventWriter(FileDropped),

    mouse_wheel: EventWriter(MouseWheel),
    mouse_motion: EventWriter(MouseMotion),

    gamepad_connected: EventWriter(GamepadConnectionEvent),

    pub fn init() EventWriters {
        var self: EventWriters = undefined;

        inline for (std.meta.fields(EventWriters)) |field| {
            aya.addEvent(field.type.event_type);
            @field(self, field.name) = aya.getEventWriter(field.type.event_type);
        }
        return self;
    }

    pub fn newFrame() void {
        inline for (std.meta.fields(EventWriters)) |field| {
            aya.res.get(Events(field.type.event_type)).?.update();
        }
    }
};
