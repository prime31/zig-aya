const std = @import("std");
const aya = @import("aya.zig");
const core = @import("mach-core");
const zgui = @import("zgui");

const App = aya.App;
const Window = aya.Window;
const Events = aya.Events;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

const WindowResized = aya.WindowResized;
const WindowMoved = aya.WindowMoved;
const WindowFocused = aya.WindowFocused;
const WindowScaleFactorChanged = aya.WindowScaleFactorChanged;

const Input = aya.Input;
const Axis = aya.Axis;
const Scancode = aya.Scancode;

const MouseWheel = aya.MouseWheel;
const MouseMotion = aya.MouseMotion;
const MouseButton = aya.MouseButton;

const GamePads = aya.Gamepads;
const GamepadButton = aya.GamepadButton;
const GamepadButtonType = aya.GamepadButtonType;
const GamepadAxis = aya.GamepadAxis;
const GamepadAxisType = aya.GamepadAxisType;
const GamepadConnectionEvent = aya.GamepadConnectionEvent;

pub const Bootstrap = struct {
    const Self = @This();
    app: *aya.App,

    pub fn init(self: *Bootstrap) !void {
        self.app = aya.App.init();
        try core.init(.{
            .title = "fooking mach imgui",
            .border = true,
            .power_preference = .high_performance,
        });
        zgui.backend.init();
        @import("root").run(self.app);
    }

    pub fn update(self: *Bootstrap) !bool {
        zgui.backend.newFrame();
        zgui.showDemoWindow(null);

        if (handleEvents(self.app)) return true;

        self.app.world.progress(0);

        zgui.backend.draw();
        core.swap_chain.present();

        return false;
    }

    pub fn deinit(self: *Bootstrap) void {
        zgui.backend.deinit();
        self.app.deinit();
        core.deinit();
    }
};

const WindowAndInputEventWriters = struct {
    window_resized: EventWriter(WindowResized),
    window_moved: EventWriter(WindowMoved),
    window_scale_factor: EventWriter(WindowScaleFactorChanged),
    window_focused: EventWriter(WindowFocused),

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

/// handles all events sending them off to the ECS. returns true if a close event was found.
fn handleEvents(app: *aya.App) bool {
    // check for AppExitEvents first
    const exit_event_reader = EventReader(aya.AppExitEvent){
        .events = app.world.getResourceMut(Events(aya.AppExitEvent)) orelse @panic("no EventReader found for " ++ @typeName(aya.AppExitEvent)),
    };
    if (exit_event_reader.read().len > 0) return true;

    const mouse_buttons = app.world.getResourceMut(Input(MouseButton)).?;
    const keys: *Input(core.Key) = app.world.getResourceMut(Input(core.Key)).?;
    const gamepads: *GamePads = app.world.getResourceMut(GamePads).?;
    const gamepad_buttons: *Input(GamepadButton) = app.world.getResourceMut(Input(GamepadButton)).?;
    const gamepad_axes: *Axis(GamepadAxis) = app.world.getResourceMut(Axis(GamepadAxis)).?;
    _ = gamepad_axes;

    const event_writers = WindowAndInputEventWriters.init(app);

    mouse_buttons.clear();
    keys.clear();
    gamepad_buttons.clear();

    var iter = core.pollEvents();
    while (iter.next()) |evt| {
        zgui.backend.passEvent(evt);
        switch (evt) {
            .key_press => |e| keys.press(e.key),
            .key_repeat => {},
            .key_release => |e| keys.release(e.key),
            .char_input => |e| {
                std.debug.print("char_input evt. codepoint: {}\n", .{e.codepoint});
            },
            .mouse_motion => |e| event_writers.mouse_motion.send(.{
                .x = @floatCast(e.pos.x),
                .y = @floatCast(e.pos.y),
            }),
            .mouse_press => |e| mouse_buttons.press(e.button),
            .mouse_release => |e| mouse_buttons.release(e.button),
            .mouse_scroll => |e| event_writers.mouse_wheel.send(.{
                .x = e.xoffset,
                .y = e.yoffset,
            }),
            .joystick_connected => |e| {
                std.debug.print("joystick_connected evt: {}\n", .{e});
                gamepads.register(@intFromEnum(e));
                // gamepads.register(event.gdevice.which);
                // event_writers.gamepad_connected.send(.{ .gamepad = event.gdevice.which, .status = .connected });

                // inline for (std.meta.fields(GamepadAxisType)) |axis_type| {
                //     gamepad_axes.set(.{ .gamepad = event.gdevice.which, .type = @enumFromInt(axis_type.value) }, 0);
                // }
            },
            .joystick_disconnected => |e| {
                std.debug.print("joystick_disconnected evt: {}\n", .{e});
                gamepads.deregister(@intFromEnum(e));
                // gamepads.deregister(event.gdevice.which);
                // event_writers.gamepad_connected.send(.{ .gamepad = event.gdevice.which, .status = .disconnected });

                // inline for (std.meta.fields(GamepadButtonType)) |button_type| {
                //     gamepad_buttons.reset(.{ .gamepad = event.gdevice.which, .type = @enumFromInt(button_type.value) });
                // }

                // inline for (std.meta.fields(GamepadAxisType)) |axis_type| {
                //     gamepad_axes.remove(.{ .gamepad = event.gdevice.which, .type = @enumFromInt(axis_type.value) });
                // }
            },
            .framebuffer_resize => |e| event_writers.window_resized.send(.{
                .width = @floatFromInt(e.width),
                .height = @floatFromInt(e.height),
            }),
            .focus_gained => event_writers.window_focused.send(.{ .focused = true }),
            .focus_lost => event_writers.window_focused.send(.{ .focused = false }),
            .close => return true,
        }
    }

    return false;
}
