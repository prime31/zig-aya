const builtin = @import("builtin");
const std = @import("std");
const Builder = std.Build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}));
    exe.install();
}

/// prefix_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(exe: *std.Build.Step.Compile) void {
    const lib_cflags = &[_][]const u8{"-O3"};
    exe.addCSourceFile(.{
        .file = .{ .path = thisDir() ++ "/src/fontstash.c" },
        .flags = lib_cflags,
    });
}

pub fn getModule(b: *std.Build) *std.Build.Module {
    return b.createModule(.{
        .root_source_file = .{ .path = thisDir() ++ "/fontstash.zig" },
    });
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
