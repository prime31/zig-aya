const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}));
    exe.install();
}

/// prefix_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(exe: *std.build.LibExeObjStep) void {
    const lib_cflags = &[_][]const u8{"-O3"};
    exe.addCSourceFile(std.Build.Step.Compile.CSourceFile{
        .file = .{ .path = thisDir() ++ "/src/fontstash.c" },
        .flags = lib_cflags,
    });
}

pub fn getModule(b: *std.Build) *std.build.Module {
    return b.createModule(.{
        .source_file = .{ .path = thisDir() ++ "/fontstash.zig" },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
