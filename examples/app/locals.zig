const std = @import("std");
const core = @import("mach-core");
const aya = @import("aya");

const Local = aya.Local;
const LocalValue = struct { data: i32 };

pub fn main() !void {
    aya.App.init()
        .addSystems(aya.First, LocalSystem1)
        .addSystems(aya.First, LocalSystem2)
        .run();
}

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
