const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Res = aya.Res;
const EventReader = aya.EventReader;
const EventWriter = aya.EventWriter;

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
        .addSystem(.update, InputSystem)
        .run();
}

const InputSystem = struct {
    pub fn run(
        status_events: EventReader(GamepadConnectionEvent),
        gamepads_res: Res(Gamepads),
        gamepad_btn_res: Res(Input(GamepadButton)),
    ) void {
        var buttons: *const Input(GamepadButton) = gamepad_btn_res.get() orelse return;
        var gamepads: *const Gamepads = gamepads_res.get() orelse return;

        for (status_events.get()) |evt| {
            std.debug.print(
                "gamepad: {}, status: {}, name: {?s}, type: {}\n",
                .{ evt.gamepad, evt.status, gamepads.getName(evt.gamepad), gamepads.getType(evt.gamepad) },
            );
        }

        while (gamepads.nextGamepad()) |pad| {
            if (buttons.justPressed(.{ .gamepad = pad, .type = .north })) {
                gamepads.rumble(pad, 0.5, 0.5, 5000);
                std.debug.print("north\n", .{});
            }
        }
    }
};
