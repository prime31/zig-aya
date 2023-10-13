const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Res = aya.Res;
const EventReader = aya.EventReader;

const Input = aya.Input;
const Axis = aya.Axis;
const Gamepads = aya.Gamepads;
const GamepadButton = aya.GamepadButton;
const GamepadAxis = aya.GamepadAxis;
const GamepadConnectionEvent = aya.GamepadConnectionEvent;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, InputSystem)
        .run();
}

const InputSystem = struct {
    pub fn run(
        status_events: EventReader(GamepadConnectionEvent),
        gamepads_res: Res(aya.Gamepads),
        gamepad_btn_res: Res(Input(GamepadButton)),
        gamepad_axes_res: Res(Axis(GamepadAxis)),
    ) void {
        var gamepads: *const Gamepads = gamepads_res.get() orelse return;
        var buttons: *const Input(GamepadButton) = gamepad_btn_res.get() orelse return;
        var gamepad_axes = gamepad_axes_res.get() orelse return;

        for (status_events.read()) |evt| {
            std.debug.print(
                "gamepad: {}, status: {}, name: {?s}, type: {}\n",
                .{ evt.gamepad, evt.status, gamepads.getName(evt.gamepad), gamepads.getType(evt.gamepad) },
            );
        }

        while (gamepads.nextGamepad()) |pad| {
            const axis = GamepadAxis{ .gamepad = pad, .type = .left_x };
            if (gamepad_axes.get(axis)) |_| {
                // do something with the axis value which will be clamped from -1 to 1
            }

            while (buttons.getNextJustPressed()) |btn| std.debug.print("{} just pressed\n", .{btn});
        }
    }
};
