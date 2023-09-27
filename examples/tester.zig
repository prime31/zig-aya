const std = @import("std");
const aya = @import("aya");

const Allocator = std.mem.Allocator;
const Resources = aya.Resources;
const App = aya.App;

const ClearColorResource = struct {
    value: usize,

    pub fn init(allocator: Allocator) ClearColorResource {
        _ = allocator;
        return .{ .value = 666 };
    }

    pub fn deinit(self: ClearColorResource) void {
        _ = self;
        std.debug.print("ClearColor.deinit\n", .{});
    }
};

const WindowResource = struct {
    value: usize,

    pub fn deinit(self: WindowResource) void {
        _ = self;
        std.debug.print("WindowResource.deinit\n", .{});
    }
};

const PhysicsPlugin = struct {
    data: u8 = 250,

    pub fn build(self: PhysicsPlugin, app: *App) void {
        _ = app;
        std.debug.print("--- PhysicsPlugins.build called. data: {}\n", .{self.data});
    }
};

const TimePlugin = struct {
    pub fn build(app: *App) void {
        _ = app;
        std.debug.print("--- TimePlugin.build called\n", .{});
    }
};

pub fn main() !void {
    App.init()
        .addPlugin(TimePlugin)
        .insertPlugin(PhysicsPlugin{ .data = 35 })
        .addPlugins(.{ TimePlugin, PhysicsPlugin{ .data = 35 } })
        .run();
}
