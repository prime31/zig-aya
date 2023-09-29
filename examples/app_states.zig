const std = @import("std");
const aya = @import("aya");

const Resources = aya.Resources;
const App = aya.App;
const World = aya.World;
const Iterator = aya.Iterator;
const Commands = aya.Commands;

const ResMut = aya.ResMut;
const NextState = aya.NextState;
const OnEnter = aya.OnEnter;
const OnExit = aya.OnExit;

const SuperState = enum {
    start,
    middle,
    end,
};

const SuperState2 = enum {
    start,
    middle,
    end,
};

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addState(SuperState, .start)
        .addSystems(.update, StartStateSystem).inState(SuperState, .start)
        .addSystems(OnEnter(SuperState.middle), EnterMiddleStateSystem)
        .addSystems(.update, MiddleStateSystem).inState(SuperState, .middle)
        .addSystems(OnExit(SuperState.start), ExitStartStateSystem)
        .addSystems(.post_update, ChangeStateSystem)
        .run();
}

const ChangeStateSystem = struct {
    pub fn run(commands: Commands, state: ResMut(NextState(SuperState))) void {
        std.debug.print("-- ChangeStateSystem called with current state: {}\n\n", .{state.get().?.state});

        if (state.get().?.state == .start) {
            state.get().?.set(commands, .middle);
        } else {
            state.get().?.set(commands, .start);
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
        std.debug.print("-- MiddleStateSystem called\n", .{});
    }
};

const EnterMiddleStateSystem = struct {
    pub fn run() void {
        std.debug.print("-- EnterMiddleStateSystem called\n", .{});
    }
};

const ExitStartStateSystem = struct {
    pub fn run() void {
        std.debug.print("-- ExitStartStateSystem called\n", .{});
    }
};
