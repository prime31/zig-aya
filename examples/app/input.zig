const std = @import("std");
const aya = @import("aya");

pub const Bootstrap = aya.Bootstrap;

const App = aya.App;
const Res = aya.Res;
const EventReader = aya.EventReader;

const Input = aya.Input;
const Key = aya.Key;
const MouseWheel = aya.MouseWheel;
const MouseButton = aya.MouseButton;

pub fn run(app: *App) void {
    std.debug.print("\n", .{});

    app.addPlugins(aya.DefaultPlugins)
        .addSystems(aya.Update, InputSystem)
        .run();
}

const InputSystem = struct {
    pub fn run(mouse_buttons_res: Res(Input(MouseButton)), keys_res: Res(Input(Key)), wheel: EventReader(MouseWheel)) void {
        var mouse_buttons: *const Input(MouseButton) = mouse_buttons_res.getAssertExists();
        var keys: *const Input(Key) = keys_res.getAssertExists();

        if (mouse_buttons.justPressed(.left)) std.debug.print("left mouse just pressed\n", .{});
        if (mouse_buttons.justReleased(.left)) std.debug.print("left mouse just released\n", .{});

        if (mouse_buttons.justPressed(.right)) std.debug.print("right mouse just pressed\n", .{});
        if (mouse_buttons.justReleased(.right)) std.debug.print("right mouse just released\n", .{});

        if (keys.justPressed(.a)) std.debug.print("a just pressed\n", .{});
        if (keys.justReleased(.a)) std.debug.print("a just released\n", .{});

        if (keys.anyJustPressed(&.{ .delete, .backspace }))
            std.debug.print("delete or backspace just pressed\n", .{});

        while (keys.getNextJustPressed()) |key| std.debug.print("{} just pressed\n", .{key});

        for (wheel.read()) |motion| std.debug.print("mouse wheel: {}\n", .{motion});
    }
};
