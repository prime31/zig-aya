const std = @import("std");

pub fn linkArtifact(exe: *std.build.LibExeObjStep) void {
    exe.linkLibC();
    exe.linkFramework("CoreServices");

    exe.addCSourceFile(std.Build.Step.Compile.CSourceFile{
        .file = .{ .path = thisDir() ++ "/lib/watcher.c" },
        .flags = &.{ "-std=c99", "-fno-sanitize=undefined" },
    });
}

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{ .source_file = .{ .path = thisDir() ++ "/src/watcher.zig" } });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
