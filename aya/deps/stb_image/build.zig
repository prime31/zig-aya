const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

/// test builder. This build file is meant to be included in an executable project. This build method is here
/// only for local testing.
pub fn build(b: *Builder) void {
    const exe = b.addStaticLibrary("JunkLib", null);
    linkArtifact(b, exe, b.standardTargetOptions(.{}), .static, "");
    exe.install();
}

pub fn linkArtifact(b: *Builder, artifact: *std.build.LibExeObjStep, target: std.build.Target) void {
    compileStbImage(b, artifact, target);
}

fn compileStbImage(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target) void {
    exe.linkLibC();
    exe.addIncludeDir("aya/deps/stb_image/src");

    const lib_cflags = &[_][]const u8{"-std=c99"};
    exe.addCSourceFile("aya/deps/stb_image/src/stb_image_impl.c", lib_cflags);
}
