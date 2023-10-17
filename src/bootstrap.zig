const aya = @import("aya.zig");
const core = @import("mach-core");
const zgui = @import("zgui");

pub const Bootstrap = struct {
    const Self = @This();
    app: *aya.App,

    pub fn init(self: *Bootstrap) !void {
        self.app = aya.App.init();
        try core.init(.{
            .title = "fooking mach imgui",
            .border = true,
        });
        zgui.backend.init();
        @import("root").run(self.app);
    }

    pub fn update(self: *Bootstrap) !bool {
        zgui.backend.newFrame();

        if (handleEvents(self.app)) return true;

        zgui.backend.draw();
        core.swap_chain.present();

        return false;
    }

    pub fn deinit(_: *Bootstrap) void {
        zgui.backend.deinit();
        core.deinit();
    }
};

/// handles all events sending them off to the ECS. returns true if a close event was found.
fn handleEvents(app: *aya.App) bool {
    _ = app;
    // implement runner.zip

    var iter = core.pollEvents();
    while (iter.next()) |evt| {
        zgui.backend.passEvent(evt);
        switch (evt) {
            .close => return true,
            else => {},
        }
    }

    return false;
}
