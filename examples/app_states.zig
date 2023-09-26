const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");

const Resources = aya.Resources;
const App = aya.App;
const World = aya.World;
const Iterator = ecs.Iterator;

const SuperState = enum {
    start,
    middle,
    end,
};

pub fn main() !void {
    App.init()
        .addState(SuperState, .start)
        .addSystem(.first, ChangeStateSystem)
        .addSystem(.pre_update, MiddleStateSystem).inState(SuperState, .middle)
        .addSystem(.pre_update, StartStateSystem).inState(SuperState, .start)
        .run();
}

const ChangeStateSystem = struct {
    pub fn run(world: *World, state: aya.ResMut(aya.NextState(SuperState))) void {
        std.debug.print("-- ChangeStateSystem called with state: {}\n", .{state.get().?.state});

        if (state.get().?.state == .start) {
            state.get().?.set(world.ecs, .middle);
        } else {
            state.get().?.set(world.ecs, .start);
        }
    }
};

const StartStateSystem = struct {
    pub fn run() void {
        std.debug.print("-- StartStateSystem called\n", .{});
    }
};

const MiddleStateSystem = struct {
    pub fn run() void {
        std.debug.print("-- EmptyMiddleStateSystem called\n", .{});
    }
};
