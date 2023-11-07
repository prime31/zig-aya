const std = @import("std");

pub fn linkArtifact(exe: *std.build.LibExeObjStep) void {
    exe.linkLibC();
    exe.linkFramework("CoreServices");

    exe.addCSourceFile(std.Build.Step.Compile.CSourceFile{
        .file = .{ .path = thisDir() ++ "/lib/watcher.c" },
        .flags = &.{ "-std=c99", "-fno-sanitize=undefined" },
    });
}

pub fn getModule(b: *std.Build, enable_hot_reload: bool) *std.build.Module {
    const step = b.addOptions();
    step.addOption(bool, "hot_reload", enable_hot_reload);

    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/src/watcher.zig" },
        .dependencies = &.{
            .{ .name = "options", .module = step.createModule() },
        },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
