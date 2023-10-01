const std = @import("std");
const aya = @import("aya");

const App = aya.App;
const Res = aya.Res;
const EventReader = aya.EventReader;

const Input = aya.Input;
const MouseWheel = aya.MouseWheel;
const MouseButton = aya.MouseButton;
const Scancode = aya.Scancode;

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystem(.update, InputSystem)
        .run();
}

const InputSystem = struct {
    pub fn run(mouse_buttons_res: Res(Input(MouseButton)), keys_res: Res(Input(Scancode)), wheel: EventReader(MouseWheel)) void {
        var mouse_buttons: *const Input(MouseButton) = mouse_buttons_res.get() orelse return;
        var keys: *const Input(Scancode) = keys_res.get() orelse return;

        if (mouse_buttons.justPressed(.left)) std.debug.print("left mouse just pressed\n", .{});
        if (mouse_buttons.justReleased(.left)) std.debug.print("left mouse just released\n", .{});

        if (mouse_buttons.justPressed(.right)) std.debug.print("right mouse just pressed\n", .{});
        if (mouse_buttons.justReleased(.right)) std.debug.print("right mouse just released\n", .{});

        if (keys.justPressed(.a)) std.debug.print("a just pressed\n", .{});
        if (keys.justReleased(aya.Scancode.a)) std.debug.print("a just released\n", .{});

        if (keys.anyJustPressed(&.{ aya.Scancode.delete, aya.Scancode.backspace }))
            std.debug.print("delete or backspace just pressed\n", .{});

        while (keys.getNextJustPressed()) |key| std.debug.print("{} just pressed\n", .{key});

        for (wheel.get()) |motion| std.debug.print("mouse wheel: {}\n", .{motion});
    }
};
