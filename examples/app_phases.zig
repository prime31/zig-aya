const std = @import("std");
const aya = @import("aya");

const App = aya.App;

const BeforeFirst = struct {};
const AfterUpdate = struct {};
const BeforeAfterUpdate = struct {};
const AfterLast = struct {};

pub fn main() !void {
    std.debug.print("\n", .{});

    App.init()
        .addPhase(BeforeFirst, .before, aya.First)
        .addPhase(AfterUpdate, .after, aya.Update)
        .addPhase(BeforeAfterUpdate, .before, AfterUpdate)
        .addPhase(AfterLast, .after, aya.Last)
        .addSystems(aya.First, FirstSystem)
        .addSystems(aya.PreUpdate, PreUpdateSystem)
        .addSystems(aya.Update, UpdateSystem)
        .addSystems(BeforeFirst, BeforeFirstSystem)
        .addSystems(AfterLast, AfterLastSystem)
        .addSystems(AfterUpdate, AfterUpdateSystem)
        .addSystems(aya.PostUpdate, PostUpdateSystem)
        .addSystems(aya.Last, LastSystem)
        .addSystems(aya.Update, UpdateSystem2)
        .addSystems(BeforeAfterUpdate, BeforeAfterUpdateSystem)
        .run();
}

const BeforeFirstSystem = struct {
    pub fn run() void {
        std.debug.print("-- -- BeforeFirstSystem called\n", .{});
    }
};

const FirstSystem = struct {
    pub fn run() void {
        std.debug.print("-- FirstSystem called\n", .{});
    }
};

const PreUpdateSystem = struct {
    pub fn run() void {
        std.debug.print("-- PreUpdateSystem called\n", .{});
    }
};

const UpdateSystem = struct {
    pub fn run() void {
        std.debug.print("-- UpdateSystem called\n", .{});
    }
};

const UpdateSystem2 = struct {
    pub fn run() void {
        std.debug.print("-- UpdateSystem2 called\n", .{});
    }
};

const BeforeAfterUpdateSystem = struct {
    pub fn run() void {
        std.debug.print("-- -- BeforeAfterUpdateSystem called\n", .{});
    }
};

const AfterUpdateSystem = struct {
    pub fn run() void {
        std.debug.print("-- -- AfterUpdateSystem called\n", .{});
    }
};

const PostUpdateSystem = struct {
    pub fn run() void {
        std.debug.print("-- PostUpdateSystem called\n", .{});
    }
};

const LastSystem = struct {
    pub fn run() void {
        std.debug.print("-- LastSystem called\n", .{});
    }
};

const AfterLastSystem = struct {
    pub fn run() void {
        std.debug.print("-- -- AfterLastSystem called\n\n", .{});
    }
};
