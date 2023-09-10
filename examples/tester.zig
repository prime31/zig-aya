const std = @import("std");
const aya = @import("aya");
const ecs = @import("ecs");

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
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.print("GPA has leaks: {}\n", .{gpa.detectLeaks()});

    var app = App.init(gpa.allocator());
    defer app.deinit();

    app.addPlugin(TimePlugin)
        .insertPlugin(PhysicsPlugin{ .data = 35 })
        .addPlugins(.{ TimePlugin, PhysicsPlugin{ .data = 35 } })
        .run();

    var res = Resources.init(gpa.allocator());
    defer res.deinit();

    _ = res.initResource(ClearColorResource);
    const ccr = res.get(ClearColorResource);
    std.debug.print("ccr: {?}\n", .{ccr});

    // res.remove(ClearColorResource);
    std.debug.print("contains ClearColorResource?: {}\n", .{res.contains(ClearColorResource)});

    res.insert(WindowResource{ .value = 33 });
    std.debug.print("contains WindowResource?: {}\n", .{res.contains(WindowResource)});
    res.remove(WindowResource);

    std.debug.print("-+-+-+ flecs test -+-+-+\n", .{});
    const world = ecs.c.ecs_init().?;
    defer _ = ecs.c.ecs_fini(world);

    var system_desc: ecs.c.ecs_system_desc_t = std.mem.zeroInit(ecs.c.ecs_system_desc_t, .{
        .callback = run,
        .run = run,
        .query = std.mem.zeroInit(ecs.c.ecs_query_desc_t, .{
            .filter = std.mem.zeroInit(ecs.c.ecs_filter_desc_t, .{ .expr = null }),
        }),
    });
    ecs.SYSTEM(world, "run_system", ecs.c.EcsOnUpdate, &system_desc);

    ecs.c.ecs_set_target_fps(world, 30);
    _ = ecs.c.ecs_progress(world, 0);
    _ = ecs.c.ecs_progress(world, 0);
    _ = ecs.c.ecs_progress(world, 0);

    ecs.TAG(world, TimePlugin);
    ecs.COMPONENT(world, PhysicsPlugin);
}

fn run(it: [*c]ecs.c.ecs_iter_t) callconv(.C) void {
    std.debug.print("------------ run system tick {d}\n", .{it.*.delta_time});
    if (!ecs.c.ecs_iter_next(it)) return; // could be ecs_filter_next or ecs_query_next
}

fn dummyFn(_: [*c]ecs.c.ecs_iter_t) callconv(.C) void {}
