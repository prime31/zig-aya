const std = @import("std");
const core = @import("mach-core");
const aya = @import("aya");

pub const Bootstrap = aya.Bootstrap;

const Local = aya.Local;
const LocalValue = struct { data: i32 };

const LocalSystem1 = struct {
    pub fn run(local: Local(LocalValue)) void {
        std.debug.print("-- LocalSystem1. local: {}\n", .{local.get().data});
        local.get().data += 1;
    }
};

const LocalSystem2 = struct {
    pub fn run(local: Local(LocalValue)) void {
        std.debug.print("-- LocalSystem2. local: {}\n", .{local.get().data});
        local.get().data -= 1;
    }
};

pub fn run(app: *aya.App) void {
    app.addSystems(aya.First, LocalSystem1)
        .addSystems(aya.First, LocalSystem2)
        .run();
}
