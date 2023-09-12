const std = @import("std");

pub fn linkArtifact(exe: *std.build.LibExeObjStep) void {
    exe.linkLibC();
    exe.addIncludePath(.{ .path = thisDir() ++ "/libs" });

    exe.addCSourceFile(std.Build.Step.Compile.CSourceFile{
        .file = .{ .path = thisDir() ++ "/libs/stb_impl.c" },
        .flags = &.{ "-std=c99", "-fno-sanitize=undefined" },
    });
}

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{ .source_file = .{ .path = thisDir() ++ "/src/stb.zig" } });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
