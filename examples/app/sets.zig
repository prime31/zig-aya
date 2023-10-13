const std = @import("std");
const aya = @import("aya");

const Allocator = std.mem.Allocator;
const App = aya.App;

const BlueSet = struct {};
const RedSet = struct {};
const OrangeSet = struct {};

pub fn main() !void {
    App.init()
        .addSets(aya.Update, .{ RedSet, OrangeSet })
        .configureSets(BlueSet, .after, RedSet)
        .addSystems(RedSet, Red2System)
        .addSystems(RedSet, Red1System).before(Red2System)
        .addSystems(aya.Update, BeforeRedSetSystem).before(Red1System)
        .addSystems(aya.Update, AfterBlueSetSystem)
        .addSystems(BlueSet, BlueSetSystem)
        .run();
}

const BlueSetSystem = struct {
    pub fn run() void {
        std.debug.print("-- BlueSetSystem called\n", .{});
    }
};

const BeforeRedSetSystem = struct {
    pub fn run() void {
        std.debug.print("-- BeforeRedSet called\n", .{});
    }
};

const AfterBlueSetSystem = struct {
    pub fn run() void {
        std.debug.print("-- AfterBlueSetSystem called\n", .{});
    }
};

const Red1System = struct {
    pub fn run() void {
        std.debug.print("-- Red1System called\n", .{});
    }
};

const Red2System = struct {
    pub fn run() void {
        std.debug.print("-- Red2System called\n", .{});
    }
};
