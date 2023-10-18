const std = @import("std");
const aya = @import("aya");

pub const Bootstrap = aya.Bootstrap;

const App = aya.App;
const Res = aya.Res;
const EventReader = aya.EventReader;

const Input = aya.Input;
const Axis = aya.Axis;
const Gamepads = aya.Gamepads;
const GamepadConnectionEvent = aya.GamepadConnectionEvent;

pub fn run(app: *App) void {
    std.debug.print("\n", .{});

    app.addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, InputSystem)
        .run();
}

const InputSystem = struct {
    pub fn run(status_events: EventReader(GamepadConnectionEvent), gamepads_res: Res(Gamepads)) void {
        var gamepads: *const Gamepads = gamepads_res.get() orelse return;

        for (status_events.read()) |evt| {
            std.debug.print(
                "gamepad: {}, status: {}, name: {?s}\n",
                .{ evt.gamepad, evt.status, gamepads.getGamepad(evt.gamepad).?.getName() },
            );
        }

        while (gamepads.nextGamepad()) |gamepad| {
            // std.debug.print("axis {d:.2}\n", .{gamepad.getAxis(.left_x)});

            while (gamepad.buttons.getNextJustPressed()) |btn| std.debug.print("{} just pressed\n", .{btn});
            while (gamepad.buttons.getNextJustReleased()) |btn| std.debug.print("{} just released\n", .{btn});
        }
    }
};
