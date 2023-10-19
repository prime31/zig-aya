const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Res = aya.Res;
const EventReader = aya.EventReader;

const Input = aya.Input;
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
    pub fn run(status_events: EventReader(GamepadConnectionEvent), gamepads_res: Res(aya.Gamepads)) void {
        var gamepads: *const Gamepads = gamepads_res.get() orelse return;

        for (status_events.read()) |evt| {
            const gamepad = gamepads.get(evt.gamepad_id).?;
            std.debug.print(
                "gamepad: {}, status: {}, name: {?s}, type: {}\n",
                .{ evt.gamepad_id, evt.status, gamepad.getName(), gamepad.getType() },
            );
            std.debug.print(
                "rumble: {}, trigger rumble: {}\n",
                .{ gamepad.hasRumble(), gamepad.hasRumbleTriggers() },
            );
        }

        while (gamepads.nextGamepad()) |pad| {
            if (@abs(pad.getAxis(.left_x)) > 0.1) std.debug.print("left x: {d:.2}\n", .{pad.getAxis(.left_x)});
            if (pad.getAxis(.right_trigger) > 0.1) std.debug.print("right trigger: {d:.2}\n", .{pad.getAxis(.right_trigger)});

            while (pad.buttons.getNextJustPressed()) |btn| std.debug.print("{} just pressed\n", .{btn});
            while (pad.buttons.getNextJustReleased()) |btn| std.debug.print("{} just released\n", .{btn});

            if (pad.buttons.pressed(.d_pad_down))
                pad.rumble(0.5, 0.8, 10);
        }
    }
};
