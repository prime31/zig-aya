const std = @import("std");
const aya = @import("aya");

const Allocator = std.mem.Allocator;
const App = aya.App;

const BlueSet = struct {};
const RedSet = struct {};

pub fn main() !void {
    App.init()
        .addPlugins(aya.DefaultPlugins)
        .addSystemSet(aya.Update, RedSet)
        .configureSystemSet(BlueSet, .after, RedSet)
        .enableWebExplorer()
        .addSystems(aya.Update, Red1System).inSet(RedSet)
        .addSystems(aya.Update, BeforeRedSetSystem).before(Red1System)
        .addSystems(aya.Update, AfterRedSetSystem)
        .addSystems(aya.Update, Red2System).inSet(RedSet).before(Red1System)
        .addSystems(aya.Update, BlueSetSystem).inSet(BlueSet)
        .addSystems(aya.Last, PanicSystem)
        .run();
}

const PanicSystem = struct {
    pub fn run() void {
        @panic("fuck");
    }
};

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

const AfterRedSetSystem = struct {
    pub fn run() void {
        std.debug.print("-- AfterRedSet called\n", .{});
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
