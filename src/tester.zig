const std = @import("std");
const Allocator = std.mem.Allocator;
const Resources = @import("app/resources.zig").Resources;
const App = @import("app/app.zig").App;

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
        std.debug.print("PhysicsPlugins.build called. app: {}, data: {}\n", .{ app, self.data });
    }
};

const TimePlugin = struct {
    pub fn build(self: TimePlugin, app: *App) void {
        _ = self;
        std.debug.print("TimePlugin.build called. app: {}\n", .{app});
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.print("GPA has leaks: {}\n", .{gpa.detectLeaks()});

    var app = App.init(gpa.allocator());
    defer app.deinit();

    app.addPlugin(TimePlugin);
    app.insertPlugin(PhysicsPlugin{ .data = 35 });
    // app.insertPlugin(PhysicsPlugin{ .data = 4 });
    // app.addPlugins(.{PhysicsPlugin});
    app.run();

    var res = Resources.init(gpa.allocator());
    defer res.deinit();

    _ = res.initResource(ClearColorResource);
    const ccr = res.get(ClearColorResource);
    std.debug.print("ccr: {?}\n", .{ccr});

    // res.remove(ClearColorResource);
    std.debug.print("contains ClearColorResource?: {}\n", .{res.contains(ClearColorResource)});

    res.insert(WindowResource{ .value = 33 });
    std.debug.print("contains WindowResource?: {}\n", .{res.contains(WindowResource)});
    // res.remove(WindowResource);
}

const World = struct {
    thing: i32 = 1,
};
